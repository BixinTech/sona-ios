//
//  CRMicOperationRequest.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "CRMicOperationRequest.h"

@implementation CRMicOperationRequest

+ (RACSignal * )micOperationWithRoomId:(NSString *)roomId uid:(NSString *)uid index:(NSInteger)index operate:(NSInteger)operate {
    CRRequest *req = [[CRRequest alloc] initWithMethod:SNRequestMethodPOST];
    req.url = @"/sona/demo/room/mic";
    req.arg = @{@"roomId":roomId ? : @"",
                @"uid": uid ? :@"",
                @"index": @(index),
                @"operate":@(operate)};
    return [[SRRequestClient shareInstance] signalWithRequest:req];
}

@end

