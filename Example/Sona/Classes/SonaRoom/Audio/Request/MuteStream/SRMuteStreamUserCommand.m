//
//  SRMuteStreamUserCommand.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/21.
//

#import "SRMuteStreamUserCommand.h"
#import "SRRequestClient.h"
#import "MJExtension.h"

@interface SRMuteStreamUserRequest : SRRequestClient
@property(nonatomic, strong) SRMuteStreamUserModel *argModel;
@end

@implementation SRMuteStreamUserRequest
- (NSString *)requestUrl {
    return @"/sona/stream/mute";
}

//- (YRRequestType)requestType {
//    return YRRequestTypeCenterGround;
//}
//
//- (NSDictionary *)parameters {
//    return [self.argModel mj_keyValues];
//}
//
//- (YTKRequestMethod)requestMethod {
//    return SNRequestMethodPOST;
//}
@end

@implementation SRMuteStreamUserCommand
- (RACCommand *)requestCommond {
    if (!_requestCommond) {
        _requestCommond = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(SRMuteStreamUserModel *arg) {
            return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
                SRMuteStreamUserRequest *request = [SRMuteStreamUserRequest new];
                request.argModel = arg;
//                [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
//                    if (![request.responseJSONObject[@"code"] isEqualToString:@"8000"]) {
//                        [subscriber sendError:nil];
//                        [subscriber sendCompleted];
//                        return;
//                    }
//                    NSInteger res = (NSInteger)request.responseJSONObject[@"result"];
//                    [subscriber sendNext:@(res)];
//                    [subscriber sendCompleted];
//                }                                    failure:^(__kindof YTKBaseRequest *request) {
                    [subscriber sendError:nil];
                    [subscriber sendCompleted];
//                }];
                return nil;
            }];
        }];
    }
    return _requestCommond;
}
@end
