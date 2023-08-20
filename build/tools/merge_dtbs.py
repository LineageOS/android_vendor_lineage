#! /usr/bin/env python3

# Copyright (c) 2020-2021, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import copy
import os
import sys
import subprocess
import shutil
from itertools import product, combinations_with_replacement, chain

def split_array(array, cells):
	"""
	Helper function for parsing fdtget output
	"""
	if array is None:
		return None
	assert (len(array) % cells) == 0
	return frozenset(tuple(array[i*cells:(i*cells)+cells]) for i in range(len(array) // cells))

class DeviceTreeInfo(object):
	def __init__(self, plat, board, pmic):
		self.plat_id = plat
		self.board_id = board
		self.pmic_id = pmic

	def __str__(self):
		s = ""
		if self.plat_id is not None:
			s += " msm-id = <{}>;".format(" ".join(map(str, self.plat_id)))
		if self.board_id is not None:
			s += " board-id = <{}>;".format(" ".join(map(str, self.board_id)))
		if self.pmic_id is not None:
			s += " pmic-id = <{}>;".format(" ".join(map(str, self.pmic_id)))
		return s.strip()

	def __repr__(self):
		return "<{} {}>".format(self.__class__.__name__, str(self))

	def has_any_properties(self):
		return self.plat_id is not None or self.board_id is not None or self.pmic_id is not None

	def __sub__(self, other):
		"""
		This devicetree has plat, board, and pmic id described like this:
		msm-id = <A>, <B>
		board-id = <c>, <d>
		pmic-id = <0, 1>

		Other has plat, board, pmic are:
		msm-id = <A>, <B>
		board-id = <c>
		pmic-id = <0>

		(self - other) will split self into a set of devicetrees with different identifers
		and meets the following requirements:
		 - One of the devicetrees matches the IDs supported by other
		 - The devices which self matches are still supported (through 1 or more extra devicetrees)
		   by creating new devicetrees with different plat/board/pmic IDs
		"""
		assert self.plat_id is None or isinstance(self.plat_id, (set, frozenset))
		assert self.board_id is None or isinstance(self.board_id, (set, frozenset))
		assert self.pmic_id is None or isinstance(self.pmic_id, (set, frozenset))
		assert other in self

		new_plat = other.plat_id is not None and self.plat_id != other.plat_id
		new_board = other.board_id is not None and self.board_id != other.board_id
		new_pmic = other.pmic_id is not None and self.pmic_id != other.pmic_id

		res = set()
		# Create the devicetree that matches other exactly
		s = copy.deepcopy(self)
		if new_plat:
			s.plat_id = other.plat_id
		if new_board:
			s.board_id = other.board_id
		if new_pmic:
			s.pmic_id = other.pmic_id
		res.add(s)

		# now create the other possibilities by removing any combination of
		# other's plat, board, and/or pmic. Set logic (unique elemnts) handles
		# duplicate devicetrees IDs spit out by this loop
		for combo in combinations_with_replacement([True, False], 3):
			if not any((c and n) for (c, n) in zip(combo, (new_plat, new_board, new_pmic))):
				continue
			s = copy.deepcopy(self)
			if combo[0] and new_plat:
				s.plat_id -= other.plat_id
			if combo[1] and new_board:
				s.board_id -= other.board_id
			if combo[2] and new_pmic:
				s.pmic_id -= other.pmic_id
			res.add(s)
		return res

	def __hash__(self):
		# Hash should only consider msm-id/board-id/pmic-id
		return hash((self.plat_id, self.board_id, self.pmic_id))

	def __and__(self, other):
		s = copy.deepcopy(self)
		for prop in ['plat_id', 'board_id', 'pmic_id']:
			if getattr(self, prop) is None or getattr(other, prop) is None:
				setattr(s, prop, None)
			else:
				setattr(s, prop, getattr(self, prop) & getattr(other, prop))
		return s

	def _do_equivalent(self, other, property):
		other_prop = getattr(other, property)
		self_prop = getattr(self, property)
		if other_prop is None:
			return True
		return self_prop == other_prop

	def __eq__(self, other):
		"""
		Checks whether other plat_id, board_id, pmic_id matches either identically
		or because the property is none
		"""
		if not isinstance(other, DeviceTreeInfo):
			return False
		if not other.has_any_properties():
			return False
		return all(map(lambda p: self._do_equivalent(other, p), ['plat_id', 'board_id', 'pmic_id']))


	def _do_gt(self, other, property):
		other_prop = getattr(other, property)
		self_prop = getattr(self, property)
		# if either property doesn't exist, it could merge in ABL
		if self_prop is None or other_prop is None:
			return True
		# convert to iterable for convenience of below check
		if isinstance(other_prop, tuple):
			# if this property is all 0s, ABL coud match with anything on other
			other_prop = [other_prop]
		assert hasattr(other_prop, '__iter__')
		if len(other_prop) == 1 and all(p == 0 for p in next(iter(other_prop))):
			return True
		# Test if this property intersects with other property
		if hasattr(self_prop, '__contains__') and not isinstance(self_prop, tuple):
			return any(p in self_prop for p in other_prop)
		else:
			return self_prop in other_prop

	def __gt__(self, other):
		"""
		Test if other is a more specific devicetree for self

		This is used to test whether other devicetree applies to self by ABL matching rules
		"""
		if not isinstance(other, DeviceTreeInfo):
			return False
		if not other.has_any_properties():
			return False
		return all(map(lambda p: self._do_gt(other, p), ['plat_id', 'board_id', 'pmic_id']))


	def _do_contains(self, other, property):
		other_prop = getattr(other, property)
		self_prop = getattr(self, property)
		# if other property doesn't exist, it can apply here
		if other_prop is None:
			return True
		# if self and other are sets, use "issubset". Handle special case where other set is
		# empty, in which case they aren't compatible because other_prop should be None
		if isinstance(self_prop, (set, frozenset)) and isinstance(other_prop, (set, frozenset)):
			return len(other_prop) > 0 and other_prop.issubset(self_prop)
		# unpack to one item for convience of below check
		if hasattr(other_prop, '__len__') and not isinstance(other_prop, tuple):
			if len(other_prop) == 1:
				other_prop = next(iter(other_prop))
		# if this is a single value (tuple), not a list of them, other needs to match exactly
		if isinstance(self_prop, tuple):
			return self_prop == other_prop
		# otherwise, use contains if possible (e.g. list or set of tuples)
		if hasattr(self_prop, '__contains__'):
			return other_prop in self_prop
		return False

	def __contains__(self, other):
		"""
		Test if other devicetree covers this devicetree. That is, the devices other devicetree
		matches is a subset of the devices this devicetree matches
		"""
		if not isinstance(other, DeviceTreeInfo):
			return False
		if not other.has_any_properties():
			return False
		return all(map(lambda p: self._do_contains(other, p), ['plat_id', 'board_id', 'pmic_id']))

class DeviceTree(DeviceTreeInfo):
	def __init__(self, filename):
		self.filename = filename
		msm_id = split_array(self.get_prop('/', 'qcom,msm-id', check_output=False), 2)
		board_id = split_array(self.get_prop('/', 'qcom,board-id', check_output=False), 2)
		# default pmic-id-size is 4
		pmic_id_size = self.get_prop('/', 'qcom,pmic-id-size', check_output=False) or 4
		pmic_id = split_array(self.get_prop('/', 'qcom,pmic-id', check_output=False), pmic_id_size)
		super().__init__(msm_id, board_id, pmic_id)

		if not self.has_any_properties():
			print('WARNING! {} has no properties and may match with any other devicetree'.format(self.filename))

	def get_prop(self, node, property, prop_type='i', check_output=True):
		r = subprocess.run(["fdtget", "-t", prop_type, self.filename, node, property],
			check=check_output, stdout=subprocess.PIPE,
			stderr=None if check_output else subprocess.DEVNULL)
		if r.returncode != 0:
			return None
		out = r.stdout.decode("utf-8").strip()

		out_array = None
		if prop_type[-1] == 'i' or prop_type[-1] == 'u':
			out_array = [int(e) for e in out.split(' ')]
		if prop_type[-1] == 'x':
			out_array = [int(e, 16) for e in out.split(' ')]
		if out_array is not None:
			if len(out_array) == 0:
				return None
			if len(out_array) == 1:
				return out_array[0]
			return out_array

		return out

	def __str__(self):
		return "{} [{}]".format(super().__str__(), self.filename)

class InnerMergedDeviceTree(DeviceTreeInfo):
	"""
	InnerMergedDeviceTree is an actual representation of a merged devicetree.
	It has a platform, board, and pmic ID, the "base" devicetree, and some set of add-on
	devicetrees
	"""
	def __init__(self, filename, plat_id, board_id, pmic_id, techpacks=None):
		self.base = filename
		self.techpacks = techpacks or []
		super().__init__(plat_id, board_id, pmic_id)

	def try_add(self, techpack):
		if not isinstance(techpack, DeviceTree):
			raise TypeError("{} is not a DeviceTree object".format(repr(techpack)))
		intersection = techpack & self
		if intersection in self:
			self.techpacks.append(intersection)
			return True
		return False

	def save(self, name=None, out_dir='.'):
		if name is None:
			name = self.get_name()

		out_file = os.path.join(out_dir, name)
		ext = os.path.splitext(os.path.basename(self.base))[1]

		# This check might fail in future if we get into an edge case
		# when splitting the base devicetree into multiple merged DTs
		assert not os.path.exists(out_file)

		if len(self.techpacks) == 0:
			cmd = ['cp', self.base, out_file]
		else:
			if ext == '.dtb':
				cmd = ['fdtoverlay']
			else:
				cmd = ['fdtoverlaymerge']
			cmd.extend(['-i', self.base])
			cmd.extend([tp.filename for tp in self.techpacks])
			cmd.extend(['-o', out_file])

		print(' {}'.format(' '.join(cmd)))
		subprocess.run(cmd, check=True)

		if self.plat_id:
			plat_iter = self.plat_id if isinstance(self.plat_id, tuple) else chain.from_iterable(self.plat_id)
			cmd = ['fdtput', '-t', 'i', out_file, '/', 'qcom,msm-id'] + list(map(str, plat_iter))
			print('  {}'.format(' '.join(cmd)))
			subprocess.run(cmd, check=True)

		if self.board_id:
			board_iter = self.board_id if isinstance(self.board_id, tuple) else chain.from_iterable(self.board_id)
			cmd = ['fdtput', '-t', 'i', out_file, '/', 'qcom,board-id'] + list(map(str, board_iter))
			print('  {}'.format(' '.join(cmd)))
			subprocess.run(cmd, check=True)

		if self.pmic_id:
			pmic_iter = self.pmic_id if isinstance(self.pmic_id, tuple) else chain.from_iterable(self.pmic_id)
			cmd = ['fdtput', '-t', 'i', out_file, '/', 'qcom,pmic-id'] + list(map(str, pmic_iter))
			print('  {}'.format(' '.join(cmd)))
			subprocess.run(cmd, check=True)

		return DeviceTree(out_file)

	def get_name(self):
		ext = os.path.splitext(os.path.basename(self.base))[1]
		base_parts = self.filename_to_parts(self.base)
		return '-'.join(chain.from_iterable([base_parts] + [self.filename_to_parts(tp.filename, ignored_parts=base_parts) for tp in self.techpacks])) + ext

	@staticmethod
	def filename_to_parts(name, ignored_parts=[]):
		# Extract just the basename, with no suffix
		filename = os.path.splitext(os.path.basename(name))[0]
		parts = filename.split('-')
		return [part for part in parts if part not in ignored_parts]

	def __str__(self):
		return "{} [{} + {{{}}}]".format(super().__str__(), self.base, " ".join(t.filename for t in self.techpacks))

class MergedDeviceTree(object):
	def __init__(self, other):
		self.merged_devicetrees = {InnerMergedDeviceTree(other.filename, other.plat_id, other.board_id, other.pmic_id)}

	def try_add(self, techpack):
		did_add = False
		for mdt in self.merged_devicetrees.copy():
			# techpack and kernel devicetree need only to overlap in order to merge,
			# and not match exactly. Think: venn diagram.
			# Need 2 things: The devicetree part that applies to
			# both kernel and techpack intersection = (techpack & mdt)
			# and the part that applies only to kernel difference = (mdt - intersection)
			# Note that because devicetrees are "multi-dimensional", doing (mdt - intersection)
			# may result in *multiple* devicetrees

			# techpack may apply to a superset of devices the mdt applies to
			# reduce the techpack to just the things mdt has:
			intersection = techpack & mdt
			if intersection not in mdt:
				continue
			# mdt may apply to a superset of devices the techpack DT applies to
			# (mdt - intersection) splits mdt into appropriate number of devicetrees
			# such that we can apply techpack onto one of the resulting DTs in the
			# difference
			difference = mdt - intersection
			if len(difference) > 1:
				print('Splitting {}'.format(mdt))
				print(' because  {}'.format(techpack))
				self.merged_devicetrees.remove(mdt)
				self.merged_devicetrees.update(difference)

		for mdt in self.merged_devicetrees:
			if mdt.try_add(techpack):
				did_add = True
		return did_add


	def save(self, out_dir):
		assert len(self.merged_devicetrees) > 0
		if len(self.merged_devicetrees) == 1:
			name = os.path.basename(next(iter(self.merged_devicetrees)).base)
		else:
			name = None
		for mdt in self.merged_devicetrees:
			print()
			yield mdt.save(name, out_dir)

def parse_dt_files(dt_folder):
	for root, dirs, files in os.walk(dt_folder):
		for filename in files:
			if os.path.splitext(filename)[1] not in ['.dtb', '.dtbo']:
				continue
			filepath = os.path.join(root, filename)
			yield DeviceTree(filepath)

def main():
	if len(sys.argv) != 4:
		print("Usage: {} <base dtb folder> <techpack dtb folder> <output folder>"
		      .format(sys.argv[0]))
		sys.exit(1)

	# 1. Parse the devicetrees -- extract the device info (msm-id, board-id, pmic-id)
	bases = parse_dt_files(sys.argv[1])
	techpacks = parse_dt_files(sys.argv[2])

	# 2.1: Create an intermediate representation of the merged devicetrees, starting with the base
	merged_devicetrees = list(map(lambda dt: MergedDeviceTree(dt), bases))
	# 2.2: Try to add techpack devicetree to each base DT
	for techpack in techpacks:
		did_add = False
		for dt in merged_devicetrees:
			if dt.try_add(techpack):
				did_add = True
		if not did_add:
			print('WARNING! Could not apply {} to any devicetrees'.format(techpack))

	print()
	print('==================================')
	created = []
	# 3. Save the deviectrees to real files
	for dt in merged_devicetrees:
		created.extend(dt.save(sys.argv[3]))

	print()
	print('==================================')
	# 4. Try to apply merged DTBOs onto merged DTBs, when appropriate
	#    This checks that DTBOs and DTBs generated by merge_dtbs.py can be merged by bootloader
	#    at runtime.
	for base, dtbo in product(created, created):
		if os.path.splitext(base.filename)[1] != '.dtb' or os.path.splitext(dtbo.filename)[1] != '.dtbo':
			continue
		# See DeviceTreeInfo.__gt__; this checks whether dtbo is more specific than the base
		if dtbo > base:
			cmd = ['ufdt_apply_overlay', base.filename, dtbo.filename, '/dev/null']
			print(' '.join(cmd))
			subprocess.run(cmd, check=True)


if __name__ == "__main__":
	main()
