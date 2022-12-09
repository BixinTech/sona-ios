//
//  SRRebootService.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/9/27.
//

/**
 * Sona 在不同云商之间热切时，对业务上层是无感知的。因此，对于上层主动打开的能力，在热切后会丢失。
 * 为了贯彻之前的理念："上层无感知"，所以需要在热切完成后，自动重启相关能力
 */
#import <Foundation/Foundation.h>
#import "SRRebootServiceItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SRRebootService : NSObject

- (void)registerRebootItem:(id<SRRebootServiceItem>)item;

- (void)removeRebootItem:(id<SRRebootServiceItem>)item;

- (void)reboot;

@end

NS_ASSUME_NONNULL_END
