# Board platform lists to be used for platform specific features.

# A Family
A_FAMILY := \
    msm7x27a \
    msm7x30 \
    msm8660 \
    msm8960

# B Family
B_FAMILY := \
    apq8084 \
    msm8226 \
    msm8610 \
    msm8974

# B64 Family
B64_FAMILY := \
    msm8992 \
    msm8994

# BR Family
BR_FAMILY := \
    msm8909 \
    msm8916 \
    msm8952

# MSM7000 Family
MSM7K_BOARD_PLATFORMS += \
    msm7x30 \
    msm7x27 \
    msm7x27a \
    msm7k

# UM Families
UM_3_18_FAMILY := \
    msm8937 \
    msm8953 \
    msm8996

UM_4_4_FAMILY := \
    msm8998 \
    sdm660

UM_4_9_FAMILY := \
    sdm845 \
    sdm710

# Define platform variable names, QCOM didn't drop them for production, e.g.
# ifneq ($(filter $(MSMSTEPPE) $(TRINKET),$(TARGET_BOARD_PLATFORM)),)
MSMSTEPPE := sm6150
TRINKET := trinket #SM6125

UM_4_14_FAMILY := \
    $(MSMSTEPPE) \
    $(TRINKET) \
    msmnile \
    atoll

UM_4_19_FAMILY := \
    kona \
    lito \
    bengal

UM_5_4_FAMILY := \
    holi \
    lahaina

UM_PLATFORMS := $(UM_3_18_FAMILY) $(UM_4_4_FAMILY) $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY) $(UM_5_4_FAMILY)
QCOM_BOARD_PLATFORMS += $(A_FAMILY) $(B_FAMILY) $(B64_FAMILY) $(BR_FAMILY) $(UM_PLATFORMS)
QSSI_SUPPORTED_PLATFORMS := $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY) $(UM_5_4_FAMILY)

# List of board platforms that use master side content protection.
MASTER_SIDE_CP_TARGET_LIST := msm8996 $(UM_4_4_FAMILY) $(UM_4_9_FAMILY) $(UM_4_14_FAMILY) $(UM_4_19_FAMILY) $(UM_5_4_FAMILY)

# List of boards platforms that use video hardware.
MSM_VIDC_TARGET_LIST := $(B_FAMILY) $(B64_FAMILY) $(BR_FAMILY) $(UM_PLATFORMS)
