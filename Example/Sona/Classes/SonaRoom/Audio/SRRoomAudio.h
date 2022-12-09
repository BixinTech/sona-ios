//
//  SRRoomAudio.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/14.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"

#import "SRMuteStreamUserModel.h"
#import "SRUnMuteStreamUserModel.h"
#import "SRSpecificStreamModel.h"
#import "SRSpecificNotStreamModel.h"

#import "SNConstant.h"

@class SNConfigModel;
@protocol SNAudioPrepProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface SRRoomAudio : NSObject
/**
 * 初始化方法
 * @param tuple 初始化元组， 包含sdk与config model
 * @return 实例
 */
- (instancetype)initWithTuple:(RACTuple *)tuple;

@property(nonatomic, strong, readonly) RACSubject *configSubject;

- (BOOL)beenEntered;

/**
 * 设置音频预处理类
 * @param processor 必须实现 SNAudioPrepProtocol
 * 需保证在"推拉流/媒体播放器播放"前设置，推拉流后再次设置无效
 */
- (void)setAudioPrep:(id<SNAudioPrepProtocol>)processor;

/**
 * 移除音频预处理
 */
- (void)removeAudioPrep:(id<SNAudioPrepProtocol>)processor;

/**
 * 是否只拉取当前房间内流
 * 默认为NO, 可跨房间拉流连麦
 * 设置为YES时, 只拉取本房间流
 */
@property(nonatomic, assign) BOOL isOnlyCurrent;

/*** 当使用Zego时以下参数id代表streamId， 当使用Tencent时以下流id代表accId ***/
/**
 * 开始推流
 * 返回推流 id
 */
- (RACSignal *)startPublish;

/**
 * 停止推流
 */
- (RACSignal *)stopPublish;

/**
 * 开始拉流
 * @param idStr streamId或accId
 */
- (RACSignal *)startPullWithId:(NSString *)idStr;

/**
 * 拉多条流
 * @param idArr id数组
 * @return 返回SNCode
 */
- (RACSignal *)startPullWithIdArr:(NSArray <NSString *> *)idArr;

/**
 * 停止拉流
 * @param idStr streamId或accId
 * @return 返回SNCode
 */
- (RACSignal *)stopPullWithId:(NSString *)idStr;

/**
 * 停止拉多条流
 * @param idArr id数组
 * @return 返回SNCode
 */
- (RACSignal *)stopPullWithIdArr:(NSArray <NSString *> *)idArr;

/**
 * 拉取房间内所有流
 */
- (RACSignal *)startPullAllId;

/**
 * 停止所有现正在拉取流
 */
- (RACSignal *)stopPullAllId;

/**
 * 开麦克
 * @return 返回SNCode
 */
- (RACSignal *)enableMic;

/**
 * 关麦克
 * @return 返回SNCode
 */
- (RACSignal *)unableMic;

/**
 * 使用扬声器
 */
- (RACSignal *)enableSpeaker;
/**
 *  关闭扬声器, 使用听筒
 */
- (RACSignal *)unableSpeaker;

/**
 * 静音流
 * @param idStr 流Id
 * @return 返回SNCode
 */
- (RACSignal *)muteWithId:(NSString *)idStr;

/**
 * 静音流
 * @param idArr stream 流Id数组
 */
- (RACSignal *)muteWithIdArr:(NSArray<NSString *> *)idArr;

/**
 * 取消静音流
 * @param idStr 流Id
 * @return 返回SNCode
 */
- (RACSignal *)unMuteWithId:(NSString *)idStr;

/**
 * 取消静音流
 * @param idArr stream 流Id数组
 * @return 返回SNCode
 */
- (RACSignal *)unMuteWithIdArr:(NSArray<NSString *> *)idArr;

/**
 * 网络请求
 * 根据accId静音指定用户, 后台发送消息到房间内其他用户, 同时静音
 * @param model 参数model
 */
- (RACSignal *)muteStreamUserWithModel:(SRMuteStreamUserModel *)model;

/**
 * 网络请求
 * 根据accId取消静音指定用户, 后台发送消息到房间内其他用户, 同时取消静音
 * @param model 静音用户模型
 */
- (RACSignal *)unMuteStreamUserWithModel:(SRUnMuteStreamUserModel *)model;

