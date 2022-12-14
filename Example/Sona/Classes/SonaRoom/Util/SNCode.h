//
//  SNCode.h
//  SonaSDK
//
//  Created by Insomnia on 2020/1/7.
//

#import <Foundation/Foundation.h>
#import "SRRoomLogArgModel.h"

static NSString *SNErrorDomain = @"cn.bxapp.SonaSDK";

/**
 * Soraka Log
 */
static NSString * const SRRoomSorakaLogKey = @"SRRoomSorakaLogKey";
static NSString * const SRRoomSorakaLogReasonKey = @"SRRoomSorakaLogReasonKey";
static NSString * const SRRoomSorakaLogDescKey = @"SRRoomSorakaLogDescKey"; // TODO: Delete it!
static NSString * const SRRoomSorakaLogEventKey = @"SRRoomSorakaLogEventKey";
static NSString * const SRRoomSorakaLogSceneKey = @"SRRoomSorakaLogSceneKey";
static NSString * const SRRoomSorakaLogScene_IM = @"SRRoomSorakaLogScene_IM";
static NSString * const SRRoomSorakaLogScene_AV = @"SRRoomSorakaLogScene_AV";
static NSString * const SRRoomSorakaLogSupplier = @"cloudProvider";
static NSString * const SRRoomSorakaLogProductCode = @"snProductCode";
static NSString * const SRRoomSorakaLogSDKCode = @"sdkCode";

/* Soraka Error Code */
// Audio
static NSString * const SRRoomSorakaLogLoginFail = @"LOGIN_FAIL";
static NSString * const SRRoomSorakaLogLoginSuccess = @"LOGIN_SUCC";
static NSString * const SRRoomSorakaLogLeaveFail = @"LEAVE_FAIL";
static NSString * const SRRoomSorakaLogPushFail = @"PUSH_FAIL";
static NSString * const SRRoomSorakaLogStopPushFail = @"STOP_PUSH_FAIL";
static NSString * const SRRoomSorakaLogPullMultiStreamFail = @"PULL_MULTI_STREAM_FAIL";
static NSString * const SRRoomSorakaLogStopPullMultiStreamFail = @"STOP_PULL_MULTI_STREAM_FAIL";
static NSString * const SRRoomSorakaLogPullMixStreamFail = @"PULL_MIX_STREAM_FAIL";
static NSString * const SRRoomSorakaLogStopPullMixStreamFail = @"STOP_PULL_MIX_STREAM_FAIL";
static NSString * const SRRoomSorakaLogOpenMicFail = @"OPEN_MIC_FAIL";
static NSString * const SRRoomSorakaLogDeviceError = @"ON_DEVICE_ERROR";
static NSString * const SRRoomSorakaLogInitSdkFail = @"INIT_SDK_FAIL";
static NSString * const SRRoomSorakaLogAudioDisconnetion = @"AUDIO_ROOM_DISCONNECTION";
static NSString * const SRRoomSorakaLogPullMixedDuration = @"PULL_MIXED_DURATION";
static NSString * const SRRoomSorakaLogPullMultiDuration = @"PULL_MULTI_DURATION";
static NSString * const SRRoomSorakaLogAudioLoginDuration = @"AUDIO_LOGIN_DURATION";

// IM Code
static NSString * const SRRoomSorakaLogIMEnterTimeout = @"ENTER_FAIL_TIMEOUT";
static NSString * const SRRoomSorakaLogIMEnterFail = @"ENTER_FAILED_OTHER_REASON";
static NSString * const SRRoomSorakaLogIMExceptionConnect = @"ROOM_EXCEPTION_CONNECT";
static NSString * const SRRoomSorakaLogIMException = @"ROOM_EXCEPTION_OTHER_REASON";

// AME Code
static NSString * const SRRRoomSorakaLogAMEError = @"AME_PLAY_FAIL";

