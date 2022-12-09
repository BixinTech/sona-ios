//
//  SNMCRConnection.m
//  SonaConn
//
//  Created by Insomnia on 2020/4/21.
//

#import "SNMCRConnection.h"
#import "MercuryService.h"
#import "MCRRoomSession.h"
#import "SNMacros.h"
#import "SNMsgModelHeader.h"
#import "NSDictionary+SNProtectedKeyValue.h"
#import "SRUtils.h"
#import "SNSubjectCleaner.h"
#import "SRCode.h"
#import "SNLoggerHelper.h"
#import "MCRRoomService.h"
#import "SRMessageCodec.h"

typedef NS_ENUM(NSInteger, SNMCallbackType) {
    SNMCRCallbackTypeEnter = 0,
};

typedef NS_ENUM(NSInteger, SNMMsgType) {
    SNMMsgTypeCustom = 0,
    SNMMsgTypeNoti = 1
};

@interface SNMCRConnection ()<MCRRoomSessionDelegate, MCRIMServiceDelegate, MercuryServiceDelegate>

@property(nonatomic, strong) SNConfigModel *configModel;
@property(nonatomic, strong) MCRRoomSession *roomSession;
@property(nonatomic, strong) MCRIMService *imService;
@property(nonatomic, strong) RACSubject *delegateSubject;
@property(nonatomic, strong) RACSubject *msgSubject;
@property (nonatomic, strong) RACSubject *connectionStateChanged;
@property (atomic, assign) BOOL isLeave;
@end

@implementation SNMCRConnection

- (instancetype)initWithConfigModel:(SNConfigModel *)configModel {
    self = [super init];
    if (self) {
        self.configModel = configModel;
        [[MCRRoomService shareInstance].tunnelServer addMercuryServiceDelegate:self];
    }
    return self;
}

#pragma mark - Properties

- (RACSignal *)updateConfigModel:(SNConfigModel *)configModel {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        self.configModel = configModel;
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (BOOL)isLogined {
    return self.roomSession.status == MCRRoomSessionStateInRoom;
}

- (RACSignal *)enter {
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        SN_LOG_LOCAL(@"MCR Enter, imRoomId: %@", self.configModel.roomId);
        if ([self.configModel.productConfig.imConfig.module isEqualToString:@"GROUP"]) {
            SN_LOG_LOCAL(@"MCR Enter GROUP Success, imRoomId: %@", self.configModel.roomId);
            [self.imService addDelegate:self];
            [subscriber sendNext:@(SNCodeMCREnterSuccess)];
            [subscriber sendCompleted];
            
        } else if ([self.configModel.productConfig.imConfig.module isEqualToString:@"CHATROOM"]) {
            self.roomSession.roomId = self.configModel.roomId;
            self.roomSession.uid = self.configModel.uid;
            [self.roomSession enterRoom];
            __block BOOL flag = YES;
            [self.delegateSubject subscribeNext:^(RACTuple *tuple) {
                if (flag) {
                    @strongify(self);
                    RACTupleUnpack(NSNumber *type, NSNumber *res) = tuple;
                    if ([type integerValue] == SNMCRCallbackTypeEnter) {
                        if ([res integerValue] > 0) {
                            SN_LOG_LOCAL(@"MCR Enter CHATROOM Success, imRoomId: %@", self.configModel.roomId);
                            [subscriber sendNext:@(SNCodeMCREnterSuccess)];
                        } else {
                            SN_LOG_LOCAL(@"MCR Enter CHATROOM Fail, roomId: %@, sdkCode: %@", self.configModel.roomId, res);
                            [subscriber sendError:[SRError errWithCode:SNCodeMCREnterFail]];
                        }
                        [subscriber sendCompleted];
                    }
                    flag = NO;
                }
            }];
        } else {
            [subscriber sendError:[SRError errWithCode:SNCodeMCREnterFail]];
            [subscriber sendCompleted];
        }
        return nil;
    }] retry:3];
}

- (RACSignal *)reEnter {
    return [self enter];
}

