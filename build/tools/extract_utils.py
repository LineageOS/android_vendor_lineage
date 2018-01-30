#!/usr/bin/env python3
#
# Copyright (C) 2018 The LineageOS Project
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
#

import argparse
import datetime
import os
import subprocess

from enum import Enum


class Certificates(Enum):
    PLATFORM = 1
    PRESIGNED = 2


class ModuleClass(Enum):
    APPS = 1
    ETC = 2
    EXECUTABLES = 3
    JAVA_LIBRARIES = 4
    SHARED_LIBRARIES = 5


class Multilib(Enum):
    ONLY_32 = 1
    ONLY_64 = 2
    BOTH = 3


def adb_pull(src, dst):
    subprocess.run(['adb', 'pull', src, dst])


def get_relative_path(blob_path, module_class):
    class_default_paths = {
        ModuleClass.EXECUTABLES: ['bin', 'sbin', 'vendor/bin'],
        ModuleClass.SHARED_LIBRARIES: [
            'lib', 'lib64', 'vendor/lib', 'vendor/lib64'],
    }
    rel_path = os.path.dirname(blob_path)
    if module_class not in class_default_paths:
        raise Exception('no default path for module class {}'.format(module_class))
    rel_path = remove_prefixes(rel_path, class_default_paths[module_class])
    if rel_path:
        return rel_path
    return None


def is_executable(destination_path):
    return destination_path.startswith(('bin/', 'vendor/bin', 'sbin/'))


def is_multilib_64(destination_path):
    return 'lib64/' in destination_path


def is_privileged(destination_path):
    return destination_path.startswith(('priv-app', 'vendor/priv-app'))


def is_rootfs_executable(destination_path):
    return destination_path.startswith('sbin/')


def oat_to_dex():
    # TODO: Implement!
    pass


def parse_blob_path(entry):
    """Return src, dst tuple from raw entry line
    entry: String representing blob listing of form:
           device/path/to/blob:lineage/path/to/blob OR
           device/path/to/blob
           Does not handle non ':' delimiters
    """
    segments = entry.split(':')
    if len(segments) > 2 or len(segments) < 1:
        # This is probably malformed
        raise Exception('malformed entry {}'.format(entry))
    if len(segments) == 2:
        source, destination = segments
        return (source, destination)
    return (entry, entry)


def parse_module_certificate(entry):
    """Return entry sans certificate, certificate tuple from raw entry line
    entry: String representing blob listing of form:
           device/path/to/blob;PRESIGNED OR
           device/path/to/blob
           Does not handle non ';' delimiters
    """
    cert_string_to_enum = {
        'platform': Certificates.PLATFORM,
        'PRESIGNED': Certificates.PRESIGNED,
    }

    segments = entry.split(';')
    if len(segments) > 2 or len(segments) < 1:
        # This is probably malformed
        raise Exception('malformed entry {}'.format(entry))
    if len(segments) == 2:
        entry, cert = segments
        if cert not in cert_string_to_enum:
            raise Exception('unknown signature {}'.format(cert))
        return (entry, cert_string_to_enum[cert])
    return (entry, Certificates.PLATFORM)


def parse_pinned_hash(entry):
    """Return entry sans pinned_hash, pinned_hash tuple from raw entry line
    entry: String representing blob listing of form:
           device/path/to/blob|pinned_hash_value
           Does not handle non '|' delimiters
    """
    segments = entry.split('|')
    if len(segments) > 2 or len(segments) < 1:
        # This is probably malformed
        raise Exception('malformed entry {}'.format(entry))
    if len(segments) == 2:
        entry, pinned_hash = segments
        return (entry, pinned_hash)
    return (entry, None)


def remove_prefixes(text, prefixes):
    for prefix in prefixes:
        if text.startswith(prefix):
            return text[len(prefix):]
    return text


def run_once(func):
    def wrapper(*args, **kwargs):
        if not wrapper.has_run:
            wrapper.has_run = True
            return f(*args, **kwargs)
    wrapper.has_run = False
    return wrapper

@run_once
def set_up_adb():
    subprocess.run(['adb', 'start-server'])
    subprocess.run(['adb', 'wait-for-device'])
    subprocess.run(['adb', 'root'])
    subprocess.run(['adb', 'wait-for-device'])


