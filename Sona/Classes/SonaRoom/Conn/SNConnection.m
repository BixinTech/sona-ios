//
//  SNConnection.m
//  SonaSDK
//
//  Created by Insomnia on 2019/12/4.
//

#import "SNConnection.h"
#import "SNMacros.h"
#import "NSDictionary+SNProtectedKeyValue.h"

#if __has_include("SonaConn.h")
#import "SonaConn.h"
#endif

@interface SNConnection()
@property(nonatomic, strong, readwrite) SNConnection *driver;
@property(nonatomic, strong) NSMutableArray <SNConnection *> *driversMArr;
@property (nonatomic, strong) SNConnection *mcrChannel;
@property (nonatomic, strong) RACSubject *mergedMsgSubject;
@property (nonatomic, strong) SNConfigModel *configModel;
@property (atomic, assign) BOOL hasLeaveRoom;
@end

@implementation SNConnection

- (instancetype)initWithConfigModel:(SNConfigModel *)configModel {
    self = [super init];
    if (self) {
        self.configModel = configModel;
        #ifdef SONACONN
        SNConnection *conn = [self createConnWithType:@"MERCURY"];
        if (conn) {
            [self.driversMArr addObject:conn];
        }
        if (self.driversMArr.count > 0) {
            self.driver = self.driversMArr[0];
        }
        [self subscribeAllMsgChannel];
        #endif
    }
    return self;
}

- (void)dealloc {
    if (_mergedMsgSubject) {
        [_mergedMsgSubject sendCompleted];
    }
}

- (SNConnection *)createConnWithType:(NSString *)type {
    SNConnection *conn = nil;
#ifdef SONACONN
    if ([type isEqualToString:@"MERCURY"]) {
        conn = [[SNMCRConnection alloc] initWithConfigModel:self.configModel];
    }
#endif
    return conn;
}

- (RACSignal *)updateConfigModel:(SNConfigModel *)configModel {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        #ifdef SONACONN
//        if (configModel.productConfig.imConfig.imTypeList.count > 0 && self.driversMArr.count > 0) {
//            if ([configModel.productConfig.imConfig.imTypeList[0] isKindOfClass:[NSDictionary class]] && [[configModel.productConfig.imConfig.imTypeList[0] snStringForKey:@"imType"] isEqualToString:@"NIM"])  {
//                if ([self.driversMArr[0] isKindOfClass:[SNNIMConnection class]]) {
//                    self.driver = self.driversMArr[0];
//                }
//                if (self.driversMArr.count > 1 && [self.driversMArr[1] isKindOfClass:[SNNIMConnection class]]) {
//                    self.driver = self.driversMArr[1];
//                    SNConnection *tmp = self.driversMArr[0];
//                    self.driversMArr[0] = self.driversMArr[1];
//                    self.driversMArr[1] = tmp;
//                }
//            }
//            if ([configModel.productConfig.imConfig.imTypeList[0] isKindOfClass:[NSDictionary class]] && [[configModel.productConfig.imConfig.imTypeList[0] snStringForKey:@"imType"] isEqualToString:@"MERCURY"]) {
//                if ([self.driversMArr[0] isKindOfClass:[SNMCRConnection class]]) {
//                    self.driver = self.driversMArr[0];
//                }
//                if (self.driversMArr.count > 1 && [self.driversMArr[1] isKindOfClass:[SNMCRConnection class]]) {
//                    self.driver = self.driversMArr[1];
//                    SNConnection *tmp = self.driversMArr[0];
//                    self.driversMArr[0] = self.driversMArr[1];
//                    self.driversMArr[1] = tmp;
//                }
//            }
//        }
//        #endif
//        NSMutableArray <RACSignal *> *mArr = [NSMutableArray new];
//        for (int i = 0; i < self.driversMArr.count; i++) {
//            [mArr addObject:[self.driversMArr[i] updateConfigModel:configModel]];
//        }
//        [[RACSignal merge:mArr] subscribeNext:^(id x) {
//        }];
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (BOOL)isLogined {
    return self.driver.isLogined;
}

- (RACSignal *)enter {
    if (self.driversMArr.count > 0) {
        self.hasLeaveRoom = false;
        self.driver = self.driversMArr[0];
        for (int i = 1; i < self.driversMArr.count; i++) {
            [[self.driversMArr[i] enter] subscribeNext:^(id x) {}];
        }
        return [self.driver enter];
    } else {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendError:nil];
            [subscriber sendCompleted];
            return nil;
        }];
    }
}

- (RACSignal *)leave {
    self.hasLeaveRoom = true;
    NSInteger connectionCount = self.driversMArr.count;
    for (int i = 0; i < connectionCount; i++) {
        SNConnection *conn = self.driversMArr[i];
        if (self.driver == conn) {
            continue;
        }
        [[self.driversMArr[i] leave] subscribeNext:^(id x) {}];
    }
    return [self.driver leave];
}

- (RACSubject *)msgSubject {
    return self.mergedMsgSubject;
}

- (RACSignal *)sendWithMsgModel:(SRMsgSendModel *)msgModel {
    return [self.driver sendWithMsgModel:msgModel];
}

- (RACSignal *)sendMsgByMCR:(SRMsgSendModel *)msgModel {
    return [self.mcrChannel sendWithMsgModel:msgModel];
}

- (void)sendAckMessage:(SRMsgSendModel *)msgModel {
    [self.mcrChannel sendAckMessage:msgModel];
}

- (RACSignal *)reEnter {
    return [self.driver reEnter];
}

- (RACSignal *)reconnWith:(SNMsgIMReconnModel *)model {
    SNConnection *conn = [self queryDriversWith:model.imType];
    if (!conn || [conn isLogined]) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendError:nil];
            [subscriber sendCompleted];
            return nil;
        }];
    }
    return [conn reEnter];
}

- (SNConnection *)queryDriversWith:(NSString *)str {
#ifdef SONACONN
    for (int i = 0;i < self.driversMArr.count; i++) {
        if ([str isEqualToString:@"MERCURY"] && [self.driversMArr[i] isKindOfClass:[SNMCRConnection class]]) {
            return self.driversMArr[i];
        }
    }
#endif
    return nil;
}

- (void)subscribeAllMsgChannel {
    [self.driversMArr.copy enumerateObjectsUsingBlock:^(SNConnection * _Nonnull conn, NSUInteger idx, BOOL * _Nonnull stop) {
        [self subscribeMsgChannel:conn];
    }];
}

- (void)subscribeMsgChannel:(SNConnection *)conn {
    @weakify(self)
    [conn.msgSubject subscribeNext:^(id x) {
        @strongify(self)
        [self.mergedMsgSubject sendNext:x];
    }];
}

#pragma mark - lazy load

- (NSMutableArray<SNConnection *> *)driversMArr {
    if (!_driversMArr) {
        _driversMArr = [NSMutableArray new];
    }
    return _driversMArr;
}

- (SNConnection *)mcrChannel {
    if (!_mcrChannel) {
        _mcrChannel = [self queryDriversWith:@"MERCURY"];
    }
    return _mcrChannel;
}

- (RACSubject *)mergedMsgSubject {
    if (!_mergedMsgSubject) {
        _mergedMsgSubject = [RACSubject subject];
    }
    return _mergedMsgSubject;
}

- (RACSubject *)connectionStateChanged {
    return [self.driver connectionStateChanged];
}

@end
