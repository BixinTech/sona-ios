//
//  SRRoom.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/9.
//

#import <Foundation/Foundation.h>
#import "SNSDK.h"

#import "SRRoomAdmin.h"
#import "SRRoomAudio.h"
#import "SRRoomBgm.h"
#import "SRRoomConn.h"

#import "SREnterRoomModel.h"
#import "SNConfigModel.h"

#import "SRCode.h"
#import "SNCode.h"
#import "SRRoomPluginProtocol.h"
#import "SNSDKPluginProtocol.h"

#import "SRCreateRoomRequestSignal.h"
#import "SRCloseRoomRequestSignal.h"
#import "SROpenRoomRequestSignal.h"

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SRRoom : NSObject

//// 房间消息相关操作
@property(nonatomic, strong, readonly) SRRoomConn* conn;

/// 房间流相关操作
@property(nonatomic, strong, readonly) SRRoomAudio* audio;

/// 房间bgm相关操作
@property(nonatomic, strong, readonly) SRRoomBgm *bgm;

/// 房间管理相关操作
@property(nonatomic, strong, readonly) SRRoomAdmin* admin;

/// 房间配置
@property(nonatomic, strong, readonly) SNConfigModel *configModel;

/// 设置初始 DeviceMode，默认是 SRDeviceModeGeneral
/// 如果想在推流过程中更改 deviceModel，可以通过 setDeivceMode: 来设置
@property (nonatomic, assign) SRDeviceMode defaultDeviceMode;

/** 创建房间
 @param model 参数模型。
 @return 返回创建房间结果，成功时的具体参数参见 @see SNConfigModel
*/
- (RACSignal *)createRoomWithModel:(SRCreateRoomModel *)model;

/** 进入房间
 @param model 进房数据模型， @see SREnterRoomModel
 @return 进房结果，这里会以 code 来区分房间类型(IM or Audio), @see SRRoomEnterResult
 */
- (RACSignal *)enterRoom:(SREnterRoomModel *)model;

/** 离开房间
 @return 离开房间结果，这里会以 code 来区分房间类型(IM or Audio), @see SRRoomLeaveResult
 */
- (RACSignal *)leaveRoom;

/** 开启房间
 @param model 参数模型，@see SROpenRoomModel
 */
- (RACSignal *)openRoomWithModel:(SROpenRoomModel *)model;

/** 关闭房间
 @param model 参数模型, @see SRCloseRoomModel
 */
- (RACSignal *)closeRoomWithModel:(SRCloseRoomModel *)model;

/** 用户被踢出房间
 @return 踢出房间的错误，`RACTuple`类型，元素均为 `NSNumber` 类型.
         第一个元素为被踢出的原因(枚举值，详见 @see SRRoomBeKickedType);
         第二个元素为具体的 code.
 */
- (RACSubject *)onKickOutRoom;

/** 更新配置
 @param model 配置模型，@see SNConfigModel
 */
- (void)updateConfigWithModel:(SNConfigModel *)model;

/** 注册业务plugin
 @param plugin 需要实现的协议
 */
- (void)registerWithPlugin:(id<SRRoomPluginProtocol>)plugin;

/** 注销业务plugin
 @param plugin 需要实现的协议
 */
- (void)unregisterWithPlugin:(id<SRRoomPluginProtocol>)plugin;

/** 获取业务plugin
 @param cls 类名
 @return 与 cls 匹配的 plugin
 */
- (id<SRRoomPluginProtocol>)getPluginWith:(Class)cls;

/** 注册 sdk plugin
 */
- (void)registerWithSDKPlugin:(id<SNSDKPluginProtocol>)plugin;

/** 注销sdk plugin
 */
- (void)unregisterWithSDKPlugin:(id<SNSDKPluginProtocol>)plugin;

/** 注册sdk plugin Class
 */
- (void)registerWithSDKPluginClass:(Class<SNSDKPluginProtocol>)pluginClass;

/** 注销sdk plugin Class
 */
- (void)unregisterWithSDKPluginClass:(Class<SNSDKPluginProtocol>)pluginClass;

/** 获取sdk plugin
 */
- (id<SNSDKPluginProtocol>)getSDKPluginWith:(SNSDKPluginType)pluginType;

/** 设置上麦模式，请确保在 SonaRoom 进入成功后调用（即 enterRoom 方法回调 SRRoomEnterAudioSuccess 后）
 @param mode 模式，参见 @see SRDeviceMode，默认是 SRDeviceModeGeneral
 */
- (void)setDeviceMode:(SRDeviceMode)mode;

@end

NS_ASSUME_NONNULL_END
