//
//  SRKickUserRequestSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/3/30.
//

#import "SRKickUserRequestSignal.h"
#import "SRRequestClient.h"

@implementation SRKickUserRequestSignal

+ (RACSignal *)kickUserWithArg:(NSDictionary *)arg {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/room/kick";
    request.arg = arg;
    request.resClass = [NSNumber class];
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
