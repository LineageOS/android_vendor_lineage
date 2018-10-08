#
# Copyright (C) 2007 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

empty :=
space := $(empty) $(empty)
$(eval SRC_TARGET_DIR := $(ANDROID_BUILD_TOP)/build/target)

#
# Functions for including AndroidProducts.mk files
# PRODUCT_MAKEFILES is set up in AndroidProducts.mks.
# Format of PRODUCT_MAKEFILES:
# <product_name>:<path_to_the_product_makefile>
# If the <product_name> is the same as the base file name (without dir
# and the .mk suffix) of the product makefile, "<product_name>:" can be
# omitted.

# Search for AndroidProducts.mks in the given dir.
# $(1): the path to the dir
define _search-android-products-files-in-dir
$(sort $(shell test -d $(1) && find -L $(1) \
  -maxdepth 6 \
  -name .git -prune \
  -o -name AndroidProducts.mk -print))
endef

#
# Returns the list of all AndroidProducts.mk files.
# $(call ) isn't necessary.
#
define _find-android-products-files
$(foreach d, device vendor product,$(call _search-android-products-files-in-dir,$(addprefix $(ANDROID_BUILD_TOP)/, $(d)))) \
  $(SRC_TARGET_DIR)/product/AndroidProducts.mk
endef

#
# Returns the sorted concatenation of PRODUCT_MAKEFILES
# variables set in the given AndroidProducts.mk files.
# $(1): the list of AndroidProducts.mk files.
#
define get-product-makefiles
$(sort \
  $(foreach f,$(1), \
    $(eval PRODUCT_MAKEFILES :=) \
    $(eval LOCAL_DIR := $(patsubst %/,%,$(dir $(f)))) \
    $(eval include $(f)) \
    $(PRODUCT_MAKEFILES) \
   ) \
  $(eval PRODUCT_MAKEFILES :=) \
  $(eval LOCAL_DIR :=) \
 )
endef

#
# Returns the sorted concatenation of all PRODUCT_MAKEFILES
# variables set in all AndroidProducts.mk files.
# $(call ) isn't necessary.
#
define get-all-product-makefiles
$(call get-product-makefiles,$(_find-android-products-files))
endef

# Read in all of the product definitions specified by the AndroidProducts.mk
# files in the tree.
all_product_configs := $(get-all-product-makefiles)

# $(1): product
# $(2): makefile path
define create-product-makefile-rule
$(strip $(1)):
	@echo "$(strip $(2))"
endef

# Find the product config makefile for the current product.
# all_product_configs consists items like:
# <product_name>:<path_to_the_product_makefile>
# or just <path_to_the_product_makefile> in case the product name is the
# same as the base filename of the product config makefile.
$(foreach f, $(all_product_configs),\
    $(eval _cpm_words := $(subst :,$(space),$(f)))\
    $(eval _cpm_word1 := $(word 1,$(_cpm_words)))\
    $(eval _cpm_word2 := $(word 2,$(_cpm_words)))\
    $(if $(_cpm_word2),\
        $(eval $(call create-product-makefile-rule, $(_cpm_word1), $(_cpm_word2))),\
        $(eval $(call create-product-makefile-rule, $(basename $(notdir $(f))), $(_cpm_word1)))))

