//
//  SRRebootService.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/9/27.
//

#import "SRRebootService.h"

@interface SRRebootService ()

@property (nonatomic, strong) NSMutableSet<id<SRRebootServiceItem>> *items;

@end

@implementation SRRebootService

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.items = [NSMutableSet new];
}

- (void)registerRebootItem:(id<SRRebootServiceItem>)item {
    @synchronized (self) {
        [self.items addObject:item];
    }
}

- (void)removeRebootItem:(id<SRRebootServiceItem>)item {
    @synchronized (self) {
        [self.items removeObject:item];
    }
}

- (void)reboot {
    @synchronized (self) {
        [self.items enumerateObjectsUsingBlock:^(id<SRRebootServiceItem>  _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj && [obj respondsToSelector:@selector(startReboot)]) {
                [obj startReboot];
            }
        }];
    }
}

@end
