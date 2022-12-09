//
//  SRRoom.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/9.
//

#import "SRRoom.h"

#import "SREnterRoomRequestSignal.h"
#import "SRLeaveRoomRequestSignal.h"
#import "SRLeaveRoomModel.h"
#import "SNConfigModel.h"
#import "NSDictionary+SNProtectedKeyValue.h"
#import "SNLoggerHelper.h"

#define CHECK_PARAMS \
    if (!model) {   \
        NSAssert(NO, @"model is nil");  \
        return [RACSignal error:[NSError errorWithDomain:SRErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"params is nil"}]];   \
    }
    

@interface SRRoom ()
@property(nonatomic, strong) SNSDK *sdk;
@property(nonatomic, strong) SNConfigModel *configModel;
@property(nonatomic, strong, readwrite) RACSubject *configSubject;

@property(nonatomic, strong, readwrite) SRRoomConn *conn;
@property(nonatomic, strong, readwrite) SRRoomAudio *audio;
@property(nonatomic, strong, readwrite) SRRoomBgm *bgm;
@property(nonatomic, strong, readwrite) SRRoomAdmin *admin;

@property (nonatomic, strong) NSMutableSet <SRRoomPluginProtocol> *pluginMSet;
@property (nonatomic, strong) NSMutableSet <SRRoomPluginProtocol> *pluginClsMSet;

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, id<SNSDKPluginProtocol>> *sdkPluginMDic;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, Class<SNSDKPluginProtocol>> *sdkPluginClassMDic;

@property (atomic, assign, getter=isHasLeft) BOOL hasLeft;

@property (nonatomic, strong) RACDisposable *enterDisposable;

@property (nonatomic, copy) RACSubject *mergedOnKickOutRoom;

@end

@implementation SRRoom

- (void)setupProperties:(RACTuple *)tuple {
    self.conn = [[SRRoomConn alloc] initWithTuple:tuple];
    self.audio = [[SRRoomAudio alloc] initWithTuple:tuple];
    self.bgm = [[SRRoomBgm alloc] initWithTuple:tuple];
    self.admin = [[SRRoomAdmin alloc] initWithTuple:tuple];

    @weakify(self);
    [self.audio.configSubject subscribeNext:^(SNConfigModel *model) {
        @strongify(self);
        self.configModel = model;
        [self.conn updateConfigWithModel:model];
        [self.audio updateConfigWithModel:model];
        [self.bgm updateConfigWithModel:model];
        [self.admin updateConfigWithModel:model];
        
        @synchronized (self) {
            [self.pluginMSet enumerateObjectsUsingBlock:^(id <SRRoomPluginProtocol> obj, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(updateConfigWithModel:)]) {
                    [obj updateConfigWithModel:model];
                }
            }];
        }
    }];
}

- (dispatch_queue_t)syncQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       queue = dispatch_queue_create("com.sona.srroom", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

#pragma mark - Enter

- (RACSignal *)enterRoom:(SREnterRoomModel *)model {
    SN_LOG_H.roomId = model.roomId;
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        if (!self) return nil;
        dispatch_async([self syncQueue], ^{
            @strongify(self)
            self.hasLeft = false;
            self.enterDisposable =  [[SREnterRoomRequestSignal enterRoomWithModel:model] subscribeNext:^(SNConfigModel *configModel) {
                if (!self) return;
                dispatch_async([self syncQueue], ^{
                    @strongify(self)
                    if (self.isHasLeft) {
                        SN_LOG_LOCAL(@"sona/enter success, but user has left room");
                        return;
                    }
                    SN_LOG_H.roomId = configModel.roomId;
                    configModel.uid = model.uid;
                    [subscriber sendNext:RACTuplePack(@(SRRoomEnterAPISuccess), configModel)];
                    SN_LOG_LOCAL(@"sona/enter success, will init sdk");
                    RACSignal *innerSignal = [[self attachConfigModelWithModel:configModel] flattenMap:^RACStream *(SNConfigModel *configModel) {
                        @strongify(self)
                        return [[self createSdkWithModel:configModel] flattenMap:^RACStream *(id value) {
                            @strongify(self)
                            RACTuple *tuple = RACTuplePack(self.sdk, configModel);
                            [self.configSubject sendNext:tuple];
                            [self handleMsg];
                            [self setupProperties:RACTuplePack(self.sdk, self.configModel)];
                            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> innerSubscriber) {
                                @strongify(self)
                                [[self.sdk enterRoom] subscribeNext:^(id x) {
                                    @strongify(self)
                                    SN_LOG_LOCAL(@"enter %@ success", x);
                                    [innerSubscriber sendNext:RACTuplePack(x, self.configModel)];
                                } error:^(NSError *error) {
                                    SN_LOG_LOCAL(@"enter error: %@", error);
                                    [innerSubscriber sendError:error];
                                } completed:^{
                                    SN_LOG_LOCAL(@"enter completed");
                                    [innerSubscriber sendCompleted];
                                }];
                                return nil;
                            }];
                        }];
                    }];
                    [[RACScheduler scheduler] performAsCurrentScheduler:^{
                        // 透传
                        [innerSignal subscribeNext:^(id x) {
                            [subscriber sendNext:x];
                        } error:^(NSError *error) {
                            [subscriber sendError:error];
                        } completed:^{
                            [subscriber sendCompleted];
                        }];
                    }];
                });
            } error:^(NSError *error) {
                SN_LOG_LOCAL(@"sona/enter fial, error:%@", error);
                [subscriber sendNext:RACTuplePack(@(SRRoomEnterAPIFail), error)];
                [subscriber sendCompleted];
            }];
            SN_LOG_LOCAL(@"enter disposable, %@", self.enterDisposable);
        });
        return nil;
    }];
}

