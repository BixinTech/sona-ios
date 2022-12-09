//
//  SNMsgTypeStreamSpecificModel.h
//  SonaSDK
//
//  Created by Insomnia on 2019/12/25.
//

#import <Foundation/Foundation.h>
#import "SNMsgModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNMsgStreamSpecificModel : SNMsgModel
@property(nonatomic, copy) NSArray <NSString *> *streamList;
@property(nonatomic, copy) NSArray <NSString *> *accIdList;
@property(nonatomic, copy) NSArray <NSString *> *receive;
@property(nonatomic, copy) NSArray <NSString *> *abort;
@end

NS_ASSUME_NONNULL_END
