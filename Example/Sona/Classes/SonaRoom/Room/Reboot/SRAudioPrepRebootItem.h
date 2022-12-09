//
//  SRAudioPrepRebootItem.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/9/27.
//

#import <Foundation/Foundation.h>
#import "SRRebootServiceItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRAudioPrepRebootItem : NSObject<SRRebootServiceItem>

@property (nonatomic, copy) void(^onRebootAction)(id processor);


- (void)addProcessor:(id)processor;

- (void)removeProcessor:(id)processor;

@end

NS_ASSUME_NONNULL_END
