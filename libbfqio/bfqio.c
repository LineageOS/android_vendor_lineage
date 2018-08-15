/*
 * Copyright (C) 2017-2018 The LineageOS Project
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
#include <log/log.h>
#include <pthread.h>
#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>

static int __bfq_cgroup_supported = -1;
static pthread_once_t __bfq_init_once = PTHREAD_ONCE_INIT;

static void __initialize_rtio(void) {
    if (!access("/dev/bfqio/tasks", W_OK) ||
            !access("/dev/bfqio/rt-0/tasks", W_OK) ||
            !access("/dev/bfqio/rt-1/tasks", W_OK) ||
            !access("/dev/bfqio/rt-2/tasks", W_OK) ||
            !access("/dev/bfqio/rt-3/tasks", W_OK) ||
            !access("/dev/bfqio/rt-4/tasks", W_OK) ||
            !access("/dev/bfqio/rt-5/tasks", W_OK) ||
            !access("/dev/bfqio/rt-6/tasks", W_OK) ||
            !access("/dev/bfqio/rt-7/tasks", W_OK) ||
            !access("/dev/bfqio/be-0/tasks", W_OK) ||
            !access("/dev/bfqio/be-1/tasks", W_OK) ||
            !access("/dev/bfqio/be-2/tasks", W_OK) ||
            !access("/dev/bfqio/be-3/tasks", W_OK) ||
            !access("/dev/bfqio/be-4/tasks", W_OK) ||
            !access("/dev/bfqio/be-5/tasks", W_OK) ||
            !access("/dev/bfqio/be-6/tasks", W_OK) ||
            !access("/dev/bfqio/be-7/tasks", W_OK) ||
            !access("/dev/bfqio/idle/tasks", W_OK)) {
        __bfq_cgroup_supported = 1;
    } else {
        __bfq_cgroup_supported = 0;
    }
}

int android_set_bfq_ioprio(int id, int prio_class, int prio) {
    int fd = -1, rc = -1;
    char cgroup[22];

    pthread_once(&__bfq_init_once, __initialize_rtio);
    if (__bfq_cgroup_supported != 1) {
        return -1;
    }

    memset(cgroup, 0, sizeof(cgroup));

    // Sanity check
    if (prio < 0) {
        prio = 0;
    } else if (prio > 7) {
        prio = 7;
    }

    // Pick appropriate cgroup
    if (prio_class == 1) {
        snprintf(cgroup, sizeof(cgroup), "/dev/bfqio/rt-%d/tasks", prio);
    } else if (prio_class == 2) {
        snprintf(cgroup, sizeof(cgroup), "/dev/bfqio/be-%d/tasks", prio);
    } else if (prio_class == 3) {
        snprintf(cgroup, sizeof(cgroup), "/dev/bfqio/idle/tasks");
    } else {
        return -1;
    }

    fd = open(cgroup, O_WRONLY | O_CLOEXEC);

    if (fd < 0) {
        return -1;
    }

#ifdef HAVE_GETTID
    // Assume id 0 means get current thread id
    if (id == 0) {
        id = gettid();
    }
#endif

    // specialized itoa -- works for id > 0
    char text[22];
    char *end = text + sizeof(text) - 1;
    char *ptr = end;
    *ptr = '\0';
    while (id > 0) {
        *--ptr = '0' + (id % 10);
        id = id / 10;
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
