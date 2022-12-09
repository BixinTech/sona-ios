//
//  SNConnection.h
//  SonaSDK
//
//  Created by Insomnia on 2019/12/4.
//

#import <Foundation/Foundation.h>
#import "SNConfigModel.h"
#import "SNMsgModel.h"
#import "SRMsgSendModel.h"
#import "SNMsgIMReconnModel.h"

@class RACSignal, RACSubject;
NS_ASSUME_NONNULL_BEGIN

@interface SNConnection : NSObject

@property(nonatomic, strong, readonly) SNConnection *driver;

@property (nonatomic, assign) BOOL isLogined;

/** 初始化配置
 @param configModel 后台下发配置，@see SNConfigModel
 */
- (instancetype)initWithConfigModel:(SNConfigModel *)configModel;

/** 更新配置
 @param configModel 配置，@see SNConfigModel
*/
- (RACSignal *)updateConfigModel:(SNConfigModel *)configModel;

/** 进入长连房间
 */
- (RACSignal *)enter;

/*
 * 离开长连房间
 */
- (RACSignal *)leave;

/**
 * @brief 未实现
 * 发送消息
 * @param msgModel 消息
 */
- (RACSignal *)sendWithMsgModel:(SRMsgSendModel *)msgModel;

- (RACSignal *)sendMsgByMCR:(SRMsgSendModel *)msgModel;

- (void)sendAckMessage:(SRMsgSendModel *)msgModel;

/**
 * 收到消息
 */
- (RACSubject *)msgSubject;

- (RACSignal *)reEnter;

- (RACSignal *)reconnWith:(SNMsgIMReconnModel *)model;

/**
 * 连接状态改变回调。
 *  返回值参见 SRConnState 枚举
 */
- (RACSubject *)connectionStateChanged;

@end

NS_ASSUME_NONNULL_END
