//
//  SRStreamMixVideoRequestSignal.m
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/4/16.
//

#import "SRStreamMixVideoRequestSignal.h"
#import "SRRequestClient.h"

@implementation SRStreamMixVideoRequestSignal

+ (RACSignal *)mixedVideo:(BOOL)enabled roomId:(NSString *)roomId size:(CGSize)size {
    SRRequest *request = [[SRRequest alloc] initWithMethod:SNRequestMethodPOST];
    request.url = @"/sona/stream/mixed/mv";
    request.arg = @{@"mixStatus":enabled ? @(1) : @(2),
                    @"roomId": roomId ? : @"",
                    @"width":size.width <= 0 ? @1 : @((int)size.width),
                    @"height":size.height <= 0 ? @1 :@((int)size.height)
    };
    return [[SRRequestClient shareInstance] signalWithRequest:request];
}

@end