def write_copyright(args, makefile):
    current_year = datetime.datetime.now().year

    if current_year is not args.copyright:
        makefile.write('# Copyright (C) {}-{} The LineageOS Project\n'.format(
            args.copyright, current_year))
    else:
        makefile.write('# Copyright (C) {} The LineageOS Project\n'.format(
            current_year))
    makefile.write('#\n')
    makefile.write('# Licensed under the Apache License, Version 2.0 (the "License");\n')
    makefile.write('# you may not use this file except in compliance with the License.\n')
    makefile.write('# You may obtain a copy of the License at\n')
    makefile.write('#\n')
    makefile.write('# http://www.apache.org/licenses/LICENSE-2.0\n')
    makefile.write('#\n')
    makefile.write('# Unless required by applicable law or agreed to in writing, software\n')
    makefile.write('# distributed under the License is distributed on an "AS IS" BASIS,\n')
    makefile.write('# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n')
    makefile.write('# See the License for the specific language governing permissions and\n')


# Base blob class
class Blob(object):
    _device = None
    _vendor = None
    _extract_source = None
    _source = None
    _destination = None
    _pinned_hash = None

    def __init__(self, device, vendor, entry_line):
        self._device = device
        self._vendor = vendor


# Objects which are copied using PRODUCT_COPY_FILES
class CopyableBlob(Blob):
    def __init__(self, device, vendor, entry_line):
        super(CopyableBlob, self).__init__(device, vendor, entry_line)

        entry, self._pinned_hash = parse_pinned_hash(entry_line)
        src, dst = parse_blob_path(entry)

        # Always assume we can extract from system/vendor/...
        self._extract_source = os.path.join('system', src)

        # Always expect the actual file to be at dst
        self._source = os.path.join('vendor', self._vendor, self._device, dst)
        # Use TARGET_COPY_OUT_VENDOR if blob is listed at vendor/
        dst = ('$(TARGET_COPY_OUT_VENDOR)/{}'.format(dst[len('vendor/'):])
               if dst.startswith('vendor/') else os.path.join('system', dst))
        self._destination = dst

    def write_android_makefile_entry(self, makefile):
        # Not needed for copyable blob
        pass

    def write_vendor_makefile_entry(self, makefile):
        makefile.write('    {}:{} \\\n'.format(
            self._source, self._destination))

    def extract(self, args):
        # TODO: Implement!
        if args.extract is 'adb':
            adb_pull(self._source, self._destination)
        elif args.extract is 'dir':
            pass
        elif args.extract is 'ota':
            pass
        else:
            raise Exception('bad extraction source {}'.format(args.extract))


