//
//  SRRoomMessageManager.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/1/27.
//

#import "SRRoomMessageManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "SNLoggerHelper.h"
#import "SNGzipTool.h"

@interface SRRoomMessageManager () {
    CFRunLoopRef _runloop;
}

@property (nonatomic, strong) SRRoomMessageQueueManager *messageQueue;

@property (nonatomic, strong) dispatch_queue_t timerQueue;

@property (nonatomic, strong) NSTimer *pollingTimer;

@end

@implementation SRRoomMessageManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (void)defaultConfig {
    self.messageQueue = [SRRoomMessageQueueManager new];
    self.timerQueue = dispatch_queue_create("com.sonaroom.messageManager.timer", DISPATCH_QUEUE_SERIAL);
    self.pollingInterval = 10;
}

- (void)setMessageQueueSize:(NSInteger)messageQueueSize {
    _messageQueueSize = messageQueueSize;
    self.messageQueue.capacity = messageQueueSize;
}

- (void)setPollingInterval:(NSInteger)pollingInterval {
    if (pollingInterval <= 0) {
        return;
    }
    _pollingInterval = pollingInterval;
}

- (void)startPollingTimer {
    if (!self.timerQueue) return;
    if ([self isRunning]) return;
    @weakify(self)
    dispatch_async(self.timerQueue, ^{
        @strongify(self)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-retain-self"
        _runloop = CFRunLoopGetCurrent();
#pragma clang diagnostic pop
        if (self.pollingTimer) {
            [self.pollingTimer invalidate];
            self.pollingTimer = nil;
        }
        self.pollingTimer = [NSTimer scheduledTimerWithTimeInterval:self.pollingInterval repeats:true block:^(NSTimer * _Nonnull timer) {
            SN_LOG_LOCAL(@"Room Message Manager - Timer - Will Remove Items: %@", self.messageQueue.allElements);
            [self.messageQueue removeItemBeforeSentry];
            SN_LOG_LOCAL(@"Room Message Manager - Timer Did Remove Items:%@", self.messageQueue.allElements);
        }];
        SN_LOG_LOCAL(@"Room Message Manager - Timer Create: %@", self.pollingTimer);
        [[NSRunLoop currentRunLoop] run];
    });
}
- (void)stopPollingTimer {
    if (self.pollingTimer) {
        [self.pollingTimer invalidate];
        self.pollingTimer = nil;
    }
    
    if (_runloop) {
        CFRunLoopStop(_runloop);
        _runloop = NULL;
    }
}

- (BOOL)isRunning {
    return _runloop != NULL;
}

- (BOOL)inQueue:(NSString *)messageId {
    return [self.messageQueue contain:messageId];
}

@end
