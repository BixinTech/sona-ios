//
//  SRAdminSetSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/3/30.
//

#import "SRAdminSetRequestSignal.h"
#import "SRRequestClient.h"

@implementation SRAdminSetRequestSignal

+ (RACSignal *)adminSetWithArg:(NSDictionary *)arg {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/room/admin/set";
    request.resClass = [NSNumber class];
    request.arg = arg;
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
