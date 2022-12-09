//
//  SROpenRoomRequestSignal.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/10/18.
//

#import <Foundation/Foundation.h>
#import "SROpenRoomModel.h"

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SROpenRoomRequestSignal : NSObject

+ (RACSignal *)openRoomWithModel:(SROpenRoomModel *)model;

@end

NS_ASSUME_NONNULL_END
