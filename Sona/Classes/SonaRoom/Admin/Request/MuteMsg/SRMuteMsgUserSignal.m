//
//  SRMuteMsgUserSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/4/2.
//

#import "SRMuteMsgUserSignal.h"
#import "SRRequestClient.h"

@implementation SRMuteMsgUserSignal

+ (RACSignal *)muteMsgWithArg:(NSDictionary *)arg {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/room/mute";
    request.arg = arg;
    request.resClass = [NSNumber class];
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
