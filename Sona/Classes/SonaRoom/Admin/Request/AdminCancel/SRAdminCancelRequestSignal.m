//
//  SRAdminCancelRequestSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/3/30.
//

#import "SRAdminCancelRequestSignal.h"
#import "SRRequestClient.h"

@implementation SRAdminCancelRequestSignal

+ (RACSignal *)adminCancelWithArg:(NSDictionary *)arg {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/room/admin/cancel";
    request.resClass = [NSNumber class];
    request.arg = arg;
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