- (RACSignal *)attachConfigModelWithModel:(SNConfigModel *)configModel {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        [configModel.attMDic setValue:@(true) forKey:@"env"];
        
        if (configModel.guestUid.length > 0) {
            [configModel.attMDic setValue:configModel.guestUid forKey:@"uid"];
        }
        
        NSUInteger appID = [[configModel.productConfig.streamConfig.appInfo snStringForKey:@"appId"] integerValue];
        
        if ([configModel.productConfig.streamConfig.supplier isEqualToString:SN_STREAM_SUPPLIER_ZEGO]) {
            NSString *sigString = [configModel.productConfig.streamConfig.appInfo snStringForKey:@"appSign"];
            NSArray <NSString *> *arr = [sigString componentsSeparatedByString:@","];
            NSUInteger len =  arr.count;
            Byte byteArr[10000] = {0};
            for (int i = 0; i < len; i++) {
                int num = [self numberWithHexString:arr[i]];
                byteArr[i] = num;
            }
            
            if (arr.count < 32) {
                [subscriber sendError:[SRError errWithCode:SRCodeEnterRoomError]];
                [subscriber sendCompleted];
                
            } else {
                NSData *sig = [[NSData alloc] initWithBytes:byteArr length:len];
                [configModel.attMDic setValue:sig forKey:@"sig"];
            }
        } else if ([configModel.productConfig.streamConfig.supplier isEqualToString:SN_STREAM_SUPPLIER_TENCENT]) {
            NSString *sigString = [configModel.productConfig.streamConfig.appInfo snStringForKey:@"appSign"];
            [configModel.attMDic setValue:sigString forKey:@"sig"];
        } 
        [configModel.attMDic setValue:@(appID) forKey:@"appId"];
        [configModel.attMDic setValue:@(self.defaultDeviceMode) forKey:@"deviceMode"];
        self.configModel = configModel;
        [subscriber sendNext:configModel];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal *)createSdkWithModel:(SNConfigModel *)model {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self)
        self.sdk = [[SNSDK alloc] initWithConfigModel:model sdkPlugin:self.sdkPluginMDic sdkPluginClass:self.sdkPluginClassMDic];
        [[self.sdk.audio.onKickOutRoom takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
            RACTuple *tuple =  RACTuplePack(@(SRRoomBeKickedTypeBySupplier), x);
            [self.mergedOnKickOutRoom sendNext:tuple];
        }];
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        return nil;
    }];
}

#pragma mark - Leave

