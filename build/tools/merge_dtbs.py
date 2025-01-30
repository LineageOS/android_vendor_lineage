#! /usr/bin/env python3

# Copyright (c) 2020-2021, The Linux Foundation. All rights reserved.
# Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
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
from collections import defaultdict
import graphlib
import os
import sys
import subprocess
import shutil
from itertools import product, combinations_with_replacement, chain
import logging
import argparse

def split_array(array, cells):
	"""
	Helper function for parsing fdtget output
	"""
	if array is None:
		return None
	assert (len(array) % cells) == 0
	return frozenset(tuple(array[i*cells:(i*cells)+cells]) for i in range(len(array) // cells))

class DeviceTreeInfo(object):
	def __init__(self, plat, board, pmic, proj, hw):
		self.plat_id = plat
		self.board_id = board
		self.pmic_id = pmic
		self.proj_id = proj
		self.hw_id = hw

	def __str__(self):
		s = ""
		if self.plat_id is not None:
			s += " msm-id = <{}>;".format(" ".join(map(str, self.plat_id)))
		if self.board_id is not None:
			s += " board-id = <{}>;".format(" ".join(map(str, self.board_id)))
		if self.pmic_id is not None:
			s += " pmic-id = <{}>;".format(" ".join(map(str, self.pmic_id)))
		if self.proj_id is not None:
			s += " proj_id = <{}>;".format(" ".join(map(str, self.proj_id)))
		if self.hw_id is not None:
			s += " hw_id = <{}>;".format(" ".join(map(str, self.hw_id)))
		return s.strip()

	def __repr__(self):
		return "<{} {}>".format(self.__class__.__name__, str(self))

	def has_any_properties(self):
		return self.plat_id is not None or self.board_id is not None or self.pmic_id is not None or self.proj_id is not None or self.hw_id is not None

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
		assert self.proj_id is None or isinstance(self.proj_id, (set, frozenset))
		assert self.hw_id is None or isinstance(self.hw_id, (set, frozenset))
		assert other in self

		new_plat = other.plat_id is not None and self.plat_id != other.plat_id
		new_board = other.board_id is not None and self.board_id != other.board_id
		new_pmic = other.pmic_id is not None and self.pmic_id != other.pmic_id
		new_proj = other.proj_id is not None and self.proj_id != other.proj_id
		new_hw = other.hw_id is not None and self.hw_id != other.hw_id

		res = set()
		# Create the devicetree that matches other exactly
		s = copy.deepcopy(self)
		if new_plat:
			s.plat_id = other.plat_id
		if new_board:
			s.board_id = other.board_id
		if new_pmic:
			s.pmic_id = other.pmic_id
		if new_proj:
			s.proj_id = other.proj_id
		if new_hw:
			s.hw_id = other.hw_id
		res.add(s)

		# now create the other possibilities by removing any combination of
		# other's plat, board, and/or pmic. Set logic (unique elemnts) handles
		# duplicate devicetrees IDs spit out by this loop
		for combo in combinations_with_replacement([True, False], 5):
			if not any((c and n) for (c, n) in zip(combo, (new_plat, new_board, new_pmic, new_proj, new_hw))):
				continue
			s = copy.deepcopy(self)
			if combo[0] and new_plat:
				s.plat_id -= other.plat_id
			if combo[1] and new_board:
				s.board_id -= other.board_id
			if combo[2] and new_pmic:
				s.pmic_id -= other.pmic_id
			if combo[3] and new_proj:
				s.proj_id -= other.proj_id
			if combo[4] and new_hw:
				s.hw_id -= other.hw_id
			res.add(s)
		return res

	def __hash__(self):
		# Hash should only consider msm-id/board-id/pmic-id
		return hash((self.plat_id, self.board_id, self.pmic_id, self.proj_id, self.hw_id))

	def __and__(self, other):
		s = copy.deepcopy(self)
		for prop in ['plat_id', 'board_id', 'pmic_id', 'proj_id', 'hw_id']:
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
		return all(map(lambda p: self._do_equivalent(other, p), ['plat_id', 'board_id', 'pmic_id', 'proj_id', 'hw_id']))


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
		return all(map(lambda p: self._do_gt(other, p), ['plat_id', 'board_id', 'pmic_id', 'proj_id', 'hw_id']))


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
		return all(map(lambda p: self._do_contains(other, p), ['plat_id', 'board_id', 'pmic_id', 'proj_id', 'hw_id']))

class DeviceTree(DeviceTreeInfo):
	def __init__(self, filename):
		self.filename = filename
		logging.debug('Initializing new DeviceTree: {}'.format(os.path.basename(filename)))
		msm_id = split_array(self.get_prop('/', 'qcom,msm-id', check_output=False), 2)
		board_id = split_array(self.get_prop('/', 'qcom,board-id', check_output=False), 2)

		proj_id_prop = self.get_prop('/', 'oplus,project-id', check_output=False)
		if proj_id_prop is None:
			proj_id = None
		elif (isinstance(proj_id_prop, int)):
			list = []
			list.append(proj_id_prop)
			proj_id = split_array(list,1)
		else:
			proj_id = split_array(proj_id_prop, 1)

		hw_id_prop = self.get_prop('/', 'oplus,hw-id', check_output=False)
		if hw_id_prop is None:
			hw_id = None
		elif (isinstance(hw_id_prop, int)):
			list1 = []
			list1.append(hw_id_prop)
			hw_id = split_array(list1, 1)
		else:
			hw_id = split_array(hw_id_prop, 1)

		# default pmic-id-size is 4
		pmic_id_size = self.get_prop('/', 'qcom,pmic-id-size', check_output=False) or 4
		pmic_id = split_array(self.get_prop('/', 'qcom,pmic-id', check_output=False), pmic_id_size)
		super().__init__(msm_id, board_id, pmic_id, proj_id, hw_id)

		if not self.has_any_properties():
			logging.warning('{} has no properties and may match with any other devicetree'.format(os.path.basename(self.filename)))

	def list_props(self,node):
		r = subprocess.run(["fdtget", "-p", self.filename, node],check=False, stdout=subprocess.PIPE,stderr= subprocess.DEVNULL)
		if r.returncode != 0:
			return []
		out = r.stdout.decode("utf-8").strip()
		return out.splitlines()[:-1]


	def get_prop(self, node, property, prop_type='i', check_output=True):
		r = subprocess.run(["fdtget", "-t", prop_type, self.filename, node, property],check=check_output, stdout=subprocess.PIPE,stderr=None if check_output else subprocess.DEVNULL)
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
		return "[{}] {}".format(os.path.basename(self.filename), super().__str__())

class InnerMergedDeviceTree(DeviceTreeInfo):
	"""
	InnerMergedDeviceTree is an actual representation of a merged devicetree.
	It has a platform, board, and pmic ID, the "base" devicetree, and some set of add-on
	devicetrees
	"""
	def __init__(self, filename, plat_id, board_id, pmic_id, proj_id, hw_id, techpacks=None):
		self.base = filename
		# All inner merged device trees start with zero techpacks
		self.techpacks = techpacks or []
		super().__init__(plat_id, board_id, pmic_id, proj_id, hw_id)

	def try_add(self, techpack):
		if not isinstance(techpack, DeviceTree):
			raise TypeError("{} is not a DeviceTree object".format(repr(techpack)))
		intersection = techpack & self
		if intersection in self:
			self.techpacks.append(intersection)
			logging.debug('Appended after intersection: {}'.format(repr(self)))
			return True
		return False

	def save(self, name=None, out_dir='.'):
		if name is None:
			name = self.get_name()

		logging.info('Saving to: {}'.format(name))
		out_file = os.path.join(out_dir, name)
		ext = os.path.splitext(os.path.basename(self.base))[1]

		# This check might fail in future if we get into an edge case
		# when splitting the base devicetree into multiple merged DTs
		assert not os.path.exists(out_file), "Cannot overwrite: {}".format(out_file)

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

		logging.debug(' {}'.format(' '.join(cmd)))
		subprocess.run(cmd, check=True)

		if self.plat_id:
			plat_iter = self.plat_id if isinstance(self.plat_id, tuple) else chain.from_iterable(self.plat_id)
			cmd = ['fdtput', '-t', 'i', out_file, '/', 'qcom,msm-id'] + list(map(str, plat_iter))
			logging.debug('  {}'.format(' '.join(cmd)))
			subprocess.run(cmd, check=True)

		if self.board_id:
			board_iter = self.board_id if isinstance(self.board_id, tuple) else chain.from_iterable(self.board_id)
			cmd = ['fdtput', '-t', 'i', out_file, '/', 'qcom,board-id'] + list(map(str, board_iter))
			logging.debug('  {}'.format(' '.join(cmd)))
			subprocess.run(cmd, check=True)

		if self.pmic_id:
			pmic_iter = self.pmic_id if isinstance(self.pmic_id, tuple) else chain.from_iterable(self.pmic_id)
			cmd = ['fdtput', '-t', 'i', out_file, '/', 'qcom,pmic-id'] + list(map(str, pmic_iter))
			logging.debug('  {}'.format(' '.join(cmd)))
			subprocess.run(cmd, check=True)

		if self.proj_id:
			proj_iter = self.proj_id if isinstance(self.proj_id, tuple) else chain.from_iterable(self.proj_id)
			cmd = ['fdtput', '-t', 'i', out_file, '/', 'oplus,project-id'] + list(map(str, proj_iter))
			logging.debug('  {}'.format(' '.join(cmd)))
			subprocess.run(cmd, check=True)

		if self.hw_id:
			hw_iter = self.hw_id if isinstance(self.hw_id, tuple) else chain.from_iterable(self.hw_id)
			cmd = ['fdtput', '-t', 'i', out_file, '/', 'oplus,hw-id'] + list(map(str, hw_iter))
			logging.debug('  {}'.format(' '.join(cmd)))
			subprocess.run(cmd, check=True)

		return DeviceTree(out_file)

	def get_name(self):
		ext = os.path.splitext(os.path.basename(self.base))[1]
		base_parts = self.filename_to_parts(self.base)
		name_hash = hex(hash((self.plat_id, self.board_id, self.pmic_id, self.proj_id, self.hw_id)))
		name = '-'.join(chain.from_iterable([base_parts] + [self.filename_to_parts(tp.filename, ignored_parts=base_parts) for tp in self.techpacks]))
		final_name = '-'.join([name, name_hash]) + ext
		return final_name

	@staticmethod
	def filename_to_parts(name, ignored_parts=[]):
		# Extract just the basename, with no suffix
		filename = os.path.splitext(os.path.basename(name))[0]
		parts = filename.split('-')
		return [part for part in parts if part not in ignored_parts]

	def __str__(self):
		return "[{} + {{{}}}] {}".format(os.path.basename(self.base), " ".join(os.path.basename(t.filename) for t in self.techpacks), super().__str__())

class MergedDeviceTree(object):
	def __init__(self, other):
		self.merged_devicetrees = {InnerMergedDeviceTree(other.filename, other.plat_id, other.board_id, other.pmic_id, other.proj_id, other.hw_id)}

	def merged_dt_try_add(self, techpack):
		did_add = False
		for mdt in self.merged_devicetrees.copy():
			logging.debug('{}'.format(repr(mdt)))
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
			logging.debug('Found intersection!')

			# mdt may apply to a superset of devices the techpack DT applies to
			# (mdt - intersection) splits mdt into appropriate number of devicetrees
			# such that we can apply techpack onto one of the resulting DTs in the
			# difference
			difference = mdt - intersection
			if len(difference) > 1:
				logging.debug('Splitting {}'.format(mdt))
				logging.debug('because {}'.format(techpack))
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
			yield mdt.save(name, out_dir)

def find_symbol(dtbs, symbol):
	for symbols, _, dt in dtbs:
		if symbol in symbols:
			return dt

def create_adjacency(dtbs):
	graph = {}
	for _, fixups, dt in dtbs:
		graph[dt] = set()
		for fixup in fixups:
			graph[dt].add(find_symbol(dtbs, fixup))
	return graph

def parse_tech_dt_files(folder):
	dtbs = []
	for root, dirs, files in os.walk(folder):
		for filename in files:
			if os.path.splitext(filename)[1] in ['.dtbo','.dtb']:
				filepath = os.path.join(root, filename)
				dt = DeviceTree(filepath)
				dtbs.append((dt.list_props('/__symbols__'), dt.list_props('/__fixups__'), filepath))
	graph = create_adjacency(dtbs)
	ts = graphlib.TopologicalSorter(graph)
	order = list(ts.static_order())
	devicetrees = []
	for dt in order:
		if dt: # Check the value is 'None'
			devicetrees.append(DeviceTree(dt))
	return devicetrees

def parse_dt_files(dt_folder):
	devicetrees = []
	for root, dirs, files in os.walk(dt_folder):
		for filename in files:
			if os.path.splitext(filename)[1] not in ['.dtb', '.dtbo']:
				continue
			filepath = os.path.join(root, filename)
			devicetrees.append(DeviceTree(filepath))
	return devicetrees

def main():

	parser = argparse.ArgumentParser(description='Merge devicetree blobs of techpacks with Kernel Platform SoCs')
	parser.add_argument('-b', '--base', required=True, help="Folder containing base DTBs from Kernel Platform output")
	parser.add_argument('-t', '--techpack', required=True, help="Folder containing techpack DLKM DTBOs")
	parser.add_argument('-o', '--out', required=True, help="Output folder where merged DTBs will be saved")
	parser.add_argument('--loglevel', choices=['debug', 'info', 'warn', 'error'], default='info', help="Set loglevel to see debug messages")

	args = parser.parse_args()

	logging.basicConfig(level=args.loglevel.upper(), format='%(levelname)s: %(message)s'.format(os.path.basename(sys.argv[0])))

	# 1. Parse the devicetrees -- extract the device info (msm-id, board-id, pmic-id)
	logging.info('Parsing base dtb files from {}'.format(args.base))
	bases = parse_dt_files(args.base)
	all_bases = '\n'.join(list(map(lambda x: str(x), bases)))
	logging.info('Parsed bases: \n{}'.format(all_bases))

	logging.info('Parsing techpack dtb files from {}'.format(args.techpack))
	techpacks = parse_tech_dt_files(args.techpack)
	all_techpacks = '\n'.join(list(map(lambda x: str(x), techpacks)))
	logging.info('Parsed techpacks: \n{}'.format(all_techpacks))

	# 2.1: Create an intermediate representation of the merged devicetrees, starting with the base
	merged_devicetrees = list(map(lambda dt: MergedDeviceTree(dt), bases))
	# 2.2: Try to add techpack devicetree to each base DT
	for techpack in techpacks:
		logging.debug('Trying to add techpack: {}'.format(techpack))
		did_add = False
		for dt in merged_devicetrees:
			if dt.merged_dt_try_add(techpack):
				did_add = True
		if not did_add:
			logging.warning('Could not apply {} to any devicetrees'.format(techpack))

	final_inner_merged_dts = '\n'.join(list(str(mdt.merged_devicetrees) for mdt in merged_devicetrees))
	logging.info('Final Inner Merged Devicetrees: \n{}'.format(final_inner_merged_dts))

	created = []
	# 3. Save the deviectrees to real files
	for dt in merged_devicetrees:
		created.extend(dt.save(args.out))

	# 4. Try to apply merged DTBOs onto merged DTBs, when appropriate
	#    This checks that DTBOs and DTBs generated by merge_dtbs.py can be merged by bootloader
	#    at runtime.
	for base, dtbo in product(created, created):
		if os.path.splitext(base.filename)[1] != '.dtb' or os.path.splitext(dtbo.filename)[1] != '.dtbo':
			continue
		# See DeviceTreeInfo.__gt__; this checks whether dtbo is more specific than the base
		if dtbo > base:
			cmd = ['ufdt_apply_overlay', base.filename, dtbo.filename, '/dev/null']
			logging.info(' '.join(cmd))
			subprocess.run(cmd, check=True)


if __name__ == "__main__":
	main()
