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
device, vendor, lineage_root = '', '', ''
init_files = []
prop_path = f'vendor/{vendor}/{device}/proprietary/'
tmpdir = subprocess.check_output(['mktemp', '-d']).decode('ascii').replace('\n', '')


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
        process = subprocess.Popen(['adb', 'get-state'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, error = process.communicate()
        if process.returncode == 0 and 'device' in str(output):
            return True
        else:
            return False

    @staticmethod
    def cleanup():
        """
        Kills temporary files on exit
        """
        subprocess.run(['rm', '-rf', tmpdir])

    @staticmethod
    def fix_xml(xml):
        """
        Fixes the given xml file by moving the version declaration to the header if not already at it
        """
        with open(xml, 'r+') as file:
            matter = file.readlines()
            header = matter.index("\n".join(s for s in matter if '<?xml version' in s))
            if header != 0:
                matter.insert(0, matter.pop(header))
                file.seek(0)
                file.writelines(matter)
                file.truncate()

    @staticmethod
    def get_file(target, dest, source):
        """
        target: input file
        dest: destination to copy the target file
        source: can be either 'adb' or anything else

        Returns process code after completing the pulling the file
        """
        if source is 'adb':
            command = ['adb', 'pull', target, dest]
        else:
            command = ['cp', '-r', target, dest]
        process = subprocess.Popen(command)
        process.communicate()
        return process.returncode

    @staticmethod
    def get_hash(file):
        """
        Returns sha1sum of the given file
        """
        shasum_prog = 'shasum' if platform == 'darwin' else 'sha1sum'
        return subprocess.check_output([shasum_prog, file]).decode('ascii').split('  ', 1)[0]

    @staticmethod
    def target_file(spec):
        """
        Input: spec in the form of 'src[:dst][;args]'
        Output: 'dst' if present, 'src' otherwise
        """
        if ':' in spec:
            dst = spec.split(':', 1)[1]
        else:
            dst = spec
        # Check if dst contains sha1sum or any argument delimited by '|' or ';'
        if "|" in dst:
            return dst.split('|', 1)[0]
        elif ";" in dst:
            return dst.split(';', 1)[0]
        else:
            return dst

    @staticmethod
    def target_list(prop_list, content):
        work_list = []
        if content is "packages":
            for item in list(prop_list):
                if str(item).startswith('-'):
                    work_list.append(item)
        else:
            for item in list(prop_list):
                if not str(item).startswith(('-', '#')):
                    work_list.append(item)

        # Cleanup the list
        work_list = [i.replace('\n', '') for i in work_list]  # new lines
        work_list = list(filter(None, work_list))  # empty strings
        for n, i in enumerate(work_list):
            work_list[n] = Helpers.target_file(i)  # sha|args
        work_list = list(dict.fromkeys(work_list))  # duplicates

        # Sort and return it
        work_list.sort()
        return work_list


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
        subprocess.run(['adb', 'start-server'])
        while Helpers.adb_connected() is False:
            print('No device is online. Waiting for one...')
            print('Please connect USB and/or enable USB debugging')
            subprocess.run(['adb', 'wait-for-device'])
        else:
            print('\nDevice Found')

        # Check if device is using a TCP connection
        using_tcp = False
        output = subprocess.check_output(['adb', 'devices']).decode('ascii').splitlines()
        device_id = output[1]
        if ":" in device_id:
            using_tcp = True
            device_id = device_id.split(":", 1)[0] + ':5555'

        # Start adb as root if build type is not "user"
        build_type = subprocess.check_output(['adb', 'shell', 'getprop', 'ro.build.type']).decode('ascii').replace('\n', '')
        if build_type == 'user':
            pass
        else:
            subprocess.run(['adb', 'root'])
            sleep(1)
            # Connect again as starting adb as root kills connection
            if using_tcp:
                subprocess.run(['adb', 'connect', device_id])
            else:
                subprocess.run(['adb', 'wait-for-device'])

    @staticmethod
    def setup_vendor(name='', oem='', path=''):
        """
        Takes argument from user and sets global variables to be used across various functions
        Input: (device name, vendor name, lineage's source root path)
        """
        global device, vendor, lineage_root, init_files
        device = name
        vendor = oem
        lineage_root = path
        output_path = f'{lineage_root}/vendor/{vendor}/{device}'
        setup_files = [
            f'{output_path}/{device}-vendor.mk',
            f'{output_path}/Android.bp',
            f'{output_path}/Android.mk',
            f'{output_path}/BoardConfigVendor.mk'
        ]
        init_files = setup_files

        # Create initial vendor dir & files
        Path(output_path).mkdir(parents=True, exist_ok=True)
        for args in init_files:
            open(args, 'a').close()

    @staticmethod
    def write_headers(args):
        """
        Cleans and writes LineageOS's copyright header to the given file.
        variables: 'device', 'vendor' must be set before using this function.
        Accepted file extensions: '.mk', '.bp'
        setup_vendor function must be run before using this function
        """
        if Path(args).suffix == '.mk':
            comment = '# '
        else:
            comment = '// '

        current_year = datetime.now().year
        file_license = dedent(f'''\

        Copyright (C) 2019-{current_year} The LineageOS Project

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

        ''')

        header = indent(file_license, comment, lambda line: True)
        with open(args, 'w') as target:
            target.write(header + '\n')

    @staticmethod
    def write_product_copy_files(prop_list):
        """
        Takes a list as argument and writes files to copied into device-vendor.mk file
        setup_vendor function must be run before using this function
        """
        # Filter the given list to remove package targets
        work_list = Helpers.target_list(prop_list, "copy")

        # Append proper partition suffixes to copy the target into
        app_list = []
        for item in work_list:
            if str(item).startswith('vendor'):
                suffix = '$(TARGET_COPY_OUT_VENDOR)/'
            elif str(item).startswith('product'):
                suffix = '$(TARGET_COPY_OUT_PRODUCT)/'
            elif str(item).startswith('odm'):
                suffix = '$(TARGET_COPY_OUT_ODM)/'
            else:
                suffix = '$(TARGET_COPY_OUT_SYSTEM)/'
            app_list.append(f'{suffix}{item}' + ' \\')

        # Remove backslash from the last line
        app_list[-1] = app_list[-1].replace(' \\', '')

        # Create a dic based on the prop_list and app_list
        fin_files = dict(zip(work_list, app_list))

        with open(init_files[0], 'a') as target:
            target.write('PRODUCT_SOONG_NAMESPACES += \\' + '\n')
            target.write('    ' + f'vendor/{vendor}/{device}' + '\n')
            target.write('\n' + 'PRODUCT_COPY_FILES += \\' + '\n')

        for key, values in fin_files.items():
            with open(init_files[0], 'a') as target:
                target.write('    ' + prop_path + key + ':' + values + "\n")

    @staticmethod
    def write_product_packages(prop_list):
        # Filter the given list to remove copy targets
        work_list = Helpers.target_list(prop_list, "packages")

        with open(init_files[1], 'a') as path:
            path.write('soong_namespace {\n')
            path.write('}\n')

        # Empty string variables
        name, suffix, src, target, multi = '', '', '', '', ''

        for item in work_list:
            org_target = str(item)
            target = org_target.split('-', 1)[1]
            name = Path(item).stem
            suffix = Path(item).suffix
            src = f'proprietary/{target}'

            if target.startswith('vendor/'):
                specific = 'soc_specific: true,'
            elif target.startswith('product/'):
                specific = 'product_specific: true,'
            elif target.startswith('odm/'):
                specific = 'device_specific: true,'
            else:
                specific = None

            if '.apk' == suffix:
                module_format = dedent(f'''\
                android_app_import {{
                        name: "{name}",
                        owner: "{vendor}",
                        apk: "{src}",
                        certificate: "platform",
                        {'privileged: true,' if 'priv-app' in src else ''}
                        dex_preopt: {{
                                enabled: false,
                        }},
                        {specific if specific is not None else ''}
                }}''').replace('\n\n', '\n')
            elif '.jar' == suffix:
                module_format = dedent(f'''\
                dex_import {{
                        name: "{name}",
                        owner: "{vendor}",
                        jars: ["{src}"],
                        {specific if specific is not None else ''}
                }}''').replace('\n\n', '\n')
            elif '.so' == suffix:
                # Check if both 32 & 64 bit targets exist
                libpath = org_target.split('/' + name, 1)[0]
                src32 = libpath + f'/{name}.so'
                src64 = libpath + f'64/{name}.so'
                if src32 and src64 in work_list:
                    work_list.remove(src64)  # Remove 64 bit target to avoid duplication
                    multi = 'both'
                    src32 = src32.split('-', 1)[1]
                    src64 = src64.split('-', 1)[1]
                    module_format = dedent(f'''\
                        cc_prebuilt_library_shared {{
                                name: "{name}",
                                owner: "{vendor}",
                                strip: {{
                                        none: true,
                                }},
                                target: {{
                                        android_arm: {{
                                                srcs: ["proprietary/{src32}"],
                                        }},
                                        android_arm64: {{
                                                srcs: ["proprietary/{src64}"],
                                        }},
                                }},
                                compile_multilib: "{multi}",
                                prefer: true,
                                {specific if specific is not None else ''}
                        }}''').replace('\n\n', '\n')
                else:
                    if 'lib/' in target:
                        multi = '32'
                    else:
                        multi = '64'
                    module_format = dedent(f'''\
                        cc_prebuilt_library_shared {{
                                name: "{name}",
                                owner: "{vendor}",
                                strip: {{
                                        none: true,
                                }},
                                target: {{
                                        android_arm{'64' if multi == '64' else ''}: {{
                                                srcs: ["{src}"],
                                        }},
                                }},
                                compile_multilib: "{multi}",
                                prefer: true,
                                {specific if specific is not None else ''}
                        }}''').replace('\n\n', '\n')
            else:
                module_format = dedent(f'''\
                Yet to implement
                ''')

            with open(init_files[1], 'a') as path:
                path.write('\n')
                path.write(module_format + '\n')

    @staticmethod
    def write_guards():
        """
        Writes build guards for the device into Android.mk file
        setup_vendor function must be run before using this function
        """
        guard = dedent(f'''\
        LOCAL_PATH := $(call my-dir)
        ifneq ($(filter {device},$(TARGET_DEVICE)),)
        endif
        ''')
        with open(init_files[2], 'a') as target:
            target.write(guard)

    @staticmethod
    def extract_files(prop_file):
        """
        Generates a vendor dir from the given list (path to list must be absolute)
        setup_vendor function must be run before using this function
        """
        # Write required contents into the file
        for files in init_files:
            AdvHelpers.write_headers(files)
        AdvHelpers.write_guards()
        with open(prop_file) as file:
            matter = file.readlines()
        AdvHelpers.write_product_copy_files(matter)
        AdvHelpers.write_product_packages(matter)
