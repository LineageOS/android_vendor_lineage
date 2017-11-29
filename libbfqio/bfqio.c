/*
 * Copyright (C) 2017 The LineageOS Project
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

#define LOG_TAG "bfqio"

#include <fcntl.h>
#include <cutils/iosched_policy.h>
#include <cutils/log.h>
#include <pthread.h>
#include <sys/stat.h>

static int __rtio_cgroup_supported = -1;
static pthread_once_t __rtio_init_once = PTHREAD_ONCE_INIT;

static void __initialize_rtio(void) {
    if (!access("/dev/bfqio/tasks", W_OK) || !access("/dev/bfqio/rt-display/tasks", W_OK)) {
        __rtio_cgroup_supported = 1;
    } else {
        __rtio_cgroup_supported = 0;
    }
}

int android_set_rt_ioprio(int tid, int rt) {
    int fd = -1, rc = -1;

    pthread_once(&__rtio_init_once, __initialize_rtio);
    if (__rtio_cgroup_supported != 1) {
        return -1;
    }

    if (rt) {
        fd = open("/dev/bfqio/rt-display/tasks", O_WRONLY | O_CLOEXEC);
    } else {
        fd = open("/dev/bfqio/tasks", O_WRONLY | O_CLOEXEC);
    }

    if (fd < 0) {
        return -1;
    }

#ifdef HAVE_GETTID
    if (tid == 0) {
        tid = gettid();
    }
#endif

    // specialized itoa -- works for tid > 0
    char text[22];
    char *end = text + sizeof(text) - 1;
    char *ptr = end;
    *ptr = '\0';
    while (tid > 0) {
        *--ptr = '0' + (tid % 10);
        tid = tid / 10;
    }

    rc = write(fd, ptr, end - ptr);
    if (rc < 0) {
        /*
         * If the thread is in the process of exiting,
         * don't flag an error
         */
        if (errno == ESRCH) {
            rc = 0;
        } else {
            SLOGV("android_set_rt_ioprio failed to write '%s' (%s); fd=%d\n",
                  ptr, strerror(errno), fd);
        }
    }

    close(fd);
    return rc;
}
