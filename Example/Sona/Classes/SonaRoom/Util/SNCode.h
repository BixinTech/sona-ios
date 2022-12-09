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
     * 无错误
     */
    SNCodeNoError = 0,

    /**
     * 即构SDK初始化成功
     */
    SNCodeZegoInitSDKSuccess = 11001,
    /**
     * 即构SDK初始化失败
     */
    SNCodeZegoInitSDKFail = -11001,
    /**
     * 即构SDK反初始化成功
     */
    SNCodeZegoUnInitSDKSuccess = 11002,
    /**
     * 即构SDK反初始化失败
     */
    SNCodeZegoUnInitSDKSuccessFail = -11002,
    /**
     * 即构推流成功
     */
    SNCodeZegoPublishStreamSuccess = 11003,
    /**
     * 即构推流失败
     */
    SNCodeZegoPublishStreamFail = -11003,
    /**
     * 即构推流回调成功
     */
    SNCodeZegoPublishCallbackSuccess = 11004,
    /**
     * 即构推流回调失败
     */
    SNCodeZegoPublishCallbackFail = -11004,
    /**
     * 即构停止推流成功
     */
    SNCodeZegoStopPublishSuccess = 11005,
    /**
     * 即构停止推流失败
     */
    SNCodeZegoStopPublishFail = -11005,
    /**
     * 即构拉多流成功
     */
    SNCodeZegoStartPullMultiStreamSuccess = 11006,
    /**
     * 即构拉多流失败
     */
    SNCodeZegoStartPullMultiStreamFail = -11006,
    /**
     * 即构拉流回调成功
     */
    SNCodeZegoPullStreamCallbackSuccess = 11007,
    /**
     * 即构拉流回调失败
     */
    SNCodeZegoPullStreamCallbackFail = -11007,
    /**
     * 即构停止拉流成功
     */
    SNCodeZegoStopPullMultiStreamSuccess = 11008,
    /**
     * 即构停止拉流失败
     */
    SNCodeZegoStopPullMultiStreamFail = -11008,
    /**
     * 即构登录房间成功
     */
    SNCodeZegoEnterSuccess = 11010,
    /**
     * 即构登录房间失败
     */
    SNCodeZegoEnterFail = -11010,
    /**
     * 即构退出房间成功
     */
    SNCodeZegoLeaveSuccess = 11011,
    /**
     * 即构退出房间失败
     */
    SNCodeZegoLeaveFail = -11011,
    /**
     * 即构操作麦克风成功
     */
    SNCodeZegoMicSuccess = 11012,
    /**
     * 即构操作麦克风失败
     */
    SNCodeZegoMicFail = -11012,
    /**
     * 即构设置用户成功
     */
    SNCodeZegoSetUserSuccess = 11013,
    /**
     * 即构设置用户失败
     */
    SNCodeZegoSetUserFail= -11013,
    /**
     * 即构操作音量成功
     */
    SNCodeZegoMuteSuccess = 11014,
    /**
     * 即构操作音量成功
     */
    SNCodeZegoMuteFail = -11014,
    /**
     * 即构断开连接
     */
    SNCodeZegoDisconnect = -11015,
    /**
     * 即构切换扬声器成功
     */
    SNCodeZGSpeakerSuccess = 11017,
    /**
     * 即构切换扬声器失败
     */
    SNCodeZGSpeakerFail = -11017,
    /**
     * 即构播放bgm完成
     */
    SNCodeZGBGMPlaySuccess = 11018,
    /**
      * 即构播放bgm失败
      */
     SNCodeZGBGMPlayFail = -11018,
    /**
     * 即构停止播放bgm成功
     */
    SNCodeZGBGMStopSuccess = 11019,
    /**
      * 即构停止播放bgm失败
      */
     SNCodeZGBGMStopFail = -11019,
    /**
     * 即构暂停播放bgm成功
     */
    SNCodeZGBGMPauseSuccess = 11020,
    /**
      * 即构停止播放bgm失败
      */
     SNCodeZGBGMPauseFail = -11020,
    /**
     * 即构继续播放bgm成功
     */
    SNCodeZGBGMResumeSuccess = 11021,
    /**
     * 即构继续播放bgm失败
     */
    SNCodeZGBGMResumeFail = -11021,
    /**
     * 即构继续播放bgm成功
     */
    SNCodeZGBGMSetPositionSuccess = 11022,
    /**
     * 即构继续播放bgm失败
     */
    SNCodeZGBGMRSetPositionFail = -11022,
    /**
     * 即构设置bgm音量成功
     */
    SNCodeZGBGMSetVolumeSuccess = 11023,
    /**
     * 即构设置bgm音量失败
     */
    SNCodeZGBGMRSetVolumeFail = -11023,
    /**
     * 即构设置前置摄像头成功
     */
    SNCodeZGSetFrontCameraSuccess = 11024,
    /**
     * 即构设置前置摄像头失败
     */
    SNCodeZGSetFrontCameraFail = -11024,
    /**
     * 即构设置摄像头成功
     */
    SNCodeZGSetCameraSuccess = 11025,
    /**
     * 即构设置摄像头失败
     */
    SNCodeZGSetCameraFail = -11025,
    /**
     * 即构设置视频推流信息成功
     */
    SNCodeZGSetAVConfigSuccess = 11026,
    /**
     * 即构设置视频推流信息失败
     */
    SNCodeZGSetAVConfigFail = -11026,
    /**
     * 即构拉混流成功
     */
    SNCodeZGPullMixStreamSuccess = 11027,
    /**
     * 即构拉混流失败
     */
    SNCodeZGPullMixStreamFail = -11027,
    /**
     * 即构停止拉混流成功
     */
    SNCodeZGStopPullMixStreamSuccess = 11028,
    /**
     * 即构停止拉混流失败
     */
    SNCodeZGStopPullMixStreamFail = -11028,
    /**
     * 腾讯登录房间成功
     */
    SNCodeTXEnterSuccess = 12010,
    /**
     * 腾讯登录房间失败
     */
    SNCodeTXEnterFail = -12010,

    /**
    * 腾讯登出房间成功
    */
    SNCodeTXLeaveSuccess = 12011,
    /**
     * 腾讯登出房间失败
     */
    SNCodeTXLeaveFail = -12011,

    /**
     * 腾讯操作麦克风成功
     */
    SNCodeTXMicSuccess = 12012,
    /**
     * 腾讯操作麦克风失败
     */
    SNCodeTXMicFail = -12012,
    
    /**
     * 腾讯房间断链
     */
    SNCodeTXDisconnection = -12015,
    
    /**
     * 腾讯推流成功
     */
    SNCodeTXPublishStreamSuccess = 12003,
    /**
     * 腾讯推流失败
     */
    SNCodeTXPublishStreamFail = -12003,
    /**
     * 腾讯停止推流成功
     */
    SNCodeTXStopPublishSuccess = 12005,
    /**
     * 腾讯停止推流失败
     */
    SNCodeTXStopPublishFail = -12005,
    /**
     * 腾讯拉多流成功
     */
    SNCodeTXStartPullMultiStreamSuccess = 12006,
    /**
     * 腾讯拉多流失败
     */
    SNCodeTXStartPullMultiStreamFail = -12006,
    
    /**
     * 腾讯停止拉流成功
     */
    SNCodeTXStopPullMultiStreamSuccess = 12008,
    /**
     * 腾讯停止拉流失败
     */
    SNCodeTXStopPullMultiStreamFail = -12008,
    
    /**
     * 腾讯切换扬声器成功
     */
    SNCodeTXSpeakerSuccess = 12017,
    /**
     * 腾讯切换扬声器失败
     */
    SNCodeTXSpeakerFail = -12017,
    /**
     * 腾讯播放bgm完成
     */
    SNCodeTXBGMPlaySuccess = 12018,
    /**
      * 腾讯播放bgm失败
      */
     SNCodeTXBGMPlayFail = -12018,
    /**
     * 腾讯停止播放bgm成功
     */
    SNCodeTXBGMStopSuccess = 12019,
    /**
      * 腾讯停止播放bgm失败
      */
     SNCodeTXBGMStopFail = -12019,
    /**
     * 腾讯暂停播放bgm成功
     */
    SNCodeTXBGMPauseSuccess = 12020,
    /**
      * 腾讯停止播放bgm失败
      */
     SNCodeTXBGMPauseFail = -12020,
    /**
     * 腾讯继续播放bgm成功
     */
    SNCodeTXBGMResumeSuccess = 12021,
    /**
     * 腾讯继续播放bgm失败
     */
    SNCodeTXBGMResumeFail = -12021,
    /**
     * 腾讯继续播放bgm成功
     */
    SNCodeTXBGMSetPositionSuccess = 12022,
    /**
     * 腾讯继续播放bgm失败
     */
    SNCodeTXBGMRSetPositionFail = -12022,
    /**
     * 腾讯设置bgm音量成功
     */
    SNCodeTXBGMSetVolumeSuccess = 12023,
    /**
     * 腾讯设置bgm音量失败
     */
    SNCodeTXBGMRSetVolumeFail = -12023,
    /**
     * 腾讯拉混流成功
     */
    SNCodeTXPullMixStreamSuccess = 12027,
    /**
     * 腾讯拉混流失败
     */
    SNCodeTXPullMixStreamFail = -12027,
    /**
     * 腾讯停止拉混流成功
     */
    SNCodeTXStopPullMixStreamSuccess = 12028,
    /**
     * 腾讯停止拉混流失败
     */
    SNCodeTXStopPullMixStreamFail = -12028,
    
    /**
     * 音频卡顿开始
     */
    SNCodeAudioBreak = -14001,
    /**
     * 音频卡顿结束
     */
    SNCodeAudioEnd = -14002,
    /**
     * 进入聊天室成功
     */
    SNCodeNIMEnterSuccess = 21002,
    /**
     * 进入聊天室失败
     */
    SNCodeNIMEnterFail = -21002,
    /**
     * 聊天室异常
     */
    SNCodeNIMIlleagl = -21003,
    
    /**
     * 进入Mercury聊天室成功
     */
    SNCodeMCREnterSuccess = 22002,
    /**
     * 进入Mercury聊天室失败
     */
    SNCodeMCREnterFail = -22002,
    /**
     * Mercury聊天室异常
     */
    SNCodeMCRIlleagl = -22003,
    /**
     * 设备报Device error错误码
     */
    SNCodeDeviceError = -3000,
};

typedef NS_ENUM(NSInteger, SNPublishEvent) {
    /**
     * 推流中 Mic 被抢占
     */
    SNPublishEventMicSeize = 1000,
    /**
     * 推流中 Mic 被抢占后恢复
     */
    SNPublishEventMicRecover = 1001
};

@interface SonaError : NSError
+ (SonaError *)errWithCode:(SNCode)code;

+ (SonaError *)errWithCode:(SNCode)code streamId:(NSString *)streamId;

+ (SonaError *)errWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo;

+ (SonaError *)errWithCode:(NSInteger)code failureReason:(NSString *)failureReason;

@end
