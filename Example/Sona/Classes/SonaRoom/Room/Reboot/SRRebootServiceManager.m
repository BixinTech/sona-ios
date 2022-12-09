//
//  SRRebootServiceManager.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/9/27.
//

#import "SRRebootServiceManager.h"

@interface SRRebootServiceManager ()

@property (nonatomic, strong) SRRebootService *rebootService;

@property (nonatomic, strong) SRAudioPrepRebootItem *audioPrepReboot;

@end

@implementation SRRebootServiceManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.rebootService = [SRRebootService new];
    [self.rebootService registerRebootItem:self.audioPrepReboot];
}

#pragma mark - reboot items

- (SRAudioPrepRebootItem *)audioPrepReboot {
    if (!_audioPrepReboot) {
        _audioPrepReboot = [SRAudioPrepRebootItem new];
    }
    return _audioPrepReboot;
}

#pragma mark - public methods

- (void)reboot {
    [self.rebootService reboot];
}


@end
