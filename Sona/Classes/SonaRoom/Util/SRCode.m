//
//  SRCode.m
//  SonaRoom
//
//  Created by Insomnia on 2020/1/8.
//

#import <Foundation/Foundation.h>
#import "SRCode.h"

@implementation SRError
+ (NSError *)errWithCode:(SRCode)code {
    return [NSError errorWithDomain:SRErrorDomain code:code userInfo:nil];
}
@end
