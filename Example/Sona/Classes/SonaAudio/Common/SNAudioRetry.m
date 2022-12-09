//
//  SNAudioRetry.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/11/29.
//

#import "SNAudioRetry.h"
#import "SNAudio.h"
#import "NSDictionary+SNProtectedKeyValue.h"
#import "ReactiveCocoa.h"
#import "SNLoggerHelper.h"

#define MAX_RETRY_COUNT 3

@interface SNAudioRetry ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *pullMap;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *publishMap;

@property (nonatomic, weak) SNAudio *audio;

@end

@implementation SNAudioRetry

- (instancetype)initWithAudio:(SNAudio *)audio {
    self = [super init];
    if (self) {
        self.audio = audio;
        self.pullMap = [NSMutableDictionary new];
        self.publishMap = [NSMutableDictionary new];
        [self observeEvent];
    }
    return self;
}

- (void)observeEvent {
    [self observePullEvent];
    [self observePublishEvent];
}

#pragma mark - Pull Event

- (void)observePullEvent {
    @weakify(self)
    [self.audio.onPullStreamSuccess subscribeNext:^(NSString *streamId) {
        @strongify(self)
        @synchronized (self) {
            SN_LOG_LOCAL(@"Sona Logan: pull success: %@", streamId);
            [self.pullMap removeObjectForKey:streamId];
        }
    }];
}

- (BOOL)checkAndRetryToPullStream:(NSString *)streamId isMixed:(BOOL)isMixed {
    @synchronized (self) {
        NSInteger retryCount = [self.pullMap snIntegerForKey:streamId];
        if (retryCount < MAX_RETRY_COUNT) {
            // 没有超过重试最大次数，重试
            SN_LOG_LOCAL(@"Sona Logan: will retry pull: %@", streamId);
            retryCount += 1;
            [self.pullMap setValue:@(retryCount) forKey:streamId];
            [self pullStream:streamId isMixed:isMixed];
            return true;
        } else {
            // 超过了最大重试次数，不再重试
            SN_LOG_LOCAL(@"Sona Logan: stop retry pull: %@", streamId);
            @synchronized (self) {
                [self.pullMap removeObjectForKey:streamId];
            }
            return false;
        }
    }
}

- (void)pullStream:(NSString *)streamId isMixed:(BOOL)isMixed {
    if (!self.audio) {
        return;
    }
    if (isMixed) {
        [[self.audio startPullAllId] subscribeNext:^(id x) {
            SN_LOG_LOCAL(@"Sona Logan: retry to pull mixed: %@", streamId);
        }];
    } else {
        [[self.audio startPullWithId:streamId] subscribeNext:^(id x) {
            SN_LOG_LOCAL(@"Sona Logan: retry to pull multi: %@", streamId);
        }];
    }
}

#pragma mark - Publish

- (void)observePublishEvent {
    @weakify(self)
    [self.audio.onPublishStreamSuccess subscribeNext:^(NSString *streamId) {
        @strongify(self)
        @synchronized (self) {
            SN_LOG_LOCAL(@"Sona Logan: publish success : %@", streamId);
            [self.publishMap removeObjectForKey:streamId];
        }
    }];
}

- (BOOL)retryToPublishStream:(NSString *)streamId {
    NSInteger retryCount = [self.publishMap snIntegerForKey:streamId];
    if (retryCount < MAX_RETRY_COUNT) {
        @synchronized (self) {
            SN_LOG_LOCAL(@"Sona Logan: try publish : %@", streamId);
            retryCount += 1;
            [self.publishMap setValue:@(retryCount) forKey:streamId];
            [[self.audio startPublishWithId:streamId] subscribeNext:^(id x) {}];
        }
        return true;
    } else {
        SN_LOG_LOCAL(@"Sona Logan: publish fail");
        @synchronized (self) {
            [self.publishMap removeObjectForKey:streamId];
        }
        return false;
    }
}

@end
