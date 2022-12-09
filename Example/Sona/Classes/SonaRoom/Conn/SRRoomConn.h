//
//  SRRoomConn.h
//  SonaRoom
//
//  Created by Insomnia on 2019/12/17.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import "SRMsgSendModel.h"
#import "SRGiftRewardModel.h"
#import "SRGiftRewardResModel.h"
#import "MCRMessage.h"

@class SNConfigModel;

NS_ASSUME_NONNULL_BEGIN

@interface SRRoomConn : NSObject
- (instancetype)initWithTuple:(RACTuple *)tuple;
/**
 * 透传消息接口
 * 发送: RACTuple
 * 接收方式: RACTupleUnpack(NSNumber *type, id msg) = tuple;
 */
@property (nonatomic, strong, readonly) RACSubject *msgSubject;

- (BOOL)isLogined;

/**
 * 更新配置
 */
- (void)updateConfigWithModel:(SNConfigModel *)model;

/**
 * 停止幂等轮询
 */
- (void)stopPollingTimer;

/**
 * 发送消息
 * @param model 消息模型
 * @return resp 回调
 */
- (RACSignal *)sendMessageWithModel:(SRMsgSendModel *)model;

- (RACSignal *)giftRewardWithModel:(SRGiftRewardModel *)model;

- (RACSignal *)reEnter;

- (RACSubject *)connectionStateChanged;

@end

NS_ASSUME_NONNULL_END
