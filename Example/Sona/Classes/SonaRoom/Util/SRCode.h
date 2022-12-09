//
//  SRCode.h
//  SonaRoom
//
//  Created by Insomnia on 2020/1/8.
//

#import <Foundation/Foundation.h>

static NSString *SRErrorDomain = @"cn.bxapp.SonaRoom";


typedef NS_ENUM(NSUInteger, SRCode) {
    // 错误码 10000 - 19999
    /**
     * 房间参数错误
     */
    SRCodeParamsError = 50000,
    /**
     * 房间状态不对
     */
    SRCodeStatusError = 50001,
    /**
     * 设置管理员失败
     */
    SRCodeSetAdminError = 50002,
    /**
     * 取消设置管理员失败
     */
    SRCodeCancelAdminError = 50003,
    /**
     * 拉黑失败
     */
    SRCodeSetBlockError = 50004,
    /**
     * 取消拉黑失败
     */
    SRCodeCancelBlockError = 50005,
    /**
     * 禁言失败
     */
    SRCodeSetMsgMuteError = 50006,
    /**
     * 取消禁言失败
     */
    SRCodeCancelMsgMuteError = 50007,
    /**
     * 禁音失败
     */
    SRCodeSetStreamMuteError = 50008,
    /**
     * 取消禁音失败
     */
    SRCodeCancelStreamMuteError = 50009,
    /**
     * 踢人失败
     */
    SRCodeKickError = 50010,
    /**
     * 生产流失败
     */
    SRCodeGenerateStreamError = 50011,
    /**
     * 发送消息失败
     */
    SRCodeMsgSendError = 50012,
    /**
     * 进入房间失败
     */
    SRCodeEnterRoomError = 50013,
    /**
     * 创建房间失败
     */
    SRCodeCreateRoomError = 50014,
    /**
     * 更新房间失败
     */
    SRCodeUpdateRoomError = 50015,
    /**
     * 组件初始化失败
     */
    SRCodeSDKInitError = 50016,
    /**
     * 音频组件重连失败
     */
    SRCodeAudioReconnectError = 50017,
    /**
     * 长连组件重连失败
     */
    SRCodeConnReconnectError = 50018,
    /**
     * 离开房间失败
     */
    SRCodeLeaveRoomError = 50019,
    /**
     * 关闭房间失败
     */
    SRCodeCloseRoomError = 50020,
    /**
     * 在线人员列表错误
     */
    SRCodeOnlineListError = 50021,
    /**
     * 在线人员数量错误
     */
    SRCodeOnlineCountError = 50022,
    /**
      * 推流调用失败
      */
    SRCodePublicStreamError = 60001,
    /**
     * 开关麦克风失败
     */
    SRCodeSwitchMicError= 60002,
    /**
     * 停止推流失败
     */
    SRCodeStopPushStreamError= 60003,
    /**
     * 静音失败
     */
    SRCodeMuteStreamError = 60004
};

typedef NS_ENUM(NSInteger, SRRoomEnterResult) {
    /**
     * 请求后端接口获取SonaConfig的结果
     */
    SRRoomEnterAPISuccess   = 1000,
    SRRoomEnterAPIFail      = -1000,
    /**
     * IM 的进入结果
     */
    SRRoomEnterIMSuccess    = 2000,
    SRRoomEnterIMFail       = -2000,
    /**
     * Audio 的进入结果
     */
    SRRoomEnterAudioSuccess = 3000,
    SRRoomEnterAudioFail    = -3000,
    /**
     * Video 的进入结果
     */
    SRRoomEnterVideoSuccess = 4000,
    SRRoomEnterVideoFail    = -4000,
    /**
     * VideoChat 的进入结果
     */
    SRRoomEnterVideoChatSuccess = 5000,
    SRRoomEnterVideoChatFail    = -5000
};

typedef NS_ENUM(NSInteger, SRRoomLeaveResult) {
    /**
     * 请求后端接口的结果
     */
    SRRoomLeaveAPISuccess   = 1001,
    SRRoomLeaveAPIFail      = -1001,
    /**
     * IM 离开的结果
     */
    SRRoomLeaveIMSuccess    = 2001,
    SRRoomLeaveIMFail       = -2001,
    /**
     * Audio 离开的结果
     */
    SRRoomLeaveAudioSuccess = 3001,
    SRRoomLeaveAudioFail    = -3001,
    /**
     * Video 离开的结果
     */
    SRRoomLeaveVideoSuccess = 4001,
    SRRoomLeaveVideoFail    = -4001,
    /**
     * VideoChat 离开的结果
     */
    SRRoomLeaveVideoChatSuccess = 5001,
    SRRoomLeaveVideoChatFail    = -5001
};

typedef NS_ENUM(NSInteger,SRConnState){
    SRConnStateUnknown       = -1,
    SRConnStateConnecting    = 0,
    SRConnStateConnected     = 1,
    SRConnStateDisconnect    = 2
};

typedef NS_ENUM(NSInteger, SRRoomBeKickedType) {
    SRRoomBeKickedTypeUnknown = -1,     // 未知原因
    SRRoomBeKickedTypeBySupplier = 1,   // 被云商踢出
    SRRoomBeKickedTypeBySona = 2        // 被Sona踢出
};

@interface SRError : NSError
+ (NSError *)errWithCode:(SRCode)code;
@end
