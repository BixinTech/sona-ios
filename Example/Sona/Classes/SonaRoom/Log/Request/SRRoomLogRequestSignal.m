//
//  SRRoomLogRequestSignal.m
//  ChatRoom
//
//  Created by Insomnia on 2020/1/14.
//

#import "SRRoomLogRequestSignal.h"
#import "MJExtension.h"

@implementation SRRoomLogRequestSignal
+ (RACSignal *)roomLogRequestWithcode:(NSInteger)code argModel:(SRRoomLogArgModel *)argModel {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/log/report";
    NSString *dataStr = [argModel mj_JSONString];
    NSDictionary *argDic = @{
        @"code": @(code),
        @"data": dataStr
    };
    request.arg = argDic;
    request.resClass = [NSNumber class];
    
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}
@end
