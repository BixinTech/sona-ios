//
//  SRLeaveRoomRequestSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/3/10.
//

#import <Foundation/Foundation.h>
#import "SRLeaveRoomModel.h"

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SRLeaveRoomRequestSignal : NSObject
+ (RACSignal *)leaveRoomWithModel:(SRLeaveRoomModel *)model;
@end

NS_ASSUME_NONNULL_END
