//
//  SNConfigPollingService.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/8/18.
//

#import "SNConfigPollingService.h"
#import "ReactiveCocoa.h"
#import "SRSyncConfigModel.h"
#import "SRSyncConfigRequest.h"
#import "SNLoggerHelper.h"


#define MAX_RETRY_COUNT 2

@interface SNConfigPollingService ()

@property (atomic, assign) BOOL shouldStop;

@property (atomic, assign, getter=isPolling) BOOL polling;

@property (nonatomic, assign) NSInteger retryCount;

@property (nonatomic, assign) BOOL infinitePolling;
    
@end

@implementation SNConfigPollingService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.retryCount = 0;
    }
    return self;
}

- (void)startPolling:(BOOL)infinite {
    if (self.infinitePolling) {
        SN_LOG_LOCAL(@"Sona Logan: Polling");
        return;
    }
    self.infinitePolling = infinite;
    self.shouldStop = false;
    [self execPolling];
    SN_LOG_LOCAL(@"Sona Logan: PL Config S,Infinite %@", @(infinite));
}

- (void)stopPolling {
    self.shouldStop = true;
    self.retryCount = 0;
    self.polling = false;
    self.infinitePolling = false;
    SN_LOG_LOCAL(@"Sona Logan: PL Config E");
}

- (void)execPolling {
    if (!self.targetRoomId || self.targetRoomId.length <= 0) {
        return;
    }
    if (self.shouldStop) {
        return;
    }
    if (self.isPolling) {
        return;
    }
    self.polling = true;
    
    [[self fetchConfig] subscribeNext:^(id x) {
        !self.onGetConfig ? : self.onGetConfig(x, nil);
        self.polling = false;
        if (self.infinitePolling) {
            [self delayFetchConfig];
        }
    } error:^(NSError *error) {
        self.polling = false;
        if (error && !self.infinitePolling) {
            if (self.retryCount < MAX_RETRY_COUNT) {
                self.retryCount++;
                [self delayFetchConfig];
            } else {
                !self.onGetConfig ? : self.onGetConfig(nil, error);
                self.retryCount = 0;
            }
        }
        if (self.infinitePolling) {
            [self delayFetchConfig];
        }
    }];
}

- (void)delayFetchConfig {
    @weakify(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        [self execPolling];
    });
}

- (RACSignal *)fetchConfig {
    return [SRSyncConfigRequest syncConfigWithRoomId:self.targetRoomId];
}

@end
