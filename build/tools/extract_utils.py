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
import hashlib
import os
import shutil
import subprocess
import tempfile
import unittest

from enum import Enum


class TestFileType(unittest.TestCase):
    def test_is_executable(self):
        self.assertTrue(is_executable('bin/perfd'))
        self.assertTrue(is_executable('vendor/bin/perfd'))
        self.assertTrue(is_executable('sbin/hvdcpd'))
        self.assertFalse(is_executable('lib/libaudcal.so'))
        self.assertFalse(is_executable('vendor/lib/libaudcal.so'))

    def test_is_multilib_64(self):
        self.assertTrue(is_multilib_64('lib64/libaudcal.so'))
        self.assertTrue(is_multilib_64('vendor/lib64/librcc.so'))
        self.assertFalse(is_multilib_64('bin/perfd'))
        self.assertFalse(is_multilib_64('lib/libdiag.so'))
        self.assertFalse(is_multilib_64('vendor/lib/libxml2.so'))

    def test_is_privileged(self):
        self.assertTrue(is_privileged('priv-app/Klik/Klik.apk'))
        self.assertTrue(is_privileged('vendor/priv-app/Klik/Klik.apk'))
        self.assertFalse(is_privileged('app/Score/Score.apk'))
        self.assertFalse(is_privileged('bin/perfd'))
        self.assertFalse(is_privileged('lib64/libaudcal.so'))

    def test_is_rootfs_executable(self):
        self.assertTrue(is_rootfs_executable('sbin/hvdcpd'))
        self.assertFalse(is_rootfs_executable('bin/perfd'))
        self.assertFalse(is_rootfs_executable('vendor/bin/perfd'))
        self.assertFalse(is_rootfs_executable('lib/libdiag.so'))

    def test_is_vendor_file(self):
        self.assertTrue(is_vendor_file('vendor/bin/perfd'))
        self.assertTrue(is_vendor_file('vendor/lib64/libaudcal.so'))
        self.assertTrue(is_vendor_file('vendor/etc/gps.conf'))
        self.assertTrue(is_vendor_file('vendor/framework/qcrilhook.jar'))
        self.assertFalse(is_vendor_file('bin/perfd'))
        self.assertFalse(is_vendor_file('lib64/vendor.display.color@1.0_vendor.so'))

class TestParseEntry(unittest.TestCase):
    def test_parse_blob_path(self):
        pass

    def test_parse_module_certificate(self):
        pass

    def test_parse_pinned_hash(self):
        pass


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
    return subprocess.run(['adb', 'pull', src, dst]).returncode


def get_file_hash(file_path):
    with open(file_path, 'rb') as file_obj:
        file_data = file_obj.read()
        return hashlib.sha1(file_data).hexdigest()


def get_multilib_32_path(lib_path):
    return lib_path.replace('lib64/', 'lib/')


def get_multilib_64_path(lib_path):
    return lib_path.replace('lib/', 'lib64/')


def get_relative_path(blob_path, module_class):
    class_default_paths = {
        ModuleClass.EXECUTABLES: ['bin', 'sbin', 'vendor/bin'],
        ModuleClass.SHARED_LIBRARIES: [
            'lib', 'lib64', 'vendor/lib', 'vendor/lib64'],
    }
    rel_path = os.path.dirname(blob_path)
    if module_class not in class_default_paths:
        raise Exception(
                'no default path for module class {}'.format(module_class))
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


def is_vendor_file(destination_path):
    return destination_path.startswith('vendor/')


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
            return func(*args, **kwargs)
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
    _extract_sources = None
    _extract_destination = None
    _mk_source = None
    _mk_destination = None
    _pinned_hash = None

    def __init__(self, device, vendor, entry_line):
        self._device = device
        self._vendor = vendor

    def do_extract_vendor_file(self, croot, dst_path):
        # Extract the file from the existing vendor repo
        vendor_file = os.path.join(croot, 'vendor', self._vendor,
                                   self._device, 'proprietary',
                                   self._extract_destination)
        if os.path.exists(vendor_file):
            if self.is_hash_match(vendor_file):
                shutil.copyfile(vendor_file, dst_path)
                return True
        return False

    def extract_adb(self, croot, out_root, extract_func):
        set_up_adb()

        # Always prepend system/ to on-device path
        src_paths = [os.path.join('system', src)
                     for src in self._extract_sources]

        dst_path = os.path.join(out_root, self._extract_destination)

        if not os.path.isdir(os.path.dirname(dst_path)):
            os.makedirs(os.path.dirname(dst_path))

        for src_path in src_paths:
            # Attempt to copy from existing vendor file first
            if self._pinned_hash and self.do_extract_vendor_file(
                    croot, dst_path):
                break

            if extract_func(croot, src_path, dst_path):
                break

    def extract_dir(self, croot, out_root, src_root, extract_func):
        src_paths = [os.path.join(src_root, src)
                     if src.startswith('vendor/') else
                     os.path.join(src_root, 'system', src)
                     for src in self._extract_sources]

        dst_path = os.path.join(out_root, self._extract_destination)

        if not os.path.isdir(os.path.dirname(dst_path)):
            os.makedirs(os.path.dirname(dst_path))

        for src_path in src_paths:
            # Attempt to copy from existing vendor file first
            if self._pinned_hash and self.do_extract_vendor_file(
                    croot, dst_path):
                break

            if extract_func(croot, src_path, dst_path):
                break

    def is_hash_match(self, file_path):
        file_hash = get_file_hash(file_path)
        return file_hash == self._pinned_hash


