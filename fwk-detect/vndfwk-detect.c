/*
 * Copyright (c) 2018, The Linux Foundation. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *    * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above
 *      copyright notice, this list of conditions and the following
 *      disclaimer in the documentation and/or other materials provided
 *      with the distribution.
 *    * Neither the name of The Linux Foundation nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <string.h>
#include <cutils/properties.h>

#include "vndfwk-detect.h"

#define VALUEADD_AOSP_SUPPORT_PROPERTY "ro.vendor.qti.va_aosp.support"
#define VALUEADD_ODM_SUPPORT_PROPERTY "ro.vendor.qti.va_odm.support"
#define VND_ENHANCED_ODM_STATUS_BIT 0x01
#define VND_ENHANCED_SYS_STATUS_BIT 0x02

int isRunningWithVendorEnhancedFramework() {
    bool va_aosp_support = false;
    va_aosp_support = property_get_bool(VALUEADD_AOSP_SUPPORT_PROPERTY, false);

    if (va_aosp_support)
        return 1;

    return 0;
}

/*
 * int getVendorEnhancedInfo(void)
 * return val(int32_t):
 * bit0: for ODM status
 *    =>0: PureAOSP Building
 *    =>1: QC VA Building
 *
 * bit1: for System status
 *    =>0: PureAOSP Building
 *    =>1: QC VA Building
 */
int getVendorEnhancedInfo() {
    int val = 0;
    bool va_odm_support = false;
    va_odm_support = property_get_bool(VALUEADD_ODM_SUPPORT_PROPERTY, false);

    if (va_odm_support) {
        val |= VND_ENHANCED_ODM_STATUS_BIT;
    }

    if (1 == isRunningWithVendorEnhancedFramework()) {
        val |= VND_ENHANCED_SYS_STATUS_BIT;
    }

    return val;
}
