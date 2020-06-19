#
# Copyright (C) 2020 The LineageOS Project
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
from datetime import datetime
from textwrap import dedent, indent
from pathlib import Path

# Global variables
device = ""
vendor = ""
tmpdir = subprocess.check_output(["mktemp", "-d"]).decode('ascii').replace("\n", "")


class Helpers:
    """
    The following class contains internal functions which are supposed to used by other functions.
    Functions in this class must be short, not dependent on any other function in the same class.
    """

    @staticmethod
    def adb_connected():
        """
        Returns True if adb is up and not in recovery
        """
        process = subprocess.Popen(["adb", "get-state"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, error = process.communicate()
        if process.returncode == 0 and "device" in str(output):
            return True
        else:
            return False

    @staticmethod
    def cleanup():
        """
        Kills temporary files on exit
        """
        subprocess.run(["rm", "-rf", tmpdir])

    @staticmethod
    def fix_xml(xml):
        """
        Fixes the given xml file by moving the version declaration to the header if not already at it
        """
        with open(xml, "r+") as file:
            matter = file.readlines()
            header = matter.index("\n".join(s for s in matter if "<?xml version" in s))
            if header != 0:
                matter.insert(0, matter.pop(header))
                file.seek(0)
                file.writelines(matter)
                file.truncate()
            file.close()

    @staticmethod
    def get_file(target, dest, source):
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

    @staticmethod
    def get_hash(file):
        """
        Returns sha1sum of the given file
        """
        shasum_prog = 'shasum' if platform == 'darwin' else 'sha1sum'
        return subprocess.check_output([shasum_prog, file]).decode('ascii').split("  ", 1)[0]

    @staticmethod
    def prefix_match_file(prefix, file):
        """
        Input: prefix and filename to match the prefix for
        Output: returns True if prefix is matched else False
        """
        return str(file).startswith(prefix)

    @staticmethod
    def src_file(spec):
        """
        Input: spec in the form of "src[:dst][;args]"
        Output: "src"
        """
        return spec.split(':', 1)[0]

    @staticmethod
    def suffix_match_file(suffix, file):
        """
        Input: suffix and filename to match the prefix for
        Output: returns True if suffix is matched else False
        """
        return str(file).endswith(suffix)

    @staticmethod
    def target_args(spec):
        """
        Input: spec in the form of "src[:dst][;args]"
        Output: "args" if present, "" otherwise
        """
        if ";" in spec:
            args = spec.split(';', 1)[1]
            return args
        else:
            return ""

    @staticmethod
    def target_file(spec):
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

    @staticmethod
    def truncate_file(file):
        """
        Internal function which truncates a filename by removing the first dir in the path

        Input: file: filename to truncate, return_file: the argument to output the truncated filename to
        Output: file:location
        """
        rm_str = str(file).split('/', 1)[0]
        location = str(file).lstrip(rm_str + "/")
        return f'{file}:{location}'


class AdvHelpers:
    """
    This class contains functions which are dependent upon "Helpers" class and/or are doing a
    lot of work.
    """

    @staticmethod
    def init_adb_connection():
        """
        Depends upon: adb_connected function
        Starts adb server and waits for the device
        """
        subprocess.run(["adb", "start-server"])
        while Helpers.adb_connected() is False:
            print("No device is online. Waiting for one...")
            print("Please connect USB and/or enable USB debugging")
            subprocess.run(["adb", "wait-for-device"])
        else:
            print("\nDevice Found")

        # Check if device is using a TCP connection
        using_tcp = False
        output = subprocess.check_output(["adb", "devices"]).decode('ascii').splitlines()
        device_id = output[1]
        if ":" in device_id:
            using_tcp = True
            device_id = device_id.split(":", 1)[0] + ":5555"

        # Start adb as root if build type is not "user"
        build_type = subprocess.check_output(["adb", "shell", "getprop", "ro.build.type"]).decode('ascii').replace("\n",
                                                                                                                   "")
        if build_type == "user":
            pass
        else:
            subprocess.run(["adb", "root"])
            sleep(1)
            # Connect again as starting adb as root kills connection
            if using_tcp:
                subprocess.run(["adb", "connect", device_id])
            subprocess.run(["adb", "wait-for-device"])

    @staticmethod
    def write_headers(file):
        """
        Writes LineageOS's copyright header to the given file.
        variables: 'device', 'vendor' must be set before using this function.
        Accepted file extensions: '.mk', '.bp'
        """
        if "mk" in Path(file).suffix:
            comment = "# "
        else:
            comment = "// "

        init_year = "2019"
        current_year = datetime.now().year

        file_license = dedent(f"""\
        
        Copyright (C) {init_year}-{current_year} The LineageOS Project

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
        
        This file is generated by device/{vendor}/{device}/setup-makefiles.sh
        
        """)

        header = indent(file_license, comment, lambda line: True)

        with open(file, "w") as file:
            file.write(header)
            file.close()