# Objects which have a defined makefile entry
class PrebuiltBlob(Blob):
    _module_name = None
    _module_owner = None
    _certificate = Certificates.PLATFORM
    _tags = None
    _module_class = None
    _module_suffix = None
    _is_privileged = False
    _is_proprietary = False
    _multilib = None

    def __init__(self, device, vendor, entry_line):
        super(PrebuiltBlob, self).__init__(device, vendor, entry_line)

        # Strip leading '-'
        entry_line = entry_line[1:]

        self._tags = 'optional'
        self._module_owner = self._vendor

        entry, self._certificate = parse_module_certificate(entry_line)
        entry, self._pinned_hash = parse_pinned_hash(entry)
        src, dst = parse_blob_path(entry)

        # Always expect the actual file to be at dst
        self._source = os.path.join('proprietary', dst)

        # Determine whether this is a proprietary file
        self._is_proprietary = dst.startswith('vendor/')

        # Determine module class, suffix by file extension
        prop_file_name = os.path.basename(dst)
        if prop_file_name.endswith('.apk'):
            self._module_name = prop_file_name[:-len('.apk')]
            self._module_suffix = '.apk'
            self._module_class = ModuleClass.APPS
            self._is_privileged = is_privileged(dst)
        elif prop_file_name.endswith('.jar'):
            self._module_name = prop_file_name[:-len('.jar')]
            self._module_suffix = '.jar'
            self._module_class = ModuleClass.JAVA_LIBRARIES
        elif prop_file_name.endswith('.so'):
            self._module_name = prop_file_name[:-len('.so')]
            self._module_suffix = '.so'
            self._module_class = ModuleClass.SHARED_LIBRARIES
            self._multilib = (Multilib.ONLY_64
                              if is_multilib_64(dst) else Multilib.ONLY_32)
        elif is_executable(dst):
            self._module_name = prop_file_name
            self._module_class = ModuleClass.EXECUTABLES
        else:
            # Assume anything else is ETC
            self._module_name = prop_file_name
            self._module_class = ModuleClass.ETC

    def get_module_name(self):
        return self._module_name

    def get_module_class(self):
        return self._module_class

    def set_multilib_both(self):
        self._multilib = Multilib.BOTH

    def write_android_makefile_entry(self, makefile):
        cert_enum_to_string = {
            Certificates.PLATFORM: 'platform',
            Certificates.PRESIGNED: 'PRESIGNED',
        }
        module_class_enum_to_string = {
            ModuleClass.APPS: 'APPS',
            ModuleClass.ETC: 'ETC',
            ModuleClass.EXECUTABLES: 'EXECUTABLES',
            ModuleClass.SHARED_LIBRARIES: 'SHARED_LIBRARIES'
        }
        multilib_enum_to_string = {
            Multilib.ONLY_32: '32',
            Multilib.ONLY_64: '64',
            Multilib.BOTH: 'both',
        }

        makefile.write('include $(CLEAR_VARS)\n')
        makefile.write('LOCAL_MODULE := {}\n'.format(self._module_name))
        makefile.write('LOCAL_MODULE_OWNER := {}\n'.format(self._module_owner))

        if self._module_class is ModuleClass.SHARED_LIBRARIES:
            if self._multilib is Multilib.BOTH:
                src_32 = self._source
                src_64 = self._source
                if is_multilib_64(self._source):
                    src_32 = src_32.replace('lib64/', 'lib/')
                else:
                    src_64 = src_64.replace('lib/', 'lib64/')
                makefile.write('LOCAL_SRC_FILES_64 := {}\n'.format(src_64))
                makefile.write('LOCAL_SRC_FILES_32 := {}\n'.format(src_32))
            else:
                makefile.write('LOCAL_SRC_FILES := {}\n'.format(
                    self._source))

            makefile.write('LOCAL_MULTILIB := {}\n'.format(
                multilib_enum_to_string[self._multilib]))
            makefile.write('LOCAL_MODULE_SUFFIX := .so\n')

            rel_path = get_relative_path(self._source, self._module_class)
            if rel_path:
                makefile.write('LOCAL_MODULE_RELATIVE_PATH := {}\n'.format(rel_path))
        elif self._module_class is ModuleClass.APPS:
            makefile.write('LOCAL_SRC_FILES := {}\n'.format(
                self._source))
            makefile.write('LOCAL_CERTIFICATE := {}\n'.format(
                cert_enum_to_string[self._certificate]))
            makefile.write('LOCAL_DEX_PREOPT := false\n')
            makefile.write('LOCAL_MODULE_SUFFIX := .apk\n')
        elif self._module_class is ModuleClass.JAVA_LIBRARIES:
            makefile.write('LOCAL_SRC_FILES := proprietary/{}\n'.format(
                self._source))
            makefile.write('LOCAL_MODULE_SUFFIX := .jar\n')
        elif self._module_class is ModuleClass.ETC:
            makefile.write('LOCAL_SRC_FILES := proprietary/{}\n'.format(
                self._source))
        elif self._module_class is ModuleClass.EXECUTABLES:
            makefile.write('LOCAL_SRC_FILES := proprietary/{}\n'.format(
                self._source))

            if is_rootfs_executable(self._source):
                makefile.write(
                        'LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT_SBIN)\n')
                makefile.write(
                        'LOCAL_UNSTRIPPED_PATH := $(TARGET_ROOT_OUT_SBIN_UNSTRIPPED)\n')

            rel_path = get_relative_path(self._source, self._module_class)
            if rel_path:
                makefile.write('LOCAL_MODULE_RELATIVE_PATH := {}\n'.format(rel_path))
        else:
            makefile.write('LOCAL_SRC_FILES := proprietary/{}\n'.format(
                self._source))

        makefile.write('LOCAL_MODULE_TAGS := optional\n')
        makefile.write('LOCAL_MODULE_CLASS := {}\n'.format(
            module_class_enum_to_string[self._module_class]))

        if self._is_privileged:
            makefile.write('LOCAL_PRIVILEGED_MODULE := true\n')
        if self._is_proprietary:
            makefile.write('LOCAL_PROPRIETARY_MODULE := true\n')

        makefile.write('include $(BUILD_PREBUILT)\n')

    def write_vendor_makefile_entry(self, makefile):
        makefile.write('    {} \\\n'.format(self._module_name))

    def extract(self, args):
        # TODO: Implement!
        if args.extract is 'adb':
            pass
        elif args.extract is 'dir':
            pass
        elif args.extract is 'ota':
            pass
        else:
            raise Exception('bad extraction source {}'.format(args.extract))


