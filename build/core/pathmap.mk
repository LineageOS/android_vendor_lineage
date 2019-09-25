# Enter project path into pathmap
#
# $(1): name
# $(2): path
#
define project-set-path
$(eval pathmap_PROJ += $(1):$(2))
endef

# Returns the path to the requested module's include directory,
# relative to the root of the source tree.
#
# $(1): a list of modules (or other named entities) to find the projects for
define project-path-for
$(foreach n,$(1),$(patsubst $(n):%,%,$(filter $(n):%,$(pathmap_PROJ))))
endef
