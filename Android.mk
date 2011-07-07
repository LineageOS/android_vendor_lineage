# We need a way to prevent the stuff Google Apps replaces from being included in the build.
# This is a hacky way to do that.
ifdef CYANOGEN_WITH_GOOGLE
    PACKAGES.Email.OVERRIDES := Provision QuickSearchBox
endif
