//
//  SRBlockUserRequestSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/3/30.
//

#import "SRBlockUserRequestSignal.h"
#import "SRRequestClient.h"

@implementation SRBlockUserRequestSignal

+ (RACSignal *)blockUserWithArg:(NSDictionary *)arg {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/room/block";
    request.resClass = [NSNumber class];
    request.arg = arg;
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
