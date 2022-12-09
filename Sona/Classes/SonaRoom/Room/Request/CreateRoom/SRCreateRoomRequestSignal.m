//
//  SRCreateRoomRequestSignal.m
//  SonaRoom
//
//  Created by Insomnia on 2020/3/10.
//

#import "SRCreateRoomRequestSignal.h"
#import "SRRequestClient.h"
#import "SNConfigModel.h"

@implementation SRCreateRoomRequestSignal
+ (RACSignal *)createRoomWithModel:(SRCreateRoomModel *)model {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url =@"/sona/room/create";
    request.resClass = [NSDictionary class];
    request.arg = model;
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}
@end