- (RACSignal *)leave {
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        SN_LOG_LOCAL(@"MCR Leave, roomId: %@", self.configModel.roomId);
        
        self.isLeave = YES;
        [[MCRRoomService shareInstance].tunnelServer removeMercuryServiceDelegate:self];
        if ([self.configModel.productConfig.imConfig.module isEqualToString:@"GROUP"]) {
            SN_LOG_LOCAL(@"MCR Leave GROUP Success, roomId: %@", self.configModel.roomId);
            [self.imService removeDelegate:self];
            [subscriber sendNext:nil];
        } else if ([self.configModel.productConfig.imConfig.module isEqualToString:@"CHATROOM"]) {
            SN_LOG_LOCAL(@"MCR Leave CHATROOM Success, roomId: %@", self.configModel.roomId);
            self.roomSession.delegate = nil;
            [self.roomSession exitRoom];
            [self.roomSession destoryRoom];
            [subscriber sendNext:nil];
        } else {
            SN_LOG_LOCAL(@"MCR Leave Success But Module(%@) Is Not Matched,", self.configModel.productConfig.imConfig.module);
            [subscriber sendNext:@(SNCodeNIMEnterSuccess)];
        }
        [SNSubjectCleaner clear:self];
        [subscriber sendCompleted];
        return nil;
    }] retry:3];
}


- (void)dealloc {
    NSLog(@"dealloc");
//    [_msgSubject sendCompleted];
}

- (RACSignal *)sendWithMsgModel:(SRMsgSendModel *)msgModel {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        if (msgModel.msgFormat == SRMsgFormatTransparent ||
            msgModel.msgFormat == SRMsgFormatText ||
            msgModel.msgFormat == SRMsgFormatEmoji ||
            msgModel.msgFormat == SRMsgFormatAck) {
            NSDictionary *dic = [SRMessageCodec encodeWithModel:msgModel];
            if (dic) {
                NSData *data = [dic mj_JSONData];
                if ([self.configModel.productConfig.imConfig.module isEqualToString:@"GROUP"]) {
                    [self.imService sendGroupMessage:data groupid:self.configModel.roomId];
                } else if ([self.configModel.productConfig.imConfig.module isEqualToString:@"CHATROOM"]) {
                    [self.roomSession sendMessage:data completion:^(MCRResponse * _Nullable resp, NSError * _Nullable error) {
                        if (!error) {
                            [subscriber sendNext:resp];
                        } else {
                            [subscriber sendError:error];
                        }
                        [subscriber sendCompleted];
                    }];
                }
                
            } else {
                [subscriber sendError:nil];
                [subscriber sendCompleted];
            }
        } else {
            [[self mediaMsgSendWithModel:msgModel] subscribeNext:^(NSDictionary *dic) {
                @strongify(self);
                NSData *data = [dic mj_JSONData];
                if ([self.configModel.productConfig.imConfig.module isEqualToString:@"GROUP"]) {
                    [self.imService sendGroupMessage:data groupid:self.configModel.roomId];
                } else if ([self.configModel.productConfig.imConfig.module isEqualToString:@"CHATROOM"]) {
                    [self.roomSession sendMessage:data completion:^(MCRResponse * _Nullable resp, NSError * _Nullable error) {
                        if (!error) {
                            [subscriber sendNext:resp];
                        } else {
                            [subscriber sendError:error];
                        }
                        [subscriber sendCompleted];
                    }];
                }
            }];
        }
        return nil;
    }];
}

- (void)sendAckMessage:(SRMsgSendModel *)msgModel {
    NSDictionary *dict = [SRMessageCodec encodeWithModel:msgModel];
    if (dict) {
        NSData *data = [dict mj_JSONData];
        [self.roomSession sendAckMessage:data];
    } else {
        SN_LOG_LOCAL(@"MCR Send Ack Fail, %@", self.configModel.roomId);
    }
}

- (RACSignal *)mediaMsgSendWithModel:(SRMsgSendModel *)model {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (![model.content isKindOfClass:[NSData class]]) {
            NSAssert(NO, @"Should be data");
            [subscriber sendError:nil];
            [subscriber sendCompleted];
        }
        NSInteger fileType = 1;
        switch (model.msgFormat) {
            case SRMsgFormatImage:
//                fileType =
                break;
            case SRMsgFormatAudio:
//                fileType =
                break;
            case SRMsgFormatVideo:
//                fileType =
                break;
            default:
                fileType = 0;
                break;
        }
        if (fileType) {
            /// upload media
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:nil];
            [subscriber sendCompleted];
        }
        return nil;
    }];
}
 
#pragma mark - Session Delegate
/// 收到IM普通消息
/// @param model 消息内容
- (void)onRoomMessage:(MCRRoomModel *)model session:(nonnull MCRRoomSession *)session {
    if (![model.roomId isEqualToString:self.configModel.roomId]) {
        return;
    }
    [self handleMessage:model type:SNMMsgTypeCustom];
}

