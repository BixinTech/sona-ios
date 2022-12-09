//
//  SNZGSeiService.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/25.
//

#import "SNZGSeiService.h"
#import <ZegoLiveRoom/ZegoLiveRoom.h>
#import "NSDictionary+SNProtectedKeyValue.h"

#define SceneKey @"scene"
#define SonaScene @"sona"

@interface SNZGSeiService ()<ZegoMediaSideDelegate>

@property (nonatomic, weak) ZegoLiveRoomApi *api;

@property (nonatomic, strong) ZegoMediaSideInfo *mediaSideInfo;

@property (nonatomic, copy) NSDictionary *messageScene;

@end

@implementation SNZGSeiService

- (instancetype)initWithZegoApi:(ZegoLiveRoomApi *)api {
    self = [super init];
    if (self) {
        self.api = api;
        [self defaultConfig];
    }
    return self;
}

- (void)defaultConfig {
    [self mediaSideInfo];
    self.messageScene = @{SceneKey:SonaScene};
}

#pragma mark - public method

- (void)sendMessage:(NSDictionary *)message {
    if (!message || ![message isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:self.messageScene];
    [result setValue:message forKey:@"data"];
    NSData *payload = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
    [self.mediaSideInfo sendMediaSideInfo:payload packet:false channelIndex:ZEGOAPI_CHN_MAIN];
}

#pragma mark - callback

- (void)onRecvMediaSideInfo:(NSData *)data ofStream:(NSString *)streamID {
    uint32_t mediaType = ntohl(*(uint32_t*)data.bytes);
    
    if (mediaType == 1001) {
        NSData* realData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:realData options:NSJSONReadingMutableContainers error:nil];
        if ([[result snStringForKey:SceneKey] isEqualToString:SonaScene]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveSeiMessage:streamId:)]) {
                [self.delegate onReceiveSeiMessage:[result snDicForKey:@"data"] streamId:streamID];
            }
        }
    }
}

#pragma mark - getter

- (ZegoMediaSideInfo *)mediaSideInfo {
    if (!_mediaSideInfo) {
        _mediaSideInfo = [ZegoMediaSideInfo new];
        [_mediaSideInfo setMediaSideDelegate:self];
        [_mediaSideInfo setMediaSideFlags:true
                         onlyAudioPublish:false
                            mediaInfoType:SeiZegoDefined
                              seiSendType:SeiSendInVideoFrame
                             channelIndex:ZEGOAPI_CHN_MAIN];
    }
    return _mediaSideInfo;
}


@end
