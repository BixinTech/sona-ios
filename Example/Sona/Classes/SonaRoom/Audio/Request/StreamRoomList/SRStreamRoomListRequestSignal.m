//
//  SRStreamRoomList.m
//  SonaRoom
//
//  Created by Insomnia on 2020/2/10.
//

#import "SRStreamRoomListRequestSignal.h"

@implementation SRStreamRoomListRequestSignal
+ (RACSignal *)StreamRoomListWithRoomId:(NSString *)roomId {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodGET];
    
    request.url = @"/sona/stream/room/list";
    NSDictionary *argDic = @{
        @"roomId": roomId,
    };
    request.arg = argDic;
    request.resClass = [NSString class];
    
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
