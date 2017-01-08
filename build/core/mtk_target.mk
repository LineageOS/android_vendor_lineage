# Bring in Mediatek helper macros
include vendor/cm/build/core/mtk_utils.mk

ifeq ($(BOARD_USES_MTK_HARDWARE),true)
    mtk_flags := -DMTK_HARDWARE

    TARGET_GLOBAL_CFLAGS += $(mtk_flags)
    TARGET_GLOBAL_CPPFLAGS += $(mtk_flags)
    CLANG_TARGET_GLOBAL_CFLAGS += $(mtk_flags)
    CLANG_TARGET_GLOBAL_CPPFLAGS += $(mtk_flags)

    2ND_TARGET_GLOBAL_CFLAGS += $(mtk_flags)
    2ND_TARGET_GLOBAL_CPPFLAGS += $(mtk_flags)
    2ND_CLANG_TARGET_GLOBAL_CFLAGS += $(mtk_flags)
    2ND_CLANG_TARGET_GLOBAL_CPPFLAGS += $(mtk_flags)
endif
