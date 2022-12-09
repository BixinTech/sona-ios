//
//  SROnlineListSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/4/2.
//

#import "SROnlineListSignal.h"
#import "SRRequestClient.h"
#import "SROnlineListResModel.h"

@implementation SROnlineListSignal

+ (RACSignal *)onlineListWithArg:(NSDictionary *)arg {
    
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodGET];
    request.url = @"/sona/room/member/list";
    request.arg = arg;
    request.resClass = [SROnlineListResModel class];
    
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
