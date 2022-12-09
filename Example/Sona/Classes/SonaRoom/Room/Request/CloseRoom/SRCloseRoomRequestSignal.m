//
//  SRCloseRoomRequestSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/3/10.
//

#import "SRCloseRoomRequestSignal.h"
#import "SRRequestClient.h"

@implementation SRCloseRoomRequestSignal
+ (RACSignal *)closeRoomWithModel:(SRCloseRoomModel *)model {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/room/close";
    request.resClass = [NSNumber class];
    request.arg = model;
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}
@end
