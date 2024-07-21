# LineageOS common configuration

## Products

- Car

- Mobile
    
    Depending on available storage, you can choose between:

    - Full
    - Mini

    Available configurations:

    - Phone

        Based on available RAM, you can choose between:

        - Standard
        - Go

    - Tablet

        If the device has telephony capabilities, you can choose between:

        - Telephony
        - Wi-Fi only

- TV

## Makefiles inherittable from device trees

- Car: `common_car.mk`
- Mobile:
    - Phone:
        - Standard:
            - Full: `common_full_phone.mk`
            - Mini: `common_mini_phone.mk`
        - Go:
            - Full: `common_full_go_phone.mk`
            - Mini: `common_mini_go_phone.mk`
    - Tablet:
        - Telephony:
            - Full: `common_full_tablet.mk`
            - Mini: `common_mini_tablet.mk`
        - Wi-Fi only:
            - Full: `common_full_tablet_wifionly.mk`
            - Mini: `common_mini_tablet_wifionly.mk`
- TV: `common_tv.mk`
