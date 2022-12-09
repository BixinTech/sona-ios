//
//  SNAudio.h
//  SonaSDK
//
//  Created by Insomnia on 2019/12/4.
//

#import <Foundation/Foundation.h>
#import "SNConfigModel.h"
#import "SNSDKPluginProtocol.h"
#import "SNAudioPrepProtocol.h"
#import "SNConstant.h"
#import "SNMediaPlayer.h"


@class RACSignal, RACSubject;

@protocol SNPCMPlayer;
@protocol SNCopyrightedMediaPlayer;

NS_ASSUME_NONNULL_BEGIN

@interface SNAudio : NSObject <SNSDKPluginProtocol>

@property (nonatomic, strong, readonly) SNAudio *driver;

@property (nonatomic, strong, readonly) id<SNMediaPlayer> localPlayer;

@property (nonatomic, strong, readonly) id<SNMediaPlayer> auxPlayer;

@property (nonatomic, strong, readonly) id<SNPCMPlayer> pcmPlayer;

@property (nonatomic, strong, readonly) id<SNCopyrightedMediaPlayer> musicPlayer;

/** 初始化配置
 @param configModel 后台下发配置， @see SNConfigModel
 */
- (instancetype)initWithConfigModel:(SNConfigModel *)configModel;

/** 更新配置
 @param configModel 配置，@see SNConfigModel
 */
- (RACSignal *)updateConfigModel:(SNConfigModel *)configModel;

/** 是否在语聊房房间中
 */
- (BOOL)beenEntered;

/** 设置音频预处理类
 @param processor 必须实现 @see SNAudioPrepProtocol
 需保证在"推拉流/媒体播放器播放"前设置，推拉流后再次设置无效
 */
- (void)setAudioPrep:(id<SNAudioPrepProtocol>)processor;

/** 移除音频预处理
 */
- (void)removeAudioPrep:(id<SNAudioPrepProtocol>)processor;

/** 进入音视频房间
 */
- (RACSignal *)enter;

/** 重新进入音频房间
 */
- (RACSignal *)reEnter;

/** 离开音视频频房间
 */
- (RACSignal *)leave;

/** 开始推流
 @param idStr streamId或accId
 */
- (RACSignal *)startPublishWithId:(NSString *)idStr;

/** 停止推流
 */
- (RACSignal *)stopPublish;

/** 开始拉流
 @param idStr streamId或accId
 */
- (RACSignal *)startPullWithId:(NSString *)idStr;

/** 拉多条流
 @param idArr streamId或accIds
 */
- (RACSignal *)startPullWithIdArr:(NSArray <NSString *> *)idArr;

/** 停止拉流
 @param idStr streamId或accId
 */
- (RACSignal *)stopPullWithId:(NSString *)idStr;

/** 停止拉多条流
 @param idArr streamId或accId
 */
- (RACSignal *)stopPullWithIdArr:(NSArray <NSString *> *)idArr;

/** 拉取所有 streamId 或 accId
 */
- (RACSignal *)startPullAllId;

/** 停止所有现正在拉取流
 */
- (RACSignal *)stopPullAllId;

/** 打开麦克风
 */
- (RACSignal *)enableMic;

/** 关闭麦克风
 */
- (RACSignal *)unableMic;

/** 使用扬声器
 */
- (RACSignal *)enableSpeaker;

/** 关闭扬声器, 使用听筒
 */
- (RACSignal *)unableSpeaker;

/** 静音某条流
 @param idStr Id
 */
- (RACSignal *)muteWithId:(NSString *)idStr;

/** 静音多条流
 @param idArr streamId 或 accId
 */
- (RACSignal *)muteWithIdArr:(NSArray <NSString *> *)idArr;

/** 取消静音流
 @param idStr streamId或accId
 */
- (RACSignal *)unMuteWithId:(NSString *)idStr;

/** 取消静音多条流
 @param idArr streamId或accId数组
 */
