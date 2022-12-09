//
//  SNSDKPluginProtocol.h
//  SonaRoom
//
//  Created by zhuhanwei on 2020/5/19.
//

#import <Foundation/Foundation.h>
#import "SNConfigModel.h"

typedef NS_ENUM(NSInteger, SNSDKPluginType) {
    SNSDKPluginTypeVideo = 0,
    SNSDKPluginTypeAudio,
    SNSDKPluginTypeVideoChat
};

NS_ASSUME_NONNULL_BEGIN

@protocol SNSDKPluginProtocol <NSObject>

- (SNSDKPluginType)pluginType;

@end

NS_ASSUME_NONNULL_END
