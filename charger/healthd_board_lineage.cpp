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
#include <linux/rtc.h>
#include <linux/time.h>
#include <sys/epoll.h>
#include <sys/timerfd.h>

#include "healthd/healthd.h"
#include "minui/minui.h"

#define LOGE(x...) do { KLOG_ERROR("charger", x); } while (0)
#define LOGW(x...) do { KLOG_WARNING("charger", x); } while (0)
#define LOGI(x...) do { KLOG_INFO("charger", x); } while (0)
#define LOGV(x...) do { KLOG_DEBUG("charger", x); } while (0)

static const GRFont* gr_font = NULL;

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

static const GRFont* get_font()
{
    return gr_font;
}

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
    gr_font_size(get_font(), &font_x, &font_y);
    int w = gr_measure(get_font(), cap_str);
    int h = gr_get_height(f->surface);
    int x = (gr_fb_width() - w) / 2;
    int y = (gr_fb_height() + h) / 2;

    gr_color(255, 255, 255, 255);
    gr_text(get_font(), x, y + font_y / 2, cap_str, 0);
}

#ifdef QCOM_HARDWARE
enum alarm_time_type {
    ALARM_TIME,
    RTC_TIME,
};

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

static void alarm_reboot(void)
{
    LOGI("alarm time is up, reboot the phone!\n");
    syscall(__NR_reboot, LINUX_REBOOT_MAGIC1, LINUX_REBOOT_MAGIC2,
            LINUX_REBOOT_CMD_RESTART2, "rtc");
}

static int alarm_set_reboot_time_and_wait(time_t secs)
{
    int rc, epollfd, nevents;
    int fd = 0;
    struct timespec ts;
    epoll_event event, events[1];
    struct itimerspec itval;

    epollfd = epoll_create(1);
    if (epollfd < 0) {
        LOGE("epoll_create failed\n");
        goto err;
    }

    fd = timerfd_create(CLOCK_REALTIME_ALARM, 0);
    if (fd < 0) {
        LOGE("timerfd_create failed\n");
        goto err;
    }

    event.events = EPOLLIN | EPOLLWAKEUP;
    event.data.ptr = (void *)alarm_reboot;
    rc = epoll_ctl(epollfd, EPOLL_CTL_ADD, fd, &event);
    if (rc < 0) {
        LOGE("epoll_ctl(EPOLL_CTL_ADD) failed \n");
        goto err;
    }

    itval.it_value.tv_sec = secs;
    itval.it_value.tv_nsec = 0;

    itval.it_interval.tv_sec = 0;
    itval.it_interval.tv_nsec = 0;

    rc = timerfd_settime(fd, TFD_TIMER_ABSTIME, &itval, NULL);
    if (rc < 0) {
        LOGE("timerfd_settime failed %d\n",rc);
        goto err;
    }

    nevents = epoll_wait(epollfd, events, 1, -1);

    if (nevents <= 0) {
        LOGE("Unable to wait on alarm\n");
        goto err;
    } else {
        (*(void (*)())events[0].data.ptr)();
    }

    close(epollfd);
    close(fd);
    return 0;

err:
    if (epollfd > 0)
        close(epollfd);

    if (fd >= 0)
        close(fd);
    return -1;
}

/*
 * 10s the estimated time from timestamp of alarm thread start
 * to timestamp of android boot completed.
 */
#define TIME_DELTA 10

/* seconds of 1 minute*/
#define ONE_MINUTE 60
static void *alarm_thread(void *)
{
    time_t rtc_secs, alarm_secs;
    int rc;
    timespec ts;

    /*
     * to support power off alarm, the time
     * stored in alarm register at latest
     * shutdown time should be some time
     * earlier than the actual alarm time
     * set by user
     */
    rc = alarm_get_time(ALARM_TIME, &alarm_secs);
    if (rc < 0 || !alarm_secs)
        goto err;

    rc = alarm_get_time(RTC_TIME, &rtc_secs);
    if (rc < 0 || !rtc_secs)
        goto err;
    LOGI("alarm time in rtc is %ld, rtc time is %ld\n", alarm_secs, rtc_secs);

    if (alarm_secs <= rtc_secs) {
        clock_gettime(CLOCK_BOOTTIME, &ts);

        /*
         * It is possible that last power off alarm time is up at this point.
         * (alarm_secs + ONE_MINUTE) is the final alarm time to fire.
         * (rtc_secs + ts.tv_sec + TIME_DELTA) is the estimated time of next
         * boot completed to fire alarm.
         * If the final alarm time is less than the estimated time of next boot
         * completed to fire, that means it is not able to fire the last power
         * off alarm at the right time, so just miss it.
         */
        if (alarm_secs + ONE_MINUTE < rtc_secs + ts.tv_sec + TIME_DELTA) {
            LOGE("alarm is missed\n");
            goto err;
        }

        alarm_reboot();
    }

    rc = alarm_set_reboot_time_and_wait(alarm_secs);
    if (rc < 0)
        goto err;

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
    int scale_fps;  // Not in use (charger/lineage_battery_scale doesn't have FPS text
                    // chunk). We are using hard-coded frame.disp_time instead.

    rc = res_create_multi_display_surface("charger/lineage_battery_scale",
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
    GRFont* tmp_font;
    int res = gr_init_font("font_log", &tmp_font);
    if (res == 0) {
        gr_font = tmp_font;
    } else {
        LOGW("Couldn't open font, falling back to default!\n");
        gr_font = gr_sys_font();
    }

}
