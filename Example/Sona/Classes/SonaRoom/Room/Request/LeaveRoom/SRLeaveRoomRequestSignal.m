//
//  SRLeaveRoomRequestSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/3/10.
//

#import "SRLeaveRoomRequestSignal.h"
#import "SRRequestClient.h"

@implementation SRLeaveRoomRequestSignal
+ (RACSignal *)leaveRoomWithModel:(SRLeaveRoomModel *)model {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/room/leave";
    request.resClass = [NSNumber class];
    request.arg = model;
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
