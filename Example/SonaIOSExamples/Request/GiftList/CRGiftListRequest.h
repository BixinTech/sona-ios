//
//  CRGiftListRequest.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "CRRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRGiftListRequest : CRRequest

+ (RACSignal *)fetchGiftList;

@end

NS_ASSUME_NONNULL_END
