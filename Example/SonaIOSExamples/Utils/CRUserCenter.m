//
//  CRUserCenter.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/15.
//

#import "CRUserCenter.h"

@implementation CRUserCenter

+ (instancetype)defaultCenter {
    static CRUserCenter *user;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [CRUserCenter new];
    });
    return user;
}

- (NSString *)uid {
    return @"123";
}

@end
