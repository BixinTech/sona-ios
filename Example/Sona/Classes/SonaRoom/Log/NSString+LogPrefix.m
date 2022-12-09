//
//  NSString+LogPrefix.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/2/21.
//

#import "NSString+LogPrefix.h"

@implementation NSString (LogPrefix)

- (NSString *)appendPrefix:(NSString *)prefix {
    return [NSString stringWithFormat:@"[%@]: %@", prefix, self];
}

@end
