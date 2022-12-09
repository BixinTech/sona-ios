//
//  SRModifyPasswordRequestSignal.m
//  Sona
//
//  Created by Ju Liaoyuan on 2022/10/19.
//

#import "SRModifyPasswordRequestSignal.h"
#import "SRRequestClient.h"

@implementation SRModifyPasswordRequestSignal

+ (RACSignal *)modifyPassword:(NSDictionary *)arg {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/room/password/update";
    request.resClass = [NSNumber class];
    request.arg = arg;
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
