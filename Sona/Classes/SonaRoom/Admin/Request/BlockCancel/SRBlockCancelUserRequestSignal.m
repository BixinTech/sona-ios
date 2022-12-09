//
//  SRBlockCancelUserRequestSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/3/30.
//

#import "SRBlockCancelUserRequestSignal.h"
#import "SRRequestClient.h"

@implementation SRBlockCancelUserRequestSignal

+ (RACSignal *)cancelBlockUserWithArg:(NSDictionary *)arg {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/room/block/cancel";
    request.resClass = [NSNumber class];
    request.arg = arg;
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
