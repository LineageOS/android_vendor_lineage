/*
 * Copyright (C) 2018 The LineageOS Project
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

#include "verity_tool.h"

#include <getopt.h>
#include <stdio.h>
#include <string.h>

static void print_usage() {
    printf("veritytool - toggle block device verification\n"
           "    --help        show this help\n"
           "    --enable      enable dm-verity\n"
           "    --disable     disable dm-verity\n");
}

int main(int argc, char** argv) {
    int c, rc;
    int enable = 0;
    bool flag_set = false;
    struct option long_opts[] = {
        {"disable", no_argument, &enable, 0},
        {"enable", no_argument, &enable, 1},
        {NULL, 0, NULL, 0},
    };

    while ((c = getopt_long(argc, argv, "de", long_opts, NULL)) != -1) {
        switch (c) {
            case 0:
                flag_set = true;
                break;
            default:
                print_usage();
                exit(0);
        }
    }

    if (!flag_set) {
        print_usage();
        exit(0);
    }

    if (!set_verity_enabled(enable)) {
        printf("Error occurred in set_verity_enable\n");
        exit(EXIT_FAILURE);
    }

    printf("Set verity mode to: %s\n", enable ? "enabled" : "disabled");
    printf("Now reboot your device for settings to take effect\n");
    return 0;
}
