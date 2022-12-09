//
//  SRRoomConn.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/17.
//

#import "SRRoomConn.h"
#import "SNSDK.h"

#import "SRMsgSendRequestSignal.h"
#import "SRGiftRewardRequestSignal.h"
#import "NSDictionary+SNProtectedKeyValue.h"
#import "SRRoomMessageManager.h"
#import "SNLoggerHelper.h"

#if __has_include("SonaConn.h")
#import "SonaConn.h"
#endif

@interface SRRoomConn ()
@property(nonatomic, strong) SNSDK *sdk;
@property(nonatomic, strong) SNConfigModel* configModel;
@property (nonatomic, strong, readwrite) RACSubject *msgSubject;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) SRRoomMessageManager *messasgeManager;

@end

@implementation SRRoomConn
- (instancetype)initWithTuple:(RACTuple *)tuple {
    self = [SRRoomConn new];
    if (self) {
        RACTupleUnpack(SNSDK *sdk, SNConfigModel *configModel) = tuple;
        self.sdk = sdk;
        self.configModel = configModel;
        [self setupMessageManager];
        SN_LOG_LOCAL(@"Room Conn: Init Config, ExpireTime:%@ms, QueueSize:%@, Switch:%@", @(configModel.productConfig.imConfig.messageExpireTime), @(configModel.productConfig.imConfig.clientQueueSize),@(configModel.productConfig.imConfig.arrivalMessageSwitch));
        [self transparentMsg];
    }
    return self;
}

- (void)updateConfigWithModel:(SNConfigModel *)model {
    self.configModel = model;
}

- (BOOL)isLogined {
    return [self.sdk.conn isLogined];
}

- (void)transparentMsg {
    @weakify(self);
    [self.sdk.conn.msgSubject subscribeNext:^(SNMsgModel *model) {
        @strongify(self);
        // 针对ack消息，需要进一步做幂等
        if (model.isAckMsg) {
            [self checkAndTransparentMessage:model];
        } else {
            [self.msgSubject sendNext:model];
        }
    }];
}

// 长链的Ack
- (void)checkAndTransparentMessage:(SNMsgModel *)model {
    
    if (model.messageId && model.messageId.length != 0) {
        // 消息幂等
        if ([self.messasgeManager inQueue:model.messageId]) {
            // ignore message
            SN_LOG_LOCAL(@"Room Conn: hit, msgId：%@, ig", model.messageId);
        } else {
            SN_LOG_LOCAL(@"Room Conn: miss, msgId：%@, tp, enQ", model.messageId);
            [self.msgSubject sendNext:model];
            [self.messasgeManager.messageQueue enqueue:model.messageId];
        }
    } else {
        SN_LOG_LOCAL(@"Room Conn: no msgId, tp");
        [self.msgSubject sendNext:model];
    }
    
    SRMsgSendModel *ackModel = [SRMsgSendModel new];
    ackModel.uid = self.configModel.uid;
    ackModel.msgFormat = SRMsgFormatAck;
    ackModel.messageId = model.messageId;

    SN_LOG_LOCAL(@"Room Conn: ack hit, ackMsgId:%@", model.messageId);
    [self.sdk.conn sendAckMessage:ackModel];
}

- (void)stopPollingTimer {
    [self.messasgeManager stopPollingTimer];
}

- (RACSubject *)msgSubject {
    if (!_msgSubject) {
        _msgSubject = [RACSubject new];
    }
    return _msgSubject;
}

- (RACSignal *)sendMessageWithModel:(SRMsgSendModel *)model {
#ifdef SONACONN
    /// TODO:  self.configModel.productConfig.imConfig.imSendType == 2
    if (1) {
        return [self.sdk.conn sendMsgByMCR:model];
    } else {
        return [SRMsgSendRequestSignal msgSendWithModel:model roomId:self.configModel.roomId];
    }
#endif
    return [SRMsgSendRequestSignal msgSendWithModel:model roomId:self.configModel.roomId];
}

- (RACSignal *)giftRewardWithModel:(SRGiftRewardModel *)model {
    NSMutableDictionary *arg = [model mj_keyValues];
    [arg setValue:self.configModel.roomId forKey:@"roomId"];
    return [SRGiftRewardRequestSignal giftRewardWithArg:arg];
}

- (RACSignal *)reEnter {
    return [self.sdk.conn reEnter];
}

- (RACSubject *)connectionStateChanged {
    return [self.sdk.conn connectionStateChanged];
}
#pragma mark - Message Manager

- (void)setupMessageManager {
    self.messasgeManager = [SRRoomMessageManager new];
    self.messasgeManager.pollingInterval = self.configModel.productConfig.imConfig.messageExpireTime/1000;
    self.messasgeManager.messageQueueSize = self.configModel.productConfig.imConfig.clientQueueSize;
    [self.messasgeManager startPollingTimer];
}

@end