typedef NS_ENUM(NSInteger, SNCode) {
    
    /**
     * ?????????
     */
    SNCodeNoError = 0,

    /**
     * ??????SDK???????????????
     */
    SNCodeZegoInitSDKSuccess = 11001,
    /**
     * ??????SDK???????????????
     */
    SNCodeZegoInitSDKFail = -11001,
    /**
     * ??????SDK??????????????????
     */
    SNCodeZegoUnInitSDKSuccess = 11002,
    /**
     * ??????SDK??????????????????
     */
    SNCodeZegoUnInitSDKSuccessFail = -11002,
    /**
     * ??????????????????
     */
    SNCodeZegoPublishStreamSuccess = 11003,
    /**
     * ??????????????????
     */
    SNCodeZegoPublishStreamFail = -11003,
    /**
     * ????????????????????????
     */
    SNCodeZegoPublishCallbackSuccess = 11004,
    /**
     * ????????????????????????
     */
    SNCodeZegoPublishCallbackFail = -11004,
    /**
     * ????????????????????????
     */
    SNCodeZegoStopPublishSuccess = 11005,
    /**
     * ????????????????????????
     */
    SNCodeZegoStopPublishFail = -11005,
    /**
     * ?????????????????????
     */
    SNCodeZegoStartPullMultiStreamSuccess = 11006,
    /**
     * ?????????????????????
     */
    SNCodeZegoStartPullMultiStreamFail = -11006,
    /**
     * ????????????????????????
     */
    SNCodeZegoPullStreamCallbackSuccess = 11007,
    /**
     * ????????????????????????
     */
    SNCodeZegoPullStreamCallbackFail = -11007,
    /**
     * ????????????????????????
     */
    SNCodeZegoStopPullMultiStreamSuccess = 11008,
    /**
     * ????????????????????????
     */
    SNCodeZegoStopPullMultiStreamFail = -11008,
    /**
     * ????????????????????????
     */
    SNCodeZegoEnterSuccess = 11010,
    /**
     * ????????????????????????
     */
    SNCodeZegoEnterFail = -11010,
    /**
     * ????????????????????????
     */
    SNCodeZegoLeaveSuccess = 11011,
    /**
     * ????????????????????????
     */
    SNCodeZegoLeaveFail = -11011,
    /**
     * ???????????????????????????
     */
    SNCodeZegoMicSuccess = 11012,
    /**
     * ???????????????????????????
     */
    SNCodeZegoMicFail = -11012,
    /**
     * ????????????????????????
     */
    SNCodeZegoSetUserSuccess = 11013,
    /**
     * ????????????????????????
     */
    SNCodeZegoSetUserFail= -11013,
    /**
     * ????????????????????????
     */
    SNCodeZegoMuteSuccess = 11014,
    /**
     * ????????????????????????
     */
    SNCodeZegoMuteFail = -11014,
    /**
     * ??????????????????
     */
    SNCodeZegoDisconnect = -11015,
    /**
     * ???????????????????????????
     */
    SNCodeZGSpeakerSuccess = 11017,
    /**
     * ???????????????????????????
     */
    SNCodeZGSpeakerFail = -11017,
    /**
     * ????????????bgm??????
     */
    SNCodeZGBGMPlaySuccess = 11018,
    /**
      * ????????????bgm??????
      */
     SNCodeZGBGMPlayFail = -11018,
    /**
     * ??????????????????bgm??????
     */
    SNCodeZGBGMStopSuccess = 11019,
    /**
      * ??????????????????bgm??????
      */
     SNCodeZGBGMStopFail = -11019,
    /**
     * ??????????????????bgm??????
     */
    SNCodeZGBGMPauseSuccess = 11020,
    /**
      * ??????????????????bgm??????
      */
     SNCodeZGBGMPauseFail = -11020,
    /**
     * ??????????????????bgm??????
     */
    SNCodeZGBGMResumeSuccess = 11021,
    /**
     * ??????????????????bgm??????
     */
    SNCodeZGBGMResumeFail = -11021,
    /**
     * ??????????????????bgm??????
     */
    SNCodeZGBGMSetPositionSuccess = 11022,
    /**
     * ??????????????????bgm??????
     */
    SNCodeZGBGMRSetPositionFail = -11022,
    /**
     * ????????????bgm????????????
     */
    SNCodeZGBGMSetVolumeSuccess = 11023,
    /**
     * ????????????bgm????????????
     */
    SNCodeZGBGMRSetVolumeFail = -11023,
    /**
     * ?????????????????????????????????
     */
    SNCodeZGSetFrontCameraSuccess = 11024,
    /**
     * ?????????????????????????????????
     */
    SNCodeZGSetFrontCameraFail = -11024,
    /**
     * ???????????????????????????
     */
    SNCodeZGSetCameraSuccess = 11025,
    /**
     * ???????????????????????????
     */
    SNCodeZGSetCameraFail = -11025,
    /**
     * ????????????????????????????????????
     */
    SNCodeZGSetAVConfigSuccess = 11026,
    /**
     * ????????????????????????????????????
     */
    SNCodeZGSetAVConfigFail = -11026,
    /**
     * ?????????????????????
     */
    SNCodeZGPullMixStreamSuccess = 11027,
    /**
     * ?????????????????????
     */
    SNCodeZGPullMixStreamFail = -11027,
    /**
     * ???????????????????????????
     */
    SNCodeZGStopPullMixStreamSuccess = 11028,
    /**
     * ???????????????????????????
     */
    SNCodeZGStopPullMixStreamFail = -11028,
    /**
     * ????????????????????????
     */
    SNCodeTXEnterSuccess = 12010,
    /**
     * ????????????????????????
     */
    SNCodeTXEnterFail = -12010,

    /**
    * ????????????????????????
    */
    SNCodeTXLeaveSuccess = 12011,
    /**
     * ????????????????????????
     */
    SNCodeTXLeaveFail = -12011,

    /**
     * ???????????????????????????
     */
    SNCodeTXMicSuccess = 12012,
    /**
     * ???????????????????????????
     */
    SNCodeTXMicFail = -12012,
    
    /**
     * ??????????????????
     */
    SNCodeTXDisconnection = -12015,
    
    /**
     * ??????????????????
     */
    SNCodeTXPublishStreamSuccess = 12003,
    /**
     * ??????????????????
     */
    SNCodeTXPublishStreamFail = -12003,
    /**
     * ????????????????????????
     */
    SNCodeTXStopPublishSuccess = 12005,
    /**
     * ????????????????????????
     */
    SNCodeTXStopPublishFail = -12005,
    /**
     * ?????????????????????
     */
    SNCodeTXStartPullMultiStreamSuccess = 12006,
    /**
     * ?????????????????????
     */
    SNCodeTXStartPullMultiStreamFail = -12006,
    
    /**
     * ????????????????????????
     */
    SNCodeTXStopPullMultiStreamSuccess = 12008,
    /**
     * ????????????????????????
     */
    SNCodeTXStopPullMultiStreamFail = -12008,
    
    /**
     * ???????????????????????????
     */
    SNCodeTXSpeakerSuccess = 12017,
    /**
     * ???????????????????????????
     */
    SNCodeTXSpeakerFail = -12017,
    /**
     * ????????????bgm??????
     */
    SNCodeTXBGMPlaySuccess = 12018,
    /**
      * ????????????bgm??????
      */
     SNCodeTXBGMPlayFail = -12018,
    /**
     * ??????????????????bgm??????
     */
    SNCodeTXBGMStopSuccess = 12019,
    /**
      * ??????????????????bgm??????
      */
     SNCodeTXBGMStopFail = -12019,
    /**
     * ??????????????????bgm??????
     */
    SNCodeTXBGMPauseSuccess = 12020,
    /**
      * ??????????????????bgm??????
      */
     SNCodeTXBGMPauseFail = -12020,
    /**
     * ??????????????????bgm??????
     */
    SNCodeTXBGMResumeSuccess = 12021,
    /**
     * ??????????????????bgm??????
     */
    SNCodeTXBGMResumeFail = -12021,
    /**
     * ??????????????????bgm??????
     */
    SNCodeTXBGMSetPositionSuccess = 12022,
    /**
     * ??????????????????bgm??????
     */
    SNCodeTXBGMRSetPositionFail = -12022,
    /**
     * ????????????bgm????????????
     */
    SNCodeTXBGMSetVolumeSuccess = 12023,
    /**
     * ????????????bgm????????????
     */
    SNCodeTXBGMRSetVolumeFail = -12023,
    /**
     * ?????????????????????
     */
    SNCodeTXPullMixStreamSuccess = 12027,
    /**
     * ?????????????????????
     */
    SNCodeTXPullMixStreamFail = -12027,
    /**
     * ???????????????????????????
     */
    SNCodeTXStopPullMixStreamSuccess = 12028,
    /**
     * ???????????????????????????
     */
    SNCodeTXStopPullMixStreamFail = -12028,
    
    /**
     * ??????????????????
     */
    SNCodeAudioBreak = -14001,
    /**
     * ??????????????????
     */
    SNCodeAudioEnd = -14002,
    /**
     * ?????????????????????
     */
    SNCodeNIMEnterSuccess = 21002,
    /**
     * ?????????????????????
     */
    SNCodeNIMEnterFail = -21002,
    /**
     * ???????????????
     */
    SNCodeNIMIlleagl = -21003,
    
    /**
     * ??????Mercury???????????????
     */
    SNCodeMCREnterSuccess = 22002,
    /**
     * ??????Mercury???????????????
     */
    SNCodeMCREnterFail = -22002,
    /**
     * Mercury???????????????
     */
    SNCodeMCRIlleagl = -22003,
    /**
     * ?????????Device error?????????
     */
    SNCodeDeviceError = -3000,
};

typedef NS_ENUM(NSInteger, SNPublishEvent) {
    /**
     * ????????? Mic ?????????
     */
    SNPublishEventMicSeize = 1000,
    /**
     * ????????? Mic ??????????????????
     */
    SNPublishEventMicRecover = 1001
};

@interface SonaError : NSError
+ (SonaError *)errWithCode:(SNCode)code;

+ (SonaError *)errWithCode:(SNCode)code streamId:(NSString *)streamId;

+ (SonaError *)errWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo;

+ (SonaError *)errWithCode:(NSInteger)code failureReason:(NSString *)failureReason;

@end