- (RACSignal *)leaveRoom {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        if (!self) return nil;
        dispatch_async([self syncQueue], ^{
            if (self.hasLeft) {
                SN_LOG_LOCAL(@"Sona Logan: already left");
                return;
            }
            SN_LOG_LOCAL(@"dispose enterDisposable: %@", self.enterDisposable);
            [SN_LOG_H clearData];
            [self.enterDisposable dispose];
            [self.conn stopPollingTimer];
            [self.audio stopConfigPolling];
            [self unregisterAllPlugin];
            self.hasLeft = true;
            SRLeaveRoomModel *model = [SRLeaveRoomModel new];
            model.uid = self.configModel.uid;
            if (self.configModel && self.configModel.roomId) {
                model.roomId = self.configModel.roomId;
                [[SRLeaveRoomRequestSignal leaveRoomWithModel:model] subscribeNext:^(id x) {
                    SN_LOG_LOCAL(@"sona/leave success");
                    [subscriber sendNext:RACTuplePack(@(SRRoomLeaveAPISuccess), x)];
                } error:^(NSError *error) {
                    SN_LOG_LOCAL(@"sona/leave fail, %@",error);
                    [subscriber sendNext:RACTuplePack(@(SRRoomLeaveAPIFail), error)];
                }];
            } else {
                SN_LOG_LOCAL(@"sona/leave fail, roomId not exist");
            }
            
            if (self.sdk) {
                [[self.sdk leaveRoom] subscribeNext:^(id x) {
                    SN_LOG_LOCAL(@"sona leave success, type:%@", x);
                    [subscriber sendNext:RACTuplePack(x, @"")];
                } error:^(NSError *error) {
                    SN_LOG_LOCAL(@"sona leave fail, error:%@", error);
                    [subscriber sendError:error];
                } completed:^{
                    SN_LOG_LOCAL(@"sona leave completed");
                    [subscriber sendCompleted];
                }];
            } else {
                SN_LOG_LOCAL(@"sona sdk not init, do nothing");
            }
        });
        return nil;
    }];
}

- (RACSubject *)onKickOutRoom {
    return self.mergedOnKickOutRoom;
}

#pragma mark - Create

- (RACSignal *)createRoomWithModel:(SRCreateRoomModel *)model {
    CHECK_PARAMS
    return [SRCreateRoomRequestSignal createRoomWithModel:model];
}

#pragma mark - Open

- (RACSignal *)openRoomWithModel:(SROpenRoomModel *)model {
    CHECK_PARAMS
    return [SROpenRoomRequestSignal openRoomWithModel:model];
}

#pragma mark - Close

- (RACSignal *)closeRoomWithModel:(SRCloseRoomModel *)model {
    if (!model) {
        NSAssert(NO, @"model is nil");
        return [RACSignal error:[NSError errorWithDomain:SRErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"params is nil"}]];
    }
    return  [RACSignal merge:@[[self leaveRoom], [SRCloseRoomRequestSignal closeRoomWithModel:model]]];
}

#pragma mark - Plugin

- (void)registerWithPlugin:(id<SRRoomPluginProtocol>)plugin {
    if (!plugin) {
        return;
    }
    @synchronized (self) {
        if ([self.pluginMSet containsObject:plugin] || [self.pluginClsMSet containsObject:[plugin class]]) {
            return;
        }
        
        [self.pluginMSet addObject:plugin];
        [self.pluginClsMSet addObject:[plugin class]];
        
        if ([plugin respondsToSelector:@selector(registerSuccessWithRoom:)]) {
            [plugin registerSuccessWithRoom:self];
        }
    }
}

- (void)unregisterWithPlugin:(id<SRRoomPluginProtocol>)plugin {
    if (!plugin) {
        return;
    }
    
    @synchronized (self) {
        [self.pluginMSet removeObject:plugin];
        [self.pluginClsMSet removeObject:[plugin class]];
        
        if ([plugin respondsToSelector:@selector(didUnregistered)]) {
            [plugin didUnregistered];
        }
    }
}

- (void)unregisterAllPlugin {
    @synchronized (self) {
        for (int i = 0; i < self.pluginMSet.count; i++) {
            id plugin = self.pluginMSet.anyObject;
            [self unregisterWithPlugin:plugin];
        }
    }
}

- (id<SRRoomPluginProtocol>)getPluginWith:(Class)cls {
    __block id<SRRoomPluginProtocol> result = nil;
    @synchronized (self) {
        if (![self.pluginClsMSet containsObject:cls]) {
            return result;
        }
        
        [self.pluginMSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:cls]) {
                result = obj;
                *stop = true;
            }
        }];
    }
    return result;
}

#pragma mark - SDK Plugin

- (void)registerWithSDKPlugin:(id<SNSDKPluginProtocol>)plugin {
    if (!plugin) {
        return;
    }
    
    if ([self.sdkPluginMDic.allKeys containsObject:@([plugin pluginType])]) {
        return;
    }
    
    [self.sdkPluginMDic setObject:plugin forKey:@([plugin pluginType])];
}

- (void)unregisterWithSDKPlugin:(id<SNSDKPluginProtocol>)plugin {
    if (!plugin) {
        return;
    }
    
    [self.sdkPluginMDic removeObjectForKey:@([plugin pluginType])];
}

