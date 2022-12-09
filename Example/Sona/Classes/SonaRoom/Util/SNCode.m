//
//  SNCode.m
//  ChatRoom
//
//  Created by Insomnia on 2020/1/7.
//

#import <Foundation/Foundation.h>
#import "SNCode.h"
#import "MJExtension.h"

@implementation SonaError
+ (SonaError *)errWithCode:(SNCode)code {
    return [SonaError errorWithDomain:SNErrorDomain code:code userInfo:nil];
}

+ (SonaError *)errWithCode:(SNCode)code streamId:(NSString *)streamId {
    return [SonaError errorWithDomain:SNErrorDomain code:code userInfo:@{@"streamId": streamId}];
}

+ (SonaError *)errWithCode:(NSInteger)code failureReason:(NSString *)failureReason {
    if (!failureReason.length) {
        failureReason  = @"";
    }
    return [self errWithCode:code userInfo:@{NSLocalizedFailureReasonErrorKey:failureReason}];
}

+ (SonaError *)errWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [SonaError errorWithDomain:SNErrorDomain code:code userInfo:userInfo];
}

@end
