//
//  SRRoomMessageQueueManager.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/1/26.
//

#import "SRRoomMessageQueueManager.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "SNLoggerHelper.h"

@interface SRRoomMessageQueueManager ()

@property (nonatomic, strong) NSMutableArray *messageArray;

@property (nonatomic, strong) NSString *sentry;

@property (nonatomic, strong) dispatch_queue_t messageQueue;

@end

@implementation SRRoomMessageQueueManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (void)defaultConfig {
    self.capacity = 601;
    self.sentry = @"sentry";
    self.messageArray = [NSMutableArray new];
    self.messageQueue = dispatch_queue_create("com.sonaroom.messageQueue", DISPATCH_QUEUE_SERIAL);
}

- (void)enqueue:(NSString *)messageId {
    if (!(messageId && messageId.length > 0)) {
        return;
    }
    dispatch_sync(self.messageQueue, ^{
        if (self.messageArray.count >= self.capacity) {
            SN_LOG_LOCAL(@"Room Message Qeueue: 队列已满，capacity:%@",@(self.capacity));
            [self unsafeRemoveItemBeforeSentry];
            SN_LOG_LOCAL(@"Room Message Qeueue: 移除超时元素后，总数量:%@",@(self.messageArray.count));
        }
        if (self.messageArray.count >= self.capacity) {
            SN_LOG_LOCAL(@"Room Message Qeueue: 队列已满，且无超时元素，移除第一个元素");
            [self.messageArray removeObjectAtIndex:0];
        }
        [self.messageArray addObject:messageId];
        SN_LOG_LOCAL(@"Room Message Qeueue: 入队：%@", messageId);
    });
}

- (BOOL)contain:(NSString *)messageId {
    __block BOOL result = false;
    dispatch_sync(self.messageQueue, ^{
        if (messageId && messageId.length > 0) {
            result = [self.messageArray containsObject:messageId];
        } else {
            result = false;
        }
    });
    return result;
}


- (NSArray *)allElements {
    __block NSArray *result = @[];
    dispatch_sync(self.messageQueue, ^{
        result = self.messageArray.copy;
    });
    return result;
}

- (void)insertSentry {
    dispatch_sync(self.messageQueue, ^{
        [self.messageArray removeObject:self.sentry];
        [self.messageArray addObject:self.sentry];
    });
}

- (void)removeItemBeforeSentry {
    dispatch_sync(self.messageQueue, ^{
        [self unsafeRemoveItemBeforeSentry];
    });
}

- (void)unsafeRemoveItemBeforeSentry {
    while (self.messageArray.firstObject != self.sentry && self.messageArray.count > 0) {
        [self.messageArray removeObjectAtIndex:0];
    }
    [self.messageArray removeObject:self.sentry];
    [self.messageArray addObject:self.sentry];
}

- (void)setCapacity:(NSInteger)capacity {
    // 和后端约定，capacity 不会设置为0。为0时，客户端走兜底逻辑
    if (capacity <= 0) {
        return;
    }
    _capacity = capacity;
}

@end
