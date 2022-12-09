//
//  SRSpecificNotStreamCommand.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/25.
//

#import "SRSpecificNotStreamCommand.h"
#import "MJExtension.h"
#import "SRRequestClient.h"

@interface SRSpecificNotStreamRequest : SRRequestClient
//@property (nonatomic, strong) SRSpecificNotStreamModel *argModel;
@end

@implementation SRSpecificNotStreamRequest
//- (NSString *)requestUrl {
//    return @"/sona/stream/pull/specific/not";
//}
//
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

@implementation SRSpecificNotStreamCommand

- (RACCommand *)requestCommond {
    if (!_requestCommond) {
        _requestCommond = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(SRSpecificNotStreamModel *argModel) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//                SRSpecificNotStreamRequest *request = [SRSpecificNotStreamRequest new];
//                request.argModel = argModel;
//                [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
//                    if (![request.responseJSONObject[@"code"] isEqualToString:@"8000"]) {
//                        [subscriber sendError:nil];
//                        [subscriber sendCompleted];
//                        return;
//                    }
//
//                    [subscriber sendNext:request.responseJSONObject[@"result"]];
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
