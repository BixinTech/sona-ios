//
//  SNEventSignpost.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/8/24.
//

#import "SNEventSignpost.h"
#import "RACSubject.h"
#import "SNCode.h"

#define BEGIN @"beginTime"
#define END @"endTime"
#define DURATION @"duration"
#define SPID_COMMON @"com.sona.event.common"

@interface SNEvent : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSNumber *begin;

@property (nonatomic, strong) NSNumber *end;

@property (nonatomic, copy) NSDictionary *data;

@end

@implementation SNEvent

@end

@interface SNEventSignpost ()

@property (nonatomic, strong) NSMutableDictionary *eventMap;

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation SNEventSignpost

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.eventMap = @{}.mutableCopy;
    self.queue = dispatch_queue_create("com.sona.event.signpost", DISPATCH_QUEUE_SERIAL);
}

- (void)begin:(NSString *)eventName ext:(NSDictionary *)ext {
    [self begin:eventName spid:SPID_COMMON ext:ext];
}

- (void)end:(NSString *)eventName {
    [self end:eventName spid:SPID_COMMON];
}

- (void)begin:(NSString *)eventName spid:(NSString *)spid ext:(NSDictionary *)ext {
    dispatch_async(self.queue, ^{
        if (!eventName || eventName.length == 0) {
            return;
        }
        if (spid && spid.length > 0) {
            SNEvent *event = [SNEvent new];
            event.begin = [self currentTimestamp];
            event.data = ext;
            event.name = eventName;
            NSMutableDictionary *events = [self.eventMap objectForKey:eventName];
            if (events) {
                NSMutableDictionary *mergedEvents = [NSMutableDictionary dictionaryWithDictionary:events];
                [mergedEvents setObject:event forKey:spid];
                events = mergedEvents;
            } else {
                events = @{spid: event}.mutableCopy;
            }
            [self.eventMap setObject:events forKey:eventName];
        } else {
            [self begin:eventName spid:SPID_COMMON ext:ext];
        }
    });
}

- (void)end:(NSString *)eventName spid:(NSString *)spid {
    dispatch_async(self.queue, ^{
        NSMutableDictionary *events = [self.eventMap objectForKey:eventName];
        if (!events || ![events isKindOfClass:[NSMutableDictionary class]]) {
            return;
        }
        if (spid && spid.length > 0) {
            SNEvent *event = [events objectForKey:spid];
            if (!event) {
                return;
            }
            event.end = [self currentTimestamp];
            // remove event after upload
            [events removeObjectForKey:spid];
            [self upload:event];
        } else {
            [self end:eventName spid:SPID_COMMON];
        }
    });
}

- (void)upload:(SNEvent *)event {
    
    if (!event.name || event.name.length == 0) {
        return;
    }
    
    if (event.begin.longValue <= 0 || event.end.longValue <= 0) {
        return;
    }
    
    // upload...
}

- (NSNumber *)currentTimestamp {
    return @(floor([[NSDate date] timeIntervalSince1970] * 1000));
}


@end