- (void)registerWithSDKPluginClass:(Class<SNSDKPluginProtocol>)pluginClass {
    if (!pluginClass) {
        return;
    }
    id instance = [[pluginClass.class alloc] init];
    if ([self.sdkPluginClassMDic.allKeys containsObject:@([instance pluginType])]) {
        return;
    }
    
    [self.sdkPluginClassMDic setObject:pluginClass forKey:@([instance pluginType])];
}

- (void)unregisterWithSDKPluginClass:(Class<SNSDKPluginProtocol>)pluginClass {
    if (!pluginClass) {
        return;
    }
    id instance = [[pluginClass.class alloc] init];
    [self.sdkPluginClassMDic removeObjectForKey:@([instance pluginType])];
}

- (id<SNSDKPluginProtocol>)getSDKPluginWith:(SNSDKPluginType)pluginType {
    if (![self.sdkPluginMDic.allKeys containsObject:@(pluginType)]) {
        return nil;
    }
    
    return [self.sdkPluginMDic objectForKey:@(pluginType)];
}

#pragma mark -  handle

- (void)handleMsg {
    @weakify(self);
    [self.sdk.conn.msgSubject subscribeNext:^(SNMsgModel *msgModel) {
        @strongify(self);
        if ([msgModel.msgType integerValue] == SNMsgTypeClose) {
            [self handleCloseMsgWithModel:msgModel];
        }
    }];
}

- (void)handleCloseMsgWithModel:(SNMsgModel *)model {
    if ([model.roomId isEqualToString:self.configModel.roomId]) {
        @weakify(self)
        [[self leaveRoom] subscribeNext:^(RACTuple *tuple) {
            @strongify(self)
            RACTupleUnpack(NSNumber *type, __unused NSNumber *code) = tuple;
            // 这里的判断无特殊意义，只是为了防止多次触发回调。
            if ([type intValue] == SRRoomLeaveIMSuccess) {
                SN_LOG_LOCAL(@"Sona Logan: be kicked out, callback succ");
                RACTuple *tuple = RACTuplePack(@(SRRoomBeKickedTypeBySona),@(SNMsgTypeClose));
                [self.onKickOutRoom sendNext:tuple];
            }
        }];
    }
}

- (void)handleKickMsgWithModel:(SNMsgKickModel *)model {
    if ([model.roomId isEqualToString:self.configModel.roomId] && [model.uid isEqualToString:self.configModel.uid]) {
        [[self leaveRoom] subscribeNext:^(id x) {
        }];
    }
}

- (int)numberWithHexString:(NSString *)hexString{
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    int hexNumber;
    sscanf(hexChar, "%x", &hexNumber);
    return hexNumber;
}

- (void)updateConfigWithModel:(SNConfigModel *)model {
    self.configModel = model;
}

- (void)setDeviceMode:(SRDeviceMode)mode {
    NSAssert(self.audio != nil, @"请在 SonaRoom enterRoom 回调 SRRoomEnterAudioSuccess 后调用");
    [self.audio setDeviceMode:mode];
}

#pragma mark Properties

- (RACSubject *)configSubject {
    if (!_configSubject) {
        _configSubject = [RACSubject new];
    }
    return _configSubject;
}

- (NSMutableSet <SRRoomPluginProtocol> *)pluginMSet {
    if (!_pluginMSet) {
        _pluginMSet = [NSMutableSet<SRRoomPluginProtocol> new];
    }
    return _pluginMSet;
}

- (NSMutableSet<SRRoomPluginProtocol> *)pluginClsMSet {
    if (!_pluginClsMSet) {
        _pluginClsMSet = [NSMutableSet<SRRoomPluginProtocol> new];
    }
    return _pluginClsMSet;
}

- (NSMutableDictionary<NSNumber *, id<SNSDKPluginProtocol>> *)sdkPluginMDic {
    if (!_sdkPluginMDic) {
        _sdkPluginMDic = [NSMutableDictionary<NSNumber *, id<SNSDKPluginProtocol>> dictionary];
    }
    return _sdkPluginMDic;
}

- (NSMutableDictionary<NSNumber *, Class<SNSDKPluginProtocol>> *)sdkPluginClassMDic {
    if (!_sdkPluginClassMDic) {
        _sdkPluginClassMDic = [NSMutableDictionary<NSNumber *, Class<SNSDKPluginProtocol>> dictionary];
    }
    return _sdkPluginClassMDic;
}

- (RACSubject *)mergedOnKickOutRoom {
    if (!_mergedOnKickOutRoom) {
        _mergedOnKickOutRoom = [RACSubject subject];
    }
    return _mergedOnKickOutRoom;
}

- (void)dealloc {
    SN_LOG_LOCAL(@"SRRoom dealloc");
}


@end
