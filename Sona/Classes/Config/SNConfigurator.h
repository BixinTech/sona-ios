//
//  SNConfigurator.h
//  Sona
//
//  Created by Ju Liaoyuan on 2022/12/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SNConfigurator : NSObject

@property (nonatomic, copy) NSString *requestAddress;

+ (instancetype)configurator;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;



@end

NS_ASSUME_NONNULL_END
