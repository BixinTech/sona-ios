//
//  NSObject+SRUtils.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/1/6.
//

#import "NSObject+SRUtils.h"

@implementation NSObject (SRUtils)

- (BOOL)isEmptyString {
    if ([self isKindOfClass:[NSString class]]) {
        return [(NSString *)self length] == 0;
    } else {
        return true;
    }
}

@end
