//
//  SRAudioPrepRebootItem.m
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/9/27.
//

#import "SRAudioPrepRebootItem.h"
#import "SRRebootService.h"

@interface SRAudioPrepRebootItem ()

@property (nonatomic, strong) NSMutableSet *processors;

@end

@implementation SRAudioPrepRebootItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.processors = [NSMutableSet new];
    }
    return self;
}

- (void)startReboot {
    @synchronized (self) {
        [self.processors enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            !self.onRebootAction ? : self.onRebootAction(obj);
        }];
    }
}

- (void)addProcessor:(id)processor {
    @synchronized (self) {
        [self.processors addObject:processor];
    }
}

- (void)removeProcessor:(id)processor {
    @synchronized (self) {
        [self.processors removeObject:processor];
    }
}

@end
