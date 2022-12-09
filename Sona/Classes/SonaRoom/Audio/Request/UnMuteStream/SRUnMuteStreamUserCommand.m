//
//  SRMuteStreamCancelUserCommand.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/21.
//

#import "SRUnMuteStreamUserCommand.h"
#import "SRRequestClient.h"
#import "MJExtension.h"

@interface SRMuteStreamCancelUserRequest : SRRequestClient
@property(nonatomic, strong) SRUnMuteStreamUserModel *argModel;
@end

@implementation SRMuteStreamCancelUserRequest
- (NSString *)requestUrl {
    return @"/sona/stream/mute/cancel";
}

//- (YRRequestType)requestType {
//    return YRRequestTypeCenterGround;
//}

- (NSDictionary *)parameters {
    return [self.argModel mj_keyValues];
}

//- (YTKRequestMethod)requestMethod {
//    return SNRequestMethodPOST;
//}
@end
@implementation SRUnMuteStreamUserCommand
- (RACCommand *)requestCommond {
    if (!_requestCommond) {
        _requestCommond = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(SRUnMuteStreamUserModel *arg) {
            return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
                SRMuteStreamCancelUserRequest *request = [SRMuteStreamCancelUserRequest new];
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
