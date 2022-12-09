//
//  SRSyncConfigRequest.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/8/18.
//

#import "SRSyncConfigRequest.h"
#import "SRRequestClient.h"
#import "SRSyncConfigModel.h"

@implementation SRSyncConfigRequest

+ (RACSignal *)syncConfigWithRoomId:(NSString *)roomId {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodGET];
    request.url = @"/sona/stream/sync/config";
    request.arg = @{@"roomId": roomId ? : @""};
    request.resClass = [SRSyncConfigModel class];
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
