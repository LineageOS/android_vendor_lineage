/*
 * Copyright (c) 2019, The Linux Foundation. All rights reserved.
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

#define LOG_TAG "VndFwkDetectJNI"

#include "vndfwk-detect.h"

#include "jni.h"
#include "JNIHelp.h"
#include <dlfcn.h>
#include <string.h>
#include <android/log.h>
#include <utils/Log.h>

#define VNDFWK_DETECT_LIB "libqti_vndfwk_detect.so"

typedef struct dlHandler {
    void *dlHandle;
    int (*vndFwkDetect)(void);
    int (*vndEnhancedInfo)(void);
    const char *dlName;
} dlHandler;

static dlHandler mDlHandler = {
    NULL, NULL, NULL, VNDFWK_DETECT_LIB};

static void
com_qualcomm_qti_VndFwkDetect_init()
{
    mDlHandler.dlHandle = dlopen(VNDFWK_DETECT_LIB, RTLD_NOW | RTLD_LOCAL);
    if (mDlHandler.dlHandle == NULL) return;

    *(void **)(&mDlHandler.vndFwkDetect) = dlsym(mDlHandler.dlHandle, "isRunningWithVendorEnhancedFramework");
    if (mDlHandler.vndFwkDetect == NULL)
    {
        if (mDlHandler.dlHandle)
        {
            dlclose(mDlHandler.dlHandle);
            mDlHandler.dlHandle = NULL;
        }

        return;
    }

    *(void **)(&mDlHandler.vndEnhancedInfo) = dlsym(mDlHandler.dlHandle, "getVendorEnhancedInfo");
    if (mDlHandler.vndEnhancedInfo == NULL)
    {
        if (mDlHandler.dlHandle)
        {
            dlclose(mDlHandler.dlHandle);
            mDlHandler.dlHandle = NULL;
        }
    }

    return;
}

static int
com_qualcomm_qti_VndFwkDetect_native_isRunningWithVendorEnhancedFramework(JNIEnv *env, jobject clazz)
{
    if(mDlHandler.vndFwkDetect != NULL)
        return (*mDlHandler.vndFwkDetect)();

    return 0;
}


static int
com_qualcomm_qti_VndFwkDetect_native_getVendorEnhancedInfo(JNIEnv *env, jobject clazz)
{
    if(mDlHandler.vndEnhancedInfo != NULL)
        return (*mDlHandler.vndEnhancedInfo)();

    return 0;
}
static JNINativeMethod gMethods[] = {
    {"native_isRunningWithVendorEnhancedFramework", "()I", (int*)com_qualcomm_qti_VndFwkDetect_native_isRunningWithVendorEnhancedFramework},
    {"native_getVendorEnhancedInfo", "()I", (int*)com_qualcomm_qti_VndFwkDetect_native_getVendorEnhancedInfo}
};

/*
 * JNI initialization
 */
jint JNI_OnLoad(JavaVM *jvm, void *reserved)
{
    JNIEnv *e;
    jclass clazz = 0;
    int status;

    ALOGV("com.qualcomm.qti.VndFwkDetect: loading JNI\n");

    // check JNI version
    if (jvm->GetEnv((void**)&e, JNI_VERSION_1_6)) {
        ALOGE("com.qualcomm.qti.VndFwkDetect: JNI version mismatch error");
        return JNI_ERR;
    }

    clazz = e->FindClass("com/qualcomm/qti/VndFwkDetect");
    if((jclass)0 == clazz) {
        ALOGE("JNI_OnLoad: FindClass failed");
        return JNI_ERR;
    }

    com_qualcomm_qti_VndFwkDetect_init();

    if ((status = e->RegisterNatives(clazz, gMethods, NELEM(gMethods))) < 0) {
        ALOGE("com.qualcomm.qti.VndFwkDetect: jni registration failure: %d", status);
        return JNI_ERR;
    }

    return JNI_VERSION_1_6;
}
