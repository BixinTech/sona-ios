//
//  CRRoomInfoRequest.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "CRRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRRoomInfoRequest : CRRequest

+ (RACSignal *)fetchRoomInfo:(NSString *)roomId;

@end

NS_ASSUME_NONNULL_END
