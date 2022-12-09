//
//  SNLoggerHelper.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/1/21.
//

#import "SNLoggerHelper.h"
#import "SNLocalLogger.h"
#import "SNConfigModel.h"
#import "SNCode.h"

static inline NSString *localScene() {
    return [SNLocalLogger sceneKey];
}

@interface SNLoggerHelper ()

@property (nonatomic, strong) SNLogger *loggerManager;

@end

@implementation SNLoggerHelper

+ (instancetype)shared {
    static SNLoggerHelper *_helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [[SNLoggerHelper alloc] _init];
    });
    return _helper;
}

- (instancetype)_init {
    self = [super init];
    if (self) {
        [self setDefaultLogger:@[[SNLocalLogger new]]];
    }
    return self;
}

- (void)setDefaultLogger:(NSArray *)loggerCls {
    [loggerCls enumerateObjectsUsingBlock:^(id<SNLoggerProtocol> logger, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *sceneKey = [logger.class performSelector:@selector(sceneKey)];
        [self.loggerManager registerLogger:logger forScene:sceneKey];
    }];
}

- (SNLogger *)loggerManager {
    return [SNLogger shared];
}

#pragma mark - Config

- (void)clearData {
    self.roomId = nil;
}

#pragma mark - Basic

- (void)localLog:(NSString *)content prefix:(NSString *)prefix ext:(NSDictionary *)ext {
    NSMutableDictionary *mExt = [[NSMutableDictionary alloc] initWithDictionary:ext];
    if (self.roomId) {
        [mExt setValue:self.roomId forKey:SNLoggerRoomIdKey];
    }
    if ([self uid]) {
        [mExt setValue:[self uid] forKey:SNLoggerUseIdKey];
    }
    if (prefix) {
        content = [content appendPrefix:prefix];
    } else {
        content = [content appendPrefix:SNLoggerDefaultPrefix];
    }
    
    [self.loggerManager logForScene:localScene()
                            content:content
                                ext:mExt];
}

- (NSString *)uid {
    /// 添加UID
    return @"";
}


@end
