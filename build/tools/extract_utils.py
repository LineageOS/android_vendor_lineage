#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import subprocess
from time import sleep
from sys import platform

tmpdir = subprocess.check_output(["mktemp", "-d"]).decode('ascii')


class Helpers():
    """
    The following class contains internal functions which are supposed to used by other functions.
    Functions in this class must be short, not dependent on any other function in the same class.
    """
    def adb_connected(self):
        """
        Returns True if adb is up and not in recovery
        """
        process = subprocess.Popen(["adb", "get-state"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, error = process.communicate()
        if process.returncode == 0 and "device" in str(output):
            return True
        else:
            return False

    def cleanup(self):
        """
        Kills temporary files on exit
        """
        subprocess.run(["rm", "-rf", tmpdir])

    def get_file(self, target, dest, source):
        """
        target: input file
        dest: destination to copy the target file
        source: can be either 'adb' or anything else

        Returns true if file after completing the pulling the file
        """
        if source is "adb":
            process = subprocess.Popen(["adb", "pull", target, dest], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output, error = process.communicate()
            if process.returncode != 0:
                return False
            else:
                return True
        else:
            process = subprocess.Popen(["cp", "-r", target, dest], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output, error = process.communicate()
            if process.returncode != 0:
                return False
            else:
                return True

    def get_hash(self, file):
        """
        Returns sha1sum of the given file
        """
        if platform == 'darwin':
            return subprocess.check_output(["shasum", file]).decode('ascii').split("  ", 1)[0]
        else:
            return subprocess.check_output(["sha1sum", file]).decode('ascii').split("  ", 1)[0]

    def src_file(self, spec):
        """
        Input: spec in the form of "src[:dst][;args]"
        Output: "src"
        """
        return spec.split(':', 1)[0]

    def prefix_match_file(self, prefix, file):
        """
        Input: prefix and filename to match the prefix for
        Output: returns True if prefix is matched else False
        """
        if str(file).startswith(prefix):
            return True
        else:
            return False

    def suffix_match_file(self, suffix, file):
        """
        Input: suffix and filename to match the prefix for
        Output: returns True if suffix is matched else False
        """
        if str(file).endswith(suffix):
            return True
        else:
            return False

    def target_args(self, spec):
        """
        Input: spec in the form of "src[:dst][;args]"
        Output: "args" if present, "" otherwise
        """
        if ";" in spec:
            args = spec.split(';', 1)[1]
            return args
        else:
            pass

    def target_file(self, spec):
        """
        Input: spec in the form of "src[:dst][;args]"
        Output: "dst" if present, "src" otherwise
        """
        if ":" in spec:
            dst = spec.split(':', 1)[1]
            # Check if dst contains sha1sum or any argument delimited by "|" or ";"
            if "|" in dst:
                dst = spec.split('|', 1)[0]
            elif ";" in dst:
                dst = spec.split(';', 1)[0]
        else:
            dst = spec
        return dst

    def truncate_file(self, file):
        """
        Internal function which truncates a filename by removing the first dir in the path

        Input: file: filename to truncate, return_file: the argument to output the truncated filename to
        Output: file:location
        """
        rm_str = str(file).split('/', 1)[0]
        location = str(file).lstrip(rm_str + "/")
        return "{}:{}".format(file, location)


class AdvHelpers(Helpers):
    """
    This class contains functions which are dependent upon "Helpers" class and/or are doing a
    lot of work.
    """
    def init_adb_connection(self):
        """
        Depends upon: adb_connected function
        Starts adb server and waits for the device
        """
        subprocess.run(["adb", "start-server"])
        count = 0
        while self.adb_connected() is False:
            if count == 0:
                print("No device is online. Waiting for one...")
                print("Please connect USB and/or enable USB debugging")
                count += 1
        else:
            print("\nDevice Found")

        # Check if device is using a TCP connection
        using_tcp = False
        output = subprocess.check_output(["adb", "devices"]).decode('ascii').splitlines()
        device_id = output[1].split(":", 1)[0] + ":5555"
        if ":" in device_id:
            using_tcp = True

        # Start adb as root if build type is not "user"
        build_type = subprocess.check_output(["adb", "shell", "getprop", "ro.build.type"]).decode('ascii')
        if build_type == "user\n":
            pass
        else:
            subprocess.run(["adb", "root"])
            sleep(1)
            # Connect again as starting adb as root kills connection
            if using_tcp:
                subprocess.run(["adb", "connect", device_id])
            subprocess.run(["adb", "wait-for-device"])
            sleep(1)

