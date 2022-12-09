//
//  SRRoomLogRequestSignal.h
//  ChatRoom
//
//  Created by Insomnia on 2020/1/14.
//

#import <Foundation/Foundation.h>
#import "SRRequestClient.h"
#import "SRRoomLogArgModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRRoomLogRequestSignal : SRRequestClient

+ (RACSignal *)roomLogRequestWithcode:(NSInteger)code argModel:(SRRoomLogArgModel *)argModel;

@end

NS_ASSUME_NONNULL_END
