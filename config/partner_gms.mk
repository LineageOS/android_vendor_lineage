ifeq ($(WITH_GMS),true)
    # Special handling for Android TV
    ifeq ($(WITH_GMS_TV),true)
        ifneq ($(GMS_MAKEFILE),)
            # Specify the GMS makefile you want to use, for example:
            #   - gms.mk            - default Android TV GMS
            #   - gms_gtv.mk        - default Google TV GMS
            #   - gms_minimal.mk    - minimal Android TV GMS
            $(call inherit-product, vendor/partner_gms-tv/products/$(GMS_MAKEFILE))
        else
            $(call inherit-product, vendor/partner_gms-tv/products/gms.mk)
        endif
        $(call inherit-product, vendor/partner_gms-tv/products/mainline_modules.mk)
    # Special handling for Android Automotive
    else ifeq ($(WITH_GMS_CAR),true)
        ifneq ($(GMS_MAKEFILE),)
            $(call inherit-product, vendor/partner_gms-car/products/$(GMS_MAKEFILE))
        else
            $(call inherit-product, vendor/partner_gms-car/products/gms.mk)
        endif
   else
        # Specify the GMS makefile you want to use, for example:
        #   - fi.mk             - Project Fi
        #   - gms.mk            - default GMS
        #   - gms_go.mk         - low ram devices
        #   - gms_go_2gb.mk     - low ram devices (2GB)
        #   - gms_64bit_only.mk - devices supporting 64-bit only
        #   - gms_minimal.mk    - minimal GMS
        ifneq ($(GMS_MAKEFILE),)
            $(call inherit-product, vendor/partner_gms/products/$(GMS_MAKEFILE))
        else
            $(call inherit-product-if-exists, vendor/partner_gms/products/gms.mk)
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
