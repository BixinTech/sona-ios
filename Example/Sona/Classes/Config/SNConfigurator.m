//
//  SNConfigurator.m
//  Sona
//
//  Created by Ju Liaoyuan on 2022/12/7.
//

#import "SNConfigurator.h"

@implementation SNConfigurator

+ (instancetype)configurator {
    static SNConfigurator *configurator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configurator = [[self alloc] _init];
    });
    return configurator;
}

- (instancetype)_init {
    self = [super init];
    return self;
}

@end
