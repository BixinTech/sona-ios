//
//  CRGiftModel.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRGiftModel : NSObject

@property (nonatomic, assign) NSInteger giftId;

@property (nonatomic, copy) NSString *giftName;

@property (nonatomic, copy) NSString *price;

@property (nonatomic, assign) BOOL selected;

@end

NS_ASSUME_NONNULL_END
