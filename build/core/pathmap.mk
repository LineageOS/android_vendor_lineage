# Enter project path into pathmap
#
# $(1): name
# $(2): path
#
define project-set-path
$(eval pathmap_PROJ += $(1):$(2)) \
$(eval PATHMAP_SOONG_NAMESPACES += $(2))
endef

# Enter variant project path into pathmap
#
# $(1): name
# $(2): variable to check
# $(3): base path
#
define project-set-path-variant
    $(call project-set-path,$(1),$(strip \
        $(if $($(2)), \
            $(3)-$($(2)), \
            $(3))))
endef

# Returns the path to the requested module's include directory,
# relative to the root of the source tree.
#
# $(1): a list of modules (or other named entities) to find the projects for
define project-path-for
$(foreach n,$(1),$(patsubst $(n):%,%,$(filter $(n):%,$(pathmap_PROJ))))
endef
