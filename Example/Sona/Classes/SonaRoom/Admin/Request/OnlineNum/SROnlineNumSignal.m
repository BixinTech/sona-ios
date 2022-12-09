//
//  SROnlineNumSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/4/2.
//

#import "SROnlineNumSignal.h"
#import "SRRequestClient.h"

@implementation SROnlineNumSignal

+ (RACSignal *)onlineNumWithRoomId:(NSString *)roomId {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodGET];
    request.url = @"/sona/room/member/count";
    request.arg = @{@"roomId": roomId ? : @""};
    request.resClass = [NSNumber class];
    
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
