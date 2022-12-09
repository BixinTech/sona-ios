//
//  SRRebootServiceManager.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/9/27.
//

#import <Foundation/Foundation.h>
#import "SRRebootService.h"
#import "SRAudioPrepRebootItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRRebootServiceManager : NSObject

@property (nonatomic, strong, readonly) SRAudioPrepRebootItem *audioPrepReboot;

- (void)reboot;

@end

NS_ASSUME_NONNULL_END
