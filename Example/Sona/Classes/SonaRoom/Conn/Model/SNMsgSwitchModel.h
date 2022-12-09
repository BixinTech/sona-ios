//
//  SNMsgSwitchModel.h
//  SonaSDK
//
//  Created by Insomnia on 2020/3/11.
//

#import <Foundation/Foundation.h>
#import "SNModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNMsgSwitchModel : SNModel
@property (nonatomic, copy) NSString *roomId;
@property(nonatomic, copy) NSString *supplier;
@property(nonatomic, copy) NSString *pullMode;
@property(nonatomic, copy) NSString *pushMode;
@property(nonatomic, copy) NSString *streamUrl;
@property(nonatomic, copy) NSString *streamId;
@property (nonatomic, assign) NSInteger bitrate;
@property (nonatomic, assign) NSInteger playerType;
@end

NS_ASSUME_NONNULL_END
