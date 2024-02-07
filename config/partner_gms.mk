ifeq ($(WITH_GMS),true)
    # Special handling for Android TV
    ifeq ($(PRODUCT_IS_ATV),true)
<<<<<<< HEAD   (4f27f7 vars: redfin,bramble: UP1A.231105.001.B2, Feb 2024)
        ifneq (,$(wildcard vendor/partner_gms-tv))
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
=======
        ifneq ($(GMS_MAKEFILE),)
            # Specify the GMS makefile you want to use, for example:
            #   - gms.mk            - default Android TV GMS
            #   - gms_gtv.mk        - default Google TV GMS
            #   - gms_minimal.mk    - minimal Android TV GMS
            $(call inherit-product, vendor/partner_gms-tv/products/$(GMS_MAKEFILE))
        else
            $(call inherit-product-if-exists, vendor/partner_gms-tv/products/gms.mk)
>>>>>>> CHANGE (52bb8d lineage: partner_gms: Allow ATV/Car GMS that isn't partner)
        endif
    # Special handling for Android Automotive
<<<<<<< HEAD   (4f27f7 vars: redfin,bramble: UP1A.231105.001.B2, Feb 2024)
    else ifeq ($(PRODUCT_IS_AUTOMOTIVE),true)
        ifneq (,$(wildcard vendor/partner_gms-car))
            ifneq ($(GMS_MAKEFILE),)
                $(call inherit-product, vendor/partner_gms-car/products/$(GMS_MAKEFILE))
            else
                $(call inherit-product, vendor/partner_gms-car/products/gms.mk)
            endif
=======
    else ifeq ($(PRODUCT_IS_AUTO),true)
        ifneq ($(GMS_MAKEFILE),)
            $(call inherit-product, vendor/partner_gms-car/products/$(GMS_MAKEFILE))
        else
            $(call inherit-product-if-exists, vendor/partner_gms-car/products/gms.mk)
>>>>>>> CHANGE (52bb8d lineage: partner_gms: Allow ATV/Car GMS that isn't partner)
        endif
   else
        ifneq (,$(wildcard vendor/partner_gms))
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
                $(call inherit-product, vendor/partner_gms/products/gms.mk)
            endif
        endif

        ifneq (,$(wildcard vendor/partner_modules))
            # Specify the mainline module makefile you want to use, for example:
            #   - mainline_modules.mk              - updatable apex
            #   - mainline_modules_flatten_apex.mk - flatten apex
            #   - mainline_modules_low_ram.mk      - low ram devices
            ifneq ($(MAINLINE_MODULES_MAKEFILE),)
                $(call inherit-product, vendor/partner_modules/build/$(MAINLINE_MODULES_MAKEFILE))
            endif
        endif
    endif
endif
