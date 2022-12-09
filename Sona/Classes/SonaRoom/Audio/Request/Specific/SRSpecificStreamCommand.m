//
//  SRSpecificStreamCommand.m
//  SonaRoom
//
//  Created by Insomnia on 2019/12/24.
//

#import "SRSpecificStreamCommand.h"
#import "SRRequestClient.h"
#import "MJExtension.h"

@interface SRSpecificStreamRequest : SRRequestClient
@property (nonatomic, strong) SRSpecificStreamModel *argModel;
@end

@implementation SRSpecificStreamRequest
- (NSString *)requestUrl {
    return @"/sona/stream/pull/specific";
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

@implementation SRSpecificStreamCommand

- (RACCommand *)requestCommond {
    if (!_requestCommond) {
        _requestCommond = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(SRSpecificStreamModel *argModel) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//                SRSpecificStreamRequest *request = [SRSpecificStreamRequest new];
//                request.argModel = argModel;
//                [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
//                    if (![request.responseJSONObject[@"code"] isEqualToString:@"8000"]) {
//                        [subscriber sendError:nil];
//                        [subscriber sendCompleted];
//                        return;
//                    }
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
