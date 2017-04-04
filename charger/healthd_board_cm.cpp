/*
 * Copyright (C) 2016 The CyanogenMod Project
 *               2017 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <errno.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

#include <cutils/android_reboot.h>
#include <cutils/klog.h>
#include <cutils/misc.h>
#include <cutils/uevent.h>
#include <cutils/properties.h>

#include <pthread.h>
#include <linux/android_alarm.h>
#include <sys/timerfd.h>
#include <linux/rtc.h>

#include "healthd/healthd.h"
#include "minui/minui.h"

#define LOGE(x...) do { KLOG_ERROR("charger", x); } while (0)
#define LOGW(x...) do { KLOG_WARNING("charger", x); } while (0)
#define LOGI(x...) do { KLOG_INFO("charger", x); } while (0)
#define LOGV(x...) do { KLOG_DEBUG("charger", x); } while (0)

struct frame {
    int min_capacity;
    GRSurface *surface;
};

struct animation {
    struct frame *frames;
    int cur_frame;
    int num_frames;
};

static struct animation anim = {
    .frames = NULL,
    .cur_frame = 0,
    .num_frames = 0,
};

static int draw_surface_centered(GRSurface* surface)
{
    int w, h, x, y;

    w = gr_get_width(surface);
    h = gr_get_height(surface);
    x = (gr_fb_width() - w) / 2 ;
    y = (gr_fb_height() - h) / 2 ;

    gr_blit(surface, 0, 0, w, h, x, y);
    return y + h;
}

#define STR_LEN 64
static void draw_capacity(int capacity)
{
    char cap_str[STR_LEN];
    snprintf(cap_str, (STR_LEN - 1), "%d%%", capacity);

    struct frame *f = &anim.frames[0];
    int font_x, font_y;
    gr_font_size(gr_sys_font(), &font_x, &font_y);
    int w = gr_measure(gr_sys_font(), cap_str);
    int h = gr_get_height(f->surface);
    int x = (gr_fb_width() - w) / 2;
    int y = (gr_fb_height() + h) / 2;

    gr_color(255, 255, 255, 255);
    gr_text(gr_sys_font(), x, y + font_y / 2, cap_str, 0);
}

#ifdef QCOM_HARDWARE
enum alarm_time_type {
    ALARM_TIME,
    RTC_TIME,
};

/*
 * shouldn't be changed after
 * reading from alarm register
 */
static time_t alm_secs;

static int alarm_get_time(enum alarm_time_type time_type,
                          time_t *secs)
{
    struct tm tm;
    unsigned int cmd;
    int rc, fd = -1;

    if (!secs)
        return -1;

    fd = open("/dev/rtc0", O_RDONLY);
    if (fd < 0) {
        LOGE("Can't open rtc devfs node\n");
        return -1;
    }

    switch (time_type) {
        case ALARM_TIME:
            cmd = RTC_ALM_READ;
            break;
        case RTC_TIME:
            cmd = RTC_RD_TIME;
            break;
        default:
            LOGE("Invalid time type\n");
            goto err;
    }

    rc = ioctl(fd, cmd, &tm);
    if (rc < 0) {
        LOGE("Unable to get time\n");
        goto err;
    }

    *secs = mktime(&tm) + tm.tm_gmtoff;
    if (*secs < 0) {
        LOGE("Invalid seconds = %ld\n", *secs);
        goto err;
    }

    close(fd);
    return 0;

err:
    close(fd);
    return -1;
}

#define ERR_SECS 2
static int alarm_is_alm_expired()
{
    int rc;
    time_t rtc_secs;

    rc = alarm_get_time(RTC_TIME, &rtc_secs);
    if (rc < 0)
        return 0;

    return (alm_secs >= rtc_secs - ERR_SECS &&
            alm_secs <= rtc_secs + ERR_SECS) ? 1 : 0;
}

static int timerfd_set_reboot_time_and_wait(time_t secs)
{
    int fd;
    int ret = -1;
    fd = timerfd_create(CLOCK_REALTIME_ALARM, 0);
    if (fd < 0) {
        LOGE("Can't open timerfd alarm node\n");
        goto err_return;
    }

    struct itimerspec spec;
    memset(&spec, 0, sizeof(spec));
    spec.it_value.tv_sec = secs;

    if (timerfd_settime(fd, 0 /* relative */, &spec, NULL)) {
        LOGE("Can't set timerfd alarm\n");
        goto err_close;
    }

    uint64_t unused;
    if (read(fd, &unused, sizeof(unused)) < 0) {
       LOGE("Wait alarm error\n");
       goto err_close;
    }

    ret = 0;
err_close:
    close(fd);
err_return:
    return ret;
}

static int alarm_set_reboot_time_and_wait(time_t secs)
{
    int rc, fd;
    struct timespec ts;

    fd = open("/dev/alarm", O_RDWR);
    if (fd < 0) {
        LOGE("Can't open alarm devfs node, trying timerfd\n");
        return timerfd_set_reboot_time_and_wait(secs);
    }

    /* get the elapsed realtime from boot time to now */
    rc = ioctl(fd, ANDROID_ALARM_GET_TIME(
                      ANDROID_ALARM_ELAPSED_REALTIME_WAKEUP), &ts);
    if (rc < 0) {
        LOGE("Unable to get elapsed realtime\n");
        goto err;
    }

    /* calculate the elapsed time from boot time to reboot time */
    ts.tv_sec += secs;
    ts.tv_nsec = 0;

    rc = ioctl(fd, ANDROID_ALARM_SET(
                      ANDROID_ALARM_ELAPSED_REALTIME_WAKEUP), &ts);
    if (rc < 0) {
        LOGE("Unable to set reboot time to %ld\n", secs);
        goto err;
    }

    do {
        rc = ioctl(fd, ANDROID_ALARM_WAIT);
    } while ((rc < 0 && errno == EINTR) || !alarm_is_alm_expired());

    if (rc <= 0) {
        LOGE("Unable to wait on alarm\n");
        goto err;
    }

    close(fd);
    return 0;

err:
    if (fd >= 0)
        close(fd);
    return -1;
}

