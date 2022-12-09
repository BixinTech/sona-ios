//
//  SRMsgSendRequestSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/1/16.
//

#import <Foundation/Foundation.h>
#import "SRRequestClient.h"
#import "SRMsgSendModel.h"
#import "SRRequestClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRMsgSendRequestSignal : NSObject
+ (RACSignal *)msgSendWithModel:(SRMsgSendModel *)model roomId:(NSString *)roomId;
@end

NS_ASSUME_NONNULL_END