def parse_proprietary_files(args):
    copyables = []
    prebuilts = {}

    with open(args.file, 'r') as prop_files_list:
        lines = prop_files_list.readlines()
        lines.sort()
        for line in lines:
            line = line.rstrip()

            if not line:
                continue

            if line.startswith('#'):
                # skip comments
                continue

            if line.startswith('-'):
                # Parse a prebuilt
                blob = PrebuiltBlob(args.device, args.vendor, line)
                module_name = blob.get_module_name()
                if module_name in prebuilts:
                    # Handle multilib by marking the first as multilib
                    if (prebuilts[module_name].get_module_class()
                            is not ModuleClass.SHARED_LIBRARIES):
                        raise Exception(
                                'duplicate target {}'.format(module_name))
                    prebuilts[module_name].set_multilib_both()
                else:
                    prebuilts[module_name] = blob
            else:
                # Parse a copyable
                blob = CopyableBlob(args.device, args.vendor, line)
                copyables.append(blob)

    return (copyables, list(prebuilts.values()))


def write_android_makefile(args, prebuilts):
    file_path = os.path.join(
            args.croot, 'vendor', args.vendor, args.device, 'Android.mk')

    with open(file_path, 'w') as android_mk:
        write_copyright(args, android_mk)
        android_mk.write('\n')
        android_mk.write('LOCAL_PATH := $(call my-dir)')
        android_mk.write('\n')
        if args.common:
            # TODO: Allow custom guard
            android_mk.write('ifneq ($(filter {},$(TARGET_DEVICE)),)')
        else:
            android_mk.write('ifeq ($(TARGET_DEVICE),{})\n'.format(args.device))
        android_mk.write('\n')
        for prebuilt in prebuilts:
            prebuilt.write_android_makefile_entry(android_mk)
            android_mk.write('\n')
        android_mk.write('\n')
        android_mk.write('endif\n')


def write_vendor_makefile(args, copyables, prebuilts):
    file_name = '{}-vendor.mk'.format(args.device)
    file_path = os.path.join(
            args.croot, 'vendor', args.vendor, args.device, file_name)

    with open(file_path, 'w') as vendor_mk:
        write_copyright(args, vendor_mk)
        vendor_mk.write('\n')
        vendor_mk.write('PRODUCT_COPY_FILES += \\\n')
        for copyable in copyables:
            copyable.write_vendor_makefile_entry(vendor_mk)

        # always leave one newline so trailing \ isn't taken into effect
        vendor_mk.write('\n')

        vendor_mk.write('PRODUCT_PACKAGES += \\\n')
        for prebuilt in prebuilts:
            prebuilt.write_vendor_makefile_entry(vendor_mk)

        # always leave one newline so trailing \ isn't taken into effect
        vendor_mk.write('\n')


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--device', required=True)
    parser.add_argument('-v', '--vendor', required=True)
    parser.add_argument('-f', '--file', required=True)
    parser.add_argument('-r', '--croot', required=True)
    parser.add_argument('-c', '--copyright')
    parser.add_argument('-m', '--common',
            help='space delimited list of inheriting devices')
    parser.add_argument('-x', '--extract', type=str,
            choices=['adb', 'ota', 'dir'])
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()

    copyables, prebuilts = parse_proprietary_files(args)
    write_android_makefile(args, prebuilts)
    write_vendor_makefile(args, copyables, prebuilts)
