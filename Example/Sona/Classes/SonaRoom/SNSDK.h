//
//  SNSDK.h
//  SonaSDK
//
//  Created by Insomnia on 2019/12/3.
//

#import <Foundation/Foundation.h>
#import "SNConfigModel.h"
#import "SNMsgModelHeader.h"
#import "SNConnection.h"
#import "SNAudio.h"
#import "SNSDKPluginProtocol.h"

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SNSDK : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)new NS_UNAVAILABLE;

/**
 * 初始化SDK方法
 * @param configModel 设置model
 * @return 实例
 */
- (instancetype)initWithConfigModel:(SNConfigModel *)configModel;

- (instancetype)initWithConfigModel:(SNConfigModel *)configModel sdkPlugin:(NSMutableDictionary<NSNumber *, id<SNSDKPluginProtocol>> * _Nullable )plugin;

- (instancetype)initWithConfigModel:(SNConfigModel *)configModel sdkPlugin:(NSMutableDictionary<NSNumber *, id<SNSDKPluginProtocol>> *)plugin sdkPluginClass:(NSMutableDictionary<NSNumber *, Class<SNSDKPluginProtocol>> * _Nullable)pluginClass;

/**
* 更新配置
* @param configModel 配置
*/
- (RACSignal *)updateConfigModel:(SNConfigModel *)configModel;

/**
 * 长连模块
 */
@property(nonatomic, strong, readonly) SNConnection *conn;

/**
 * 音频
 */
@property(nonatomic, strong, readonly) SNAudio *audio;

/**
 * 进入房间
 * 该回调会触发多次，因为内部会根据配置进入多个不同的房间。
 * 房间类型参考 SRRoomEnterResult
 */
- (RACSignal *)enterRoom;

/**
 * 离开房间
 * 该回调会触发多次，因为内部会根据配置离开不同的房间。
 * 房间类型参考 SRRoomLeaveResult
 */
- (RACSignal *)leaveRoom;

@end

NS_ASSUME_NONNULL_END
