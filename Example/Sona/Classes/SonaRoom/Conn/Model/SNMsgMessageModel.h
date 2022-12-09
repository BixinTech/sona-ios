//
//  SNMsgMessageModel.h
//  SonaSDK
//
//  Created by Insomnia on 2020/2/29.
//

#import <Foundation/Foundation.h>
#import "SNModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNMsgMessageModel : SNModel
@property(nonatomic, copy) NSString *message;
@property(nonatomic, copy) NSDictionary *mediaInfo;
@property(nonatomic, copy) NSDictionary *attach;
@end

NS_ASSUME_NONNULL_END
