//
//  SNMsgMuteModel.h
//  SonaSDK
//
//  Created by Insomnia on 2019/12/17.
//

#import <Foundation/Foundation.h>
#import "SNMsgModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNMsgMuteModel : SNMsgModel
@property(nonatomic, assign) BOOL isMute;
@property(nonatomic, assign) NSInteger duration;
@end

NS_ASSUME_NONNULL_END
