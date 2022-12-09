//
//  SNSDK.m
//  SonaSDK
//
//  Created by Insomnia on 2019/12/3.
//

#import "SNSDK.h"
#import "SNMacros.h"
#import "SRCode.h"

#define kSignalKey @"signal"
#define kCodeKey @"code"

@interface SNSDK ()
@property(nonatomic, strong, readwrite) SNConnection *conn;
@property(nonatomic, strong, readwrite) SNAudio *audio;
@end

@implementation SNSDK

- (instancetype)initWithConfigModel:(SNConfigModel *)configModel {
    return [self initWithConfigModel:configModel sdkPlugin:nil];
}

- (instancetype)initWithConfigModel:(SNConfigModel *)configModel sdkPlugin:(NSMutableDictionary<NSNumber *, id<SNSDKPluginProtocol>> *)plugin {
    return [self initWithConfigModel:configModel sdkPlugin:plugin sdkPluginClass:nil];
}

- (instancetype)initWithConfigModel:(SNConfigModel *)configModel sdkPlugin:(NSMutableDictionary<NSNumber *, id<SNSDKPluginProtocol>> *)plugin sdkPluginClass:(NSMutableDictionary<NSNumber *, Class<SNSDKPluginProtocol>> *)pluginClass {
    if (self = [super init]) {
        self.conn = [[SNConnection alloc] initWithConfigModel:configModel];
        if ([configModel.productConfig.streamConfig.type isEqualToString:@"AUDIO"]) {
            self.audio = (SNAudio *)plugin[@(SNSDKPluginTypeAudio)];
            if (!self.audio) {
                Class audioClass = pluginClass[@(SNSDKPluginTypeAudio)] ?: SNAudio.class;
                self.audio = [[audioClass alloc] initWithConfigModel:configModel];
            }
            
        }
    }
    return self;
}

- (void)dealloc {
    if (_audio) {
        _audio = nil;
    }
    if (_conn) {
        _conn = nil;
    }
}

- (RACSignal *)updateConfigModel:(SNConfigModel *)configModel {
    @weakify(self);
    return [[self.conn updateConfigModel:configModel] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [self.audio updateConfigModel:configModel];
    }];
}

- (RACSignal *)enterRoom {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSMutableArray *subSdk = @[].mutableCopy;
        RACSignal *connSignal = [self.conn enter];
        if (connSignal) {
            [subSdk addObject:@{kSignalKey:connSignal, kCodeKey:@(SRRoomEnterIMSuccess)}];
        }
        RACSignal *audioSignal = [self.audio enter];
        if (audioSignal) {
            [subSdk addObject:@{kSignalKey:audioSignal, kCodeKey:@(SRRoomEnterAudioSuccess)}];
        }

        [self execAllSignal:subSdk subscriber:subscriber];
        return nil;
    }];
}

- (RACSignal *)leaveRoom {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSMutableArray *subSdk = @[].mutableCopy;
        RACSignal *connLeaveSignal = [self.conn leave];
        if (connLeaveSignal) {
            [subSdk addObject:@{kSignalKey:connLeaveSignal, kCodeKey:@(SRRoomLeaveIMSuccess)}];
        }
        
        RACSignal *audioLeaveSignal = [self.audio leave];
        if (audioLeaveSignal) {
            [subSdk addObject:@{kSignalKey:audioLeaveSignal, kCodeKey:@(SRRoomLeaveAudioSuccess)}];
        }
        
        [self execAllSignal:subSdk subscriber:subscriber];
        
        return nil;
    }];
}

- (void)execAllSignal:(NSArray *)signals subscriber:(id<RACSubscriber>)subscriber {
    __block NSUInteger sendCount = signals.count;
    [signals enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RACSignal *signal = [obj valueForKey:kSignalKey];
        SRRoomEnterResult code = [[obj valueForKey:kCodeKey] intValue];
        [signal subscribeNext:^(id x) {
            [subscriber sendNext:@(code)];
            sendCount -= 1;
            if (sendCount <= 0) {
                [subscriber sendCompleted];
            }
        } error:^(NSError *error) {
            [subscriber sendNext:@(-code)];
            sendCount -= 1;
            if (sendCount <= 0) {
                [subscriber sendCompleted];
            }
        }];
    }];
}

@end
