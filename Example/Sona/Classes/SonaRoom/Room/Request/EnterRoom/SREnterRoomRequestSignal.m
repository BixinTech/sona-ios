//
//  SREnterRoomRequestSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/3/10.
//

#import "SREnterRoomRequestSignal.h"
#import "SRRequestClient.h"
#import "SNConfigModel.h"

@implementation SREnterRoomRequestSignal

+ (RACSignal *)enterRoomWithModel:(SREnterRoomModel *)model {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/room/enter";
    request.resClass = [SNConfigModel class];
    request.arg = model;
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
