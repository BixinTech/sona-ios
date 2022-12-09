//
//  SRRemixStreamRequestSignal.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/5/14.
//

#import "SRRemixStreamRequestSignal.h"
#import "SRRequestClient.h"

@implementation SRRemixStreamRequestSignal

+ (RACSignal *)remixStream:(NSString *)roomId {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/stream/remixed";
    request.arg = @{@"roomId":roomId ? : @""};
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
