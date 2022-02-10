ifeq ($(WITH_GMS),true)
    # Special handling for Android TV
    ifeq ($(WITH_GMS_TV),true)
        $(call inherit-product, vendor/partner_gms-tv/products/gms.mk)
        $(call inherit-product, vendor/partner_gms-tv/products/mainline_modules.mk)
    else
        # Specify the GMS makefile you want to use, for example:
        #   - fi.mk             - Project Fi
        #   - gms.mk            - default GMS
        #   - gms_go.mk         - low ram devices
        #   - gms_go_2gb.mk     - low ram devices (2GB)
        #   - gms_64bit_only.mk - devices supporting 64-bit only
        ifneq ($(GMS_MAKEFILE),)
            $(call inherit-product, vendor/partner_gms/products/$(GMS_MAKEFILE))
        else
            $(call inherit-product, vendor/partner_gms/products/gms.mk)
        endif

        # Specify the mainline module makefile you want to use, for example:
        #   - mainline_modules.mk              - updatable apex
        #   - mainline_modules_flatten_apex.mk - flatten apex
        #   - mainline_modules_low_ram.mk      - low ram devices
        ifneq ($(MAINLINE_MODULES_MAKEFILE),)
            $(call inherit-product, vendor/partner_modules/build/$(MAINLINE_MODULES_MAKEFILE))
        endif
    endif
endif
