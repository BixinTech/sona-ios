//
//  SREnterRoomRequestSignal.h
//  SonaRoom
//
//  Created by Insomnia on 2020/3/10.
//

#import <Foundation/Foundation.h>
#import "SREnterRoomModel.h"

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SREnterRoomRequestSignal : NSObject
+ (RACSignal *)enterRoomWithModel:(SREnterRoomModel *)model;
@end

NS_ASSUME_NONNULL_END