/// 收到IM指令消息
/// @param model 消息内容
- (void)onNotificationMessage:(MCRRoomModel *)model session:(nonnull MCRRoomSession *)session {
    if (![model.roomId isEqualToString:self.configModel.roomId]) {
        return;
    }
    [self handleMessage:model type:SNMMsgTypeNoti];
}
 
/// 连接状态
/// @param state 状态
- (void)onConnectionStateChanged:(MercuryStatus)state session:(nonnull MCRRoomSession *)session {
    if (![session.roomId isEqualToString:self.configModel.roomId]) {
        return;
    }
    SRConnState srState = SRConnStateUnknown;
    
    switch (state) {
        case MercuryStatusConnected:
            srState = SRConnStateConnected;
            break;
        case MercuryStatusConnecting:
            srState = SRConnStateConnecting;
            break;
        case MercuryStatusDisconnect:
            srState = SRConnStateDisconnect;
            break;
    }
    [self.connectionStateChanged sendNext:@(srState)];
    
    if (state == MercuryStatusDisconnect) {
        SN_LOG_LOCAL(@"MCR Chatroom Disconnection, roomId: %@", self.configModel.roomId);
    }
}
 
/// 房间状态
/// @param state 状态
- (void)onRoomStateChanged:(MCRRoomSessionState)state session:(nonnull MCRRoomSession *)session {
    if (![session.roomId isEqualToString:self.configModel.roomId]) {
        return;
    }
    self.roomSession.status = state;
}
 
/// 被动退出房间
/// @param result 退出原因
- (void)onKickRoom:(NSString *)roomid result:(NSData *)result session:(nonnull MCRRoomSession *)session {
    if (![session.roomId isEqualToString:self.configModel.roomId]) {
        return;
    }
    SNMsgKickModel *model = [SNMsgKickModel new];
    model.roomId = self.configModel.roomId;
    model.msgType = @(SNMsgTypeKick).stringValue;
    [self.msgSubject sendNext:model];
}
  
/// 加入房间结果
/// @param roomid 房间ID
/// @param result nil，表示成功。
- (void)onEnterRoom:(NSString *)roomid result:(nullable NSError *)result session:(MCRRoomSession*)session {
    SN_LOG_LOCAL(@"Sona Logan: on enter room: %@", result);
    if ([roomid isEqualToString:self.configModel.roomId] && result == nil) {
        RACTuple *tuple = RACTuplePack(@(SNMCRCallbackTypeEnter), @(1));
        [self.delegateSubject sendNext:tuple];
        return;
    }
}

#pragma mark - Service Delegate

- (void)onGroupMessage:(NSData *)messageData groupid:(NSString *)groupid {
    if (![groupid isEqualToString:self.configModel.roomId]) {
        return;
    }
    MCRRoomModel *model = [MCRRoomModel new];
    model.data = messageData;
    model.roomId = self.configModel.roomId;
    [self handleMessage:model type:SNMMsgTypeCustom];
}

- (void)onTunnelStatus:(MercuryStatus)status {
    if (status == MercuryStatusConnected && self.roomSession.status == MCRRoomSessionStateLeaveRoom && !self.isLeave) {
        [[self reEnter] subscribeNext:^(id x) {
            
        }];
    }
}

#pragma mark - Handle Logic
- (void)handleMessage:(MCRRoomModel *)message type:(SNMMsgType)type {
    if (!message) {
        return;
    }
    NSError *parseError = nil;
    NSDictionary *dict = [SRMessageCodec decodeWithData:message.data error:&parseError];
    if (!dict || parseError) {
        SN_LOG_LOCAL(@"message parse fail");
        return;
    }
    SNMsgModel *model = [[SNMsgModel alloc] mj_setKeyValues:dict];
    model.isAckMsg = message.isAckMsg;
    [self.msgSubject sendNext:model];
}


- (MCRRoomSession *)roomSession {
    if (!_roomSession) {
        _roomSession = [MCRRoomSession new];
        _roomSession.delegate = self;
    }
    return _roomSession;
}

- (MCRIMService *)imService {
    if (!_imService) {
        _imService = [MercuryService shareInstance].imService;
    }
    return _imService;
}

- (RACSubject *)msgSubject {
    if (!_msgSubject) {
        _msgSubject = [RACSubject new];
    }
    return _msgSubject;
}

- (RACSubject *)delegateSubject {
    if (!_delegateSubject) {
        _delegateSubject = [RACSubject new];
    }
    return _delegateSubject;
}

- (RACSubject *)connectionStateChanged {
    if (!_connectionStateChanged) {
        _connectionStateChanged = [RACSubject new];
    }
    return _connectionStateChanged;
}

@end

