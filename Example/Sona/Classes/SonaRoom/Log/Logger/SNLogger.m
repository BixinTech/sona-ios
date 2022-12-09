//
//  SNLogger.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/1/19.
//

#import "SNLogger.h"
#import "SNLoggerProtocol.h"

@interface SNLogger ()

@property (nonatomic, strong) NSMutableDictionary *loggerMap;

@end

@implementation SNLogger

+ (instancetype)shared {
    static SNLogger *logger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[SNLogger alloc] _init];
    });
    return logger;
}


- (instancetype)_init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.loggerMap = [NSMutableDictionary new];
}

- (void)logForScene:(NSString *)scene content:(NSString *)content ext:(NSDictionary *)ext {
    id<SNLoggerProtocol> logger = self.loggerMap[scene];
    if (logger) {
        [logger logWithContent:content ext:ext];
    }
}

- (void)registerLogger:(id<SNLoggerProtocol>)logger forScene:(NSString *)scene {
    if (!logger || !scene) {
        NSAssert(NO, @"params is nil");
        return;
    }
    [self.loggerMap setValue:logger forKey:scene];
}

- (void)unregisterLoggerWithScene:(NSString *)scene {
    if (!scene) {
        NSAssert(NO, @"params is nil");
        return;
    }
    [self.loggerMap removeObjectForKey:scene];
}

@end