# Objects which are copied using PRODUCT_COPY_FILES
class CopyableBlob(Blob):
    def __init__(self, device, vendor, entry_line):
        super(CopyableBlob, self).__init__(device, vendor, entry_line)

        vendor_repo_path = os.path.join('vendor', self._vendor, self._device)

        entry, self._pinned_hash = parse_pinned_hash(entry_line)
        src, dst = parse_blob_path(entry)

        self._mk_source = os.path.join(vendor_repo_path, 'proprietary', dst)

        # Use TARGET_COPY_OUT_VENDOR if blob is listed at vendor/
        self._mk_destination = (
                '$(TARGET_COPY_OUT_VENDOR)/{}'.format(dst[len('vendor/'):])
                if is_vendor_file(dst) else os.path.join('system', dst))

        self._extract_sources = [src, dst] if src != dst else [src]
        self._extract_destination = dst

    def write_android_makefile_entry(self, makefile):
        # Not needed for copyable blob
        pass

    def write_vendor_makefile_entry(self, makefile):
        makefile.write('    {}:{} \\\n'.format(
            self._mk_source, self._mk_destination))

    def do_extract_adb(self, croot, src_path, dst_path):
        # Extract blob represented by self from src_path to dst_path
        # Called from Blob.extract_adb

        adb_pull(src_path, dst_path)

        if not os.path.exists(dst_path):
            print('{} does not exist, skipping'.format(src_path))
            return False

        if self._pinned_hash and not self.is_hash_match(dst_path):
            print('{} does not match expected hash, skipping'.format(
                src_path))
            os.remove(dst_path)
            return False

        return True

    def do_extract_dir(self, croot, src_path, dst_path):
        # Extract blob represented by self from src_path to dst_path
        # Called from Blob.extract_dir

        if not os.path.exists(src_path):
            print('{} does not exist, skipping'.format(src_path))
            return False

        if self._pinned_hash and not self.is_hash_match(src_path):
            print('{} does not match expected hash, skipping'.format(
                src_path))
            return False

        shutil.copyfile(src_path, dst_path, follow_symlinks=True)
        return True


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

        self._tags = 'optional'
        self._module_owner = self._vendor

        entry, self._certificate = parse_module_certificate(entry_line)
        entry, self._pinned_hash = parse_pinned_hash(entry)
        src, dst = parse_blob_path(entry)

        self._mk_source = os.path.join('proprietary', dst)

        self._is_proprietary = is_vendor_file(dst)

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
            # TODO: Handle ETC paths correctly for XML subdir files

        self._extract_sources = [src, dst] if src != dst else [src]
        self._extract_destination = dst

    def get_module_name(self):
        return self._module_name

    def get_module_class(self):
        return self._module_class

    def set_multilib_both(self):
        self._multilib = Multilib.BOTH

    def write_android_makefile_entry(self, makefile):
        module_class_info = {
            ModuleClass.APPS: {
                'name': 'APPS',
                'entry_writer': self.write_app_entry
            },
            ModuleClass.ETC: {
                'name': 'ETC',
                'entry_writer': self.write_etc_entry,
            },
            ModuleClass.EXECUTABLES: {
                'name': 'EXECUTABLES',
                'entry_writer': self.write_executable_entry,
            },
            ModuleClass.JAVA_LIBRARIES: {
                'name': 'JAVA_LIBRARIES',
                'entry_writer': self.write_java_library_entry,
            },
            ModuleClass.SHARED_LIBRARIES: {
                'name': 'SHARED_LIBRARIES',
                'entry_writer': self.write_shared_library_entry,
            },
        }

        if self._module_class not in module_class_info:
            raise Exception('Unknown module class: {}'.format(
                self._module_class))

        makefile.write('include $(CLEAR_VARS)\n')
        makefile.write('LOCAL_MODULE := {}\n'.format(self._module_name))
        makefile.write('LOCAL_MODULE_OWNER := {}\n'.format(self._module_owner))

        module_class_info[self._module_class]['entry_writer'](makefile)

        makefile.write('LOCAL_MODULE_TAGS := optional\n')
        makefile.write('LOCAL_MODULE_CLASS := {}\n'.format(
            module_class_info[self._module_class]['name']))

        if self._is_privileged:
            makefile.write('LOCAL_PRIVILEGED_MODULE := true\n')
        if self._is_proprietary:
            makefile.write('LOCAL_VENDOR_MODULE := true\n')

        makefile.write('include $(BUILD_PREBUILT)\n')

    def write_vendor_makefile_entry(self, makefile):
        makefile.write('    {} \\\n'.format(self._module_name))

    def do_extract_adb(self, croot, src_path, dst_path):
        # Extract blob represented by self from src_path to dst_path
        # Called from Blob.extract_adb

        # Handle multilib extraction by extracting from lib64 and lib
        if (self._module_class is ModuleClass.SHARED_LIBRARIES
                and self._multilib is Multilib.BOTH):
            if is_multilib_64(src_path):
                adb_pull(get_multilib_32_path(src_path),
                         get_multilib_32_path(dst_path))
            else:
                adb_pull(get_multilib_64_path(src_path),
                         get_multilib_64_path(dst_path))
        adb_pull(src_path, dst_path)

        if not os.path.exists(dst_path):
            print('{} does not exist, skipping'.format(src_path))
            return False

        if self._pinned_hash and not self.is_hash_match(dst_path):
            print('{} does not match expected hash, skipping'.format(
                src_path))
            # Remove all associated artifacts
            if is_multilib_64(dst_path):
                os.remove(get_multilib_32_path(dst_path))
                os.remove(dst_path)
            else:
                os.remove(get_multilib_64_path(dst_path))
                os.remove(dst_path)
            return False

        return True

    def do_extract_dir(self, croot, src_path, dst_path):
        # Extract blob represented by self from src_path to dst_path
        # Called from Blob.extract_dir

        if not os.path.exists(src_path):
            print('{} does not exist, skipping'.format(src_path))
            return False

        # Don't attempt to copy any associated artifacts either
        if self._pinned_hash and not self.is_hash_match(src_path):
            print('{} does not match expected hash, skipping'.format(
                src_path))
            return False

        # Handle multilib extraction by extracting from lib64 and lib
        if (self._module_class is ModuleClass.SHARED_LIBRARIES
                and self._multilib is Multilib.BOTH):
            if is_multilib_64(src_path):
                shutil.copyfile(get_multilib_32_path(src_path),
                                get_multilib_32_path(dst_path),
                                follow_symlinks=True)
            else:
                shutil.copyfile(get_multilib_64_path(src_path),
                                get_multilib_64_path(dst_path),
                                follow_symlinks=True)

        shutil.copyfile(src_path, dst_path, follow_symlinks=True)
        return True

    def write_app_entry(self, makefile):
        cert_enum_to_string = {
            Certificates.PLATFORM: 'platform',
            Certificates.PRESIGNED: 'PRESIGNED',
        }
        makefile.write('LOCAL_SRC_FILES := {}\n'.format(
            self._mk_source))
        makefile.write('LOCAL_CERTIFICATE := {}\n'.format(
            cert_enum_to_string[self._certificate]))
        makefile.write('LOCAL_DEX_PREOPT := false\n')
        makefile.write('LOCAL_MODULE_SUFFIX := .apk\n')

    def write_etc_entry(self, makefile):
        makefile.write('LOCAL_SRC_FILES := {}\n'.format(
            self._mk_source))

    def write_executable_entry(self, makefile):
        makefile.write('LOCAL_SRC_FILES := {}\n'.format(
            self._mk_source))

        if is_rootfs_executable(self._mk_source):
            makefile.write(
                    'LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT_SBIN)\n')
            makefile.write(
                    'LOCAL_UNSTRIPPED_PATH := $(TARGET_ROOT_OUT_SBIN_UNSTRIPPED)\n')

            rel_path = get_relative_path(
                    self._mk_source[len('proprietary/'):],
                    self._module_class)
        if rel_path:
            makefile.write(
                    'LOCAL_MODULE_RELATIVE_PATH := {}\n'.format(rel_path))

    def write_java_library_entry(self, makefile):
        makefile.write('LOCAL_SRC_FILES := {}\n'.format(
            self._mk_source))
        makefile.write('LOCAL_MODULE_SUFFIX := .jar\n')

    def write_shared_library_entry(self, makefile):
        multilib_enum_to_string = {
            Multilib.ONLY_32: '32',
            Multilib.ONLY_64: '64',
            Multilib.BOTH: 'both',
        }
        if self._multilib is Multilib.BOTH:
            if is_multilib_64(self._mk_source):
                src_32 = get_multilib_32_path(self._mk_source)
                src_64 = self._mk_source
            else:
                src_32 = self._mk_source
                src_64 = get_multilib_64_path(self._mk_source)
            makefile.write('LOCAL_SRC_FILES_64 := {}\n'.format(src_64))
            makefile.write('LOCAL_SRC_FILES_32 := {}\n'.format(src_32))
        else:
            makefile.write('LOCAL_SRC_FILES := {}\n'.format(
                self._mk_source))

        makefile.write('LOCAL_MULTILIB := {}\n'.format(
            multilib_enum_to_string[self._multilib]))
        makefile.write('LOCAL_MODULE_SUFFIX := .so\n')

        rel_path = get_relative_path(self._mk_source[len('proprietary/'):],
                                     self._module_class)
        if rel_path:
            makefile.write(
                    'LOCAL_MODULE_RELATIVE_PATH := {}\n'.format(rel_path))


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
                blob = PrebuiltBlob(args.device, args.vendor, line[len('-'):])
                module_name = blob.get_module_name()

                # Handle multilib by marking the first as multilib
                if module_name in prebuilts:
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

    if not os.path.isdir(os.path.dirname(file_path)):
        os.makedirs(os.path.dirname(file_path))

    with open(file_path, 'w') as android_mk:
        write_copyright(args, android_mk)
        android_mk.write('\n')
        android_mk.write('LOCAL_PATH := $(call my-dir)')
        android_mk.write('\n')
        if args.common:
            # TODO: Allow custom guard
            android_mk.write('ifneq ($(filter {},$(TARGET_DEVICE)),)')
        else:
            android_mk.write(
                    'ifeq ($(TARGET_DEVICE),{})\n'.format(args.device))
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

    if not os.path.isdir(os.path.dirname(file_path)):
        os.makedirs(os.path.dirname(file_path))

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