- (RACSignal *)unMuteWithIdArr:(NSArray <NSString *> *)idArr;

/** 是否正在拉取该流
 @param idStr 流id
 */
- (BOOL)isPullingWithId:(NSString *)idStr;

/** 获取正在拉取流的accId 集合
 */
- (NSSet <NSString *> *)pullingAccIdSet;

/** 获取房间内所有流集合
*/
- (NSSet <NSString *> *)allStreamSet;

/** 是否正在拉流
 */
- (RACSignal *)isPullingSignal;

/** 是否正在推流，异步回调
 */
- (RACSignal *)isPublishingSignal;

/** 是否正在推流，同步回调
 */
- (BOOL)isPublishing;

/** 音频断开连接
 */
- (RACSubject *)disconnectSubject;

/** 音频重新连接成功
 */
- (RACSubject *)reconnectSubject;


/** 推流音量回调
 */
- (RACSubject *)volumeSubject;

/** 他人说话光圈回调
 */
- (RACSignal *)voiceApertureSubject;

/** 推流事件回调，事件参考 @see SNPublishEvent
 */
- (RACSubject *)publishEventCallback;

/** 打开耳返(仅支持有线耳机)
 */
- (BOOL)enableLoopback;

/** 关闭耳返(仅支持有线耳机)
 */
- (BOOL)disableLoopback;

/** 获取采集音量，范围[0, 200]，默认100
 */
- (NSInteger)getCaptureVolume;

/** 设置采集音量，范围[0, 200]
 */
- (void)setCaptureVolume:(NSInteger)volume;

/** 设置耳返音量，范围[0, 200]
 */
- (void)setLoopbackVolume:(NSInteger)volume;

/** 设置音效
 @param mode 参考  @see SNVoiceReverbMode
 @return 是否设置成功
 */
- (BOOL)setReverbMode:(SNVoiceReverbMode)mode;

/** 设置拉流时渲染视频的 view
    可以为空，为空时，代表不再渲染视频
    Note: 内部不会强持有该 view，外部需自己做好生命周期管理
 */
- (void)setStreamRenderView:(nullable UIView *)view;

/** 视频模式下，第一次开始渲染视频时的回调
 */
- (RACSubject *)videoFirstRenderCallback;

/** 收到 SEI 消息回调
 */
- (RACSubject *)onReceiveMediaSideInfo;

/** 发送 SEI 信令消息
 @param dataDict 消息内容
 */
- (void)sendSEIMessageWithDataDict:(NSDictionary *)dataDict;

/** 拉流失败，内部已经尝试重试但无法恢复，需要调用方主动发起重试。
 @return 元组，第一个值为sdkCode，
              第二个值为一个json对象：streamType: 流类型(1：混流，2：单流)
                                 streamId: 流id
 
 */
- (RACSubject *)onPullStreamFail;

/** 拉流成功
 @return streamId
 */
- (RACSubject *)onPullStreamSuccess;

/** 推流失败，内部已经尝试重试但无法恢复，需要调用方主动发起重试。
 @return 元组，第一个值为sdkCode，
              第二个值为一个json对象：streamId: 流id
 */
- (RACSubject *)onPublishStreamFail;

/** 推流成功
 @return streamId
 */
- (RACSubject *)onPublishStreamSuccess;

/** 拉流出错时，内部判定需要检查当前配置的回调。
 @return true
 */
- (RACSubject *)onNeedCheckConfig;

/** 被踢出房间
 */
- (RACSubject *)onKickOutRoom;

/** 上传第三方sdk log
 */
- (RACSignal *)uploadSDKLog;

/** 设置上麦模式
 @param mode 模式，参见 @see `SRDeviceMode`，默认是 SRDeviceModeGeneral
 */
- (void)setDeviceMode:(SRDeviceMode)mode;

@end

NS_ASSUME_NONNULL_END
