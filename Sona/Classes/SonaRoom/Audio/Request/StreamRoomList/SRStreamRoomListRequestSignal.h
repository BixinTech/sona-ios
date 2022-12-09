//
//  SRStreamRoomList.h
//  SonaRoom
//
//  Created by Insomnia on 2020/2/10.
//

#import <Foundation/Foundation.h>
#import "SRRequestClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRStreamRoomListRequestSignal : SRRequestClient
+ (RACSignal *)StreamRoomListWithRoomId:(NSString *)roomId;
@end

NS_ASSUME_NONNULL_END