static void *alarm_thread(void *)
{
    time_t rtc_secs, rb_secs;
    int rc;

    /*
     * to support power off alarm, the time
     * stored in alarm register at latest
     * shutdown time should be some time
     * earlier than the actual alarm time
     * set by user
     */
    rc = alarm_get_time(ALARM_TIME, &alm_secs);
    LOGI("RTC Alarm %ld\n", alm_secs);
    if (rc < 0 || !alm_secs)
        goto err;

    rc = alarm_get_time(RTC_TIME, &rtc_secs);
    LOGI("RTC Clock %ld\n", rtc_secs);
    if (rc < 0)
        goto err;

    /*
     * calculate the reboot time after which
     * the phone will reboot
     */
    rb_secs = alm_secs - rtc_secs;
    if (rb_secs <= 0)
        goto err;

    rc = alarm_set_reboot_time_and_wait(rb_secs);
    if (rc < 0)
        goto err;

    LOGI("Exit from power off charging, reboot the phone!\n");
    android_reboot(ANDROID_RB_RESTART, 0, 0);

err:
    LOGE("Exit from alarm thread\n");
    return NULL;
}
#endif

void healthd_board_init(struct healthd_config*)
{
    pthread_t tid;
    char value[PROP_VALUE_MAX];
    int rc = 0, scale_count = 0, i;
    GRSurface **scale_frames;
    int scale_fps;  // Not in use (charger/cm_battery_scale doesn't have FPS text
                    // chunk). We are using hard-coded frame.disp_time instead.

    rc = res_create_multi_display_surface("charger/cm_battery_scale",
            &scale_count, &scale_fps, &scale_frames);
    if (rc < 0) {
        LOGE("%s: Unable to load battery scale image", __func__);
        return;
    }

    anim.frames = new frame[scale_count];
    anim.num_frames = scale_count;
    for (i = 0; i < anim.num_frames; i++) {
        anim.frames[i].surface = scale_frames[i];
        anim.frames[i].min_capacity = 100/(scale_count-1) * i;
    }

#ifdef QCOM_HARDWARE
    property_get("ro.bootmode", value, "");
    if (!strcmp("charger", value)) {
        rc = pthread_create(&tid, NULL, alarm_thread, NULL);
        if (rc < 0)
            LOGE("Create alarm thread failed\n");
    }
#endif
}

int healthd_board_battery_update(struct android::BatteryProperties*)
{
    // return 0 to log periodic polled battery status to kernel log
    return 1;
}

void healthd_board_mode_charger_draw_battery(
        struct android::BatteryProperties *batt_prop)
{
    int start_frame = 0;
    int capacity = -1;

    if (batt_prop && batt_prop->batteryLevel >= 0) {
        capacity = batt_prop->batteryLevel;
    }

    if (anim.num_frames == 0 || capacity < 0) {
        LOGE("%s: Unable to draw battery", __func__);
        return;
    }

    // Find starting frame to display based on current capacity
    for (start_frame = 1; start_frame < anim.num_frames; start_frame++) {
        if (capacity < anim.frames[start_frame].min_capacity)
            break;
    }
    // Always start from the level just below the current capacity
    start_frame--;

    if (anim.cur_frame < start_frame)
        anim.cur_frame = start_frame;

    draw_surface_centered(anim.frames[anim.cur_frame].surface);
    draw_capacity(capacity);
    // Move to next frame, with max possible frame at max_idx
    anim.cur_frame = ((anim.cur_frame + 1) % anim.num_frames);
}

void healthd_board_mode_charger_battery_update(
        struct android::BatteryProperties*)
{
}

#ifdef HEALTHD_BACKLIGHT_PATH
#ifndef HEALTHD_BACKLIGHT_LEVEL
#define HEALTHD_BACKLIGHT_LEVEL 100
#endif

void healthd_board_mode_charger_set_backlight(bool on)
{
    int fd;
    char buffer[10];

    memset(buffer, '\0', sizeof(buffer));
    fd = open(HEALTHD_BACKLIGHT_PATH, O_RDWR);
    if (fd < 0) {
        LOGE("Could not open backlight node : %s\n", strerror(errno));
        return;
    }
    LOGV("Enabling backlight\n");
    snprintf(buffer, sizeof(buffer), "%d\n", on ? HEALTHD_BACKLIGHT_LEVEL : 0);
    if (write(fd, buffer, strlen(buffer)) < 0) {
        LOGE("Could not write to backlight : %s\n", strerror(errno));
    }
    close(fd);

#ifdef HEALTHD_SECONDARY_BACKLIGHT_PATH
    fd = open(HEALTHD_SECONDARY_BACKLIGHT_PATH, O_RDWR);
    if (fd < 0) {
        LOGE("Could not open second backlight node : %s\n", strerror(errno));
        return;
    }
    LOGV("Enabling secondary backlight\n");
    if (write(fd, buffer, strlen(buffer)) < 0) {
        LOGE("Could not write to second backlight : %s\n", strerror(errno));
        return;
    }
    close(fd);
#endif
}

#else
void healthd_board_mode_charger_set_backlight(bool)
{
}
#endif

void healthd_board_mode_charger_init(void)
{
}
