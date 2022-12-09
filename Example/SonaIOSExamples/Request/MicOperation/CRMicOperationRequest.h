//
//  CRMicOperationRequest.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "CRRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRMicOperationRequest : CRRequest

/// operate: 0-下麦，1-上麦
+ (RACSignal * )micOperationWithRoomId:(NSString *)roomId uid:(NSString *)uid index:(NSInteger)index operate:(NSInteger)operate;

@end

NS_ASSUME_NONNULL_END
