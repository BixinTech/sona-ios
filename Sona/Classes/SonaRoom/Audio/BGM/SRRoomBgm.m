//
//  SRBgm.m
//  SonaRoom
//
//  Created by Insomnia on 2020/3/13.
//

#import "SRRoomBgm.h"
#import "SNSDK.h"

@interface SRRoomBgm ()
@property(nonatomic, strong) SNSDK *sdk;
@property(nonatomic, strong) SNConfigModel *configModel;
@end

@implementation SRRoomBgm
- (instancetype)initWithTuple:(RACTuple *)tuple {
    RACTupleUnpack(SNSDK * sdk, SNConfigModel *configModel) = tuple;
    self = [SRRoomBgm new];
    if (self) {
        self.sdk = sdk;
        self.configModel = configModel;
    }
    return self;
}

- (void)updateConfigWithModel:(SNConfigModel *)model {
    self.configModel = model;
}

- (id<SNMediaPlayer>)auxPlayer {
    return [self.sdk.audio auxPlayer];
}

- (id<SNMediaPlayer>)localPlayer {
    return [self.sdk.audio localPlayer];
}

- (id<SNPCMPlayer>)pcmPlayer {
    return [self.sdk.audio pcmPlayer];
}

- (id<SNCopyrightedMediaPlayer>)musicPlayer {
    return [self.sdk.audio musicPlayer];
}

@end