/**
 * 网络请求
 * 指定用户拉取指定流
 * @param model 流模型
 */
- (RACSignal *)startPullSpecificWithModel:(SRSpecificStreamModel *)model;

/**
 * 网络请求
 * 指定用户不拉取指定流
 * @param model 流模型
 */
- (RACSignal *)stopPullSpecificWithModel:(SRSpecificNotStreamModel *)model;

/**
 * 是否正在推流
 */
- (RACSignal *)isPublishingSignal;

/**
 * 是否正在拉取该流
 * @param idStr 流id
 */
- (BOOL)isPullingWithId:(NSString *)idStr;

/**
 * 获取正在拉取流的accId 集合
 */
- (NSSet <NSString *> *)pullingAccIdSet;

/**
 * 是否正在拉流
 */
- (RACSignal *)isPullingSignal;

/**
 *  推流音量回调
 */
- (RACSubject *)volumeSubject;

/**
 * 音频断开连接
 */
- (RACSubject *)disconnectSubject;

/**
 * 音频重新连接成功
 */
- (RACSubject *)reconnectSubject;

/**
 * 更新配置
 */
- (void)updateConfigWithModel:(SNConfigModel *)model;

/**
 * 他人说话光圈回调
 */
- (RACSignal *)voiceApertureSubject;

/**
 * 推流时间回调，事件参考 SNPublishEvent
 */
- (RACSubject *)publishEventCallback;

/*
 * 打开耳返(仅支持有线耳机)
 * @return 是否成功
 */
- (BOOL)enableLoopback;

/**
 * 关闭耳返(仅支持有线耳机)
 * @return 是否成功
 */
- (BOOL)disableLoopback;

/**
 * 获取采集音量，范围[0, 200]，默认100
 */
- (NSInteger)getCaptureVolume;

/**
 * 设置采集音量，范围[0, 200]
 */
- (void)setCaptureVolume:(NSInteger)volume;

/**
 * 设置耳返音量，范围[0, 200]
 */
- (void)setLoopbackVolume:(NSInteger)volume;
/**
 * 设置音效
 * @param mode 参考 SNVoiceReverbMode
 * @return 是否设置成功
 */
- (BOOL)setReverbMode:(SNVoiceReverbMode)mode;

/**
 * 设置拉流时渲染视频的 view
 * 可以为空，为空时，代表不再渲染视频
 * NOTE: 内部不会强持有该 view
 */
- (void)setStreamRenderView:(nullable UIView *)view;
/**
 * 将推流模式设置为视频模式
 * @param size 视频宽高，不能为 0
 */
- (RACSignal *)switchToVideo:(CGSize)size;

/**
 * 将推流模式设置为纯音频
 */
- (RACSignal *)switchToAudio;

/**
 * 视频模式下，第一次开始渲染视频时的回调
 */
- (RACSubject *)videoFirstRenderCallback;

- (RACSignal *)reEnter;

- (RACSubject *)onReceiveMediaSideInfo;

/**
 * 用户被踢出房间
 * @return 踢出房间的错误code
 */
- (RACSubject *)onKictOutRoom;

- (void)stopConfigPolling;

/**
 * 拉流失败，内部已经尝试重试但无法恢复，需要调用方主动发起重试。
 * @return 元组，第一个值为sdkCode，
 *              第二个值为一个json对象：streamType: 流类型(1：混流，2：单流)
 *                                 streamId: 流id
 *
 */
- (RACSubject *)onPullStreamFail;

/**
 * 拉流成功
 * @return streamId
 */
- (RACSubject *)onPullStreamSuccess;

/**
 * 推流失败，内部已经尝试重试但无法恢复，需要调用方主动发起重试。
 * @return 元组，第一个值为sdkCode，
 *              第二个值为一个json对象：streamId: 流id
 */
- (RACSubject *)onPublishStreamFail;

/**
 * 推流成功
 * @return streamId
 */
- (RACSubject *)onPublishStreamSuccess;

/** 设置上麦模式
 @param mode 模式，参见 `SRDeviceMode`，默认是 SRDeviceModeGeneral
 */
- (void)setDeviceMode:(SRDeviceMode)mode;


/**
 * 发送SEI信令消息
 */
- (void)sendSEIMessageWithDataDict:(NSDictionary *)dataDict;

@end

NS_ASSUME_NONNULL_END
