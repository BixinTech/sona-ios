//
//  SRMonitorStreamReqSig.m
//  SonaRoom
//
//  Created by Insomnia on 2020/8/10.
//

#import "SRMonitorStreamReqSig.h"
#import "SRRequestClient.h"


@implementation SRMonitorStreamReqSig

+ (RACSignal *)monitorStreamWith:(NSDictionary *)arg {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/stream/error/report";
    request.arg = arg;
    request.resClass = [NSString class];
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