def extract(args, out_root, copyables, prebuilts):
    if args.extract == 'adb':
        for copyable in copyables:
            copyable.extract_adb(args.croot, out_root, copyable.do_extract_adb)

        for prebuilt in prebuilts:
            prebuilt.extract_adb(args.croot, out_root, prebuilt.do_extract_adb)
    elif args.extract == 'dir':
        for copyable in copyables:
            copyable.extract_dir(args.croot, out_root, args.target,
                                 copyable.do_extract_dir)

        for prebuilt in prebuilts:
            prebuilt.extract_dir(args.croot, out_root, args.target,
                                 prebuilt.do_extract_dir)
    elif args.extract == 'ota':
        # TODO: Implement!
        pass
    else:
        raise Exception('bad extraction source {}'.format(args.extract))


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
    parser.add_argument('-t', '--target',
                        help='extraction ota/dir target')
    parser.add_argument('-u', '--unit_test',
                        help='run unit tests only', action='store_true')
    args = parser.parse_args()
    if args.extract in ['ota', 'dir'] and not args.target:
        raise Exception('Extract required, but no target specified')
    return args


if __name__ == '__main__':
    args = parse_args()

    if args.unit_test:
        unittest.main()
        exit(0)

    copyables, prebuilts = parse_proprietary_files(args)

    write_android_makefile(args, prebuilts)
    write_vendor_makefile(args, copyables, prebuilts)

    if args.extract:
        temp_root = tempfile.mkdtemp()

        # Extract to temp_root
        extract(args, temp_root, copyables, prebuilts)

        out_path = os.path.join(args.croot, 'vendor', args.vendor,
                                args.device, 'proprietary')

        # Clean up existing proprietary directory
        if os.path.isdir(out_path):
            shutil.rmtree(out_path)

        shutil.move(temp_root, out_path)
