//
//  SROpenRoomRequestSignal.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/10/18.
//

#import "SROpenRoomRequestSignal.h"
#import "SRRequestClient.h"

@implementation SROpenRoomRequestSignal

+ (RACSignal *)openRoomWithModel:(SROpenRoomModel *)model {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/room/open";
    request.resClass = [NSNumber class];
    request.arg = model;
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}
@end
