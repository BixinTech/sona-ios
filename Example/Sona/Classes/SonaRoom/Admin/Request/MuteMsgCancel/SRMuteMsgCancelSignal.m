//
//  SRMuteMsgCancelSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/4/2.
//

#import "SRMuteMsgCancelSignal.h"
#import "SRRequestClient.h"

@implementation SRMuteMsgCancelSignal

+ (RACSignal *)cancelMuteMsgWithArg:(NSDictionary *)arg {

    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/room/mute/cancel";
    request.arg = arg;
    request.resClass = [NSNumber class];
    
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
