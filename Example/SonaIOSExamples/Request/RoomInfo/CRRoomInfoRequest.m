//
//  CRRoomInfoRequest.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "CRRoomInfoRequest.h"
#import "CRRoomInfoResult.h"

@implementation CRRoomInfoRequest

+ (RACSignal *)fetchRoomInfo:(NSString *)roomId {
    CRRequest *req = [[CRRequest alloc] initWithMethod:SNRequestMethodGET];
    req.url = @"/sona/demo/room/info";
    req.arg = @{@"roomId": roomId ? : @""};
    req.resClass = [CRRoomInfoResult class];
    return [[SRRequestClient shareInstance] signalWithRequest:req];
}

@end
