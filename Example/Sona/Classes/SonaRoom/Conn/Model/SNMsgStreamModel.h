//
//  SNMsgStreamModel.h
//  SonaSDK
//
//  Created by Insomnia on 2019/12/17.
//

#import <Foundation/Foundation.h>
#import "SNMsgModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNMsgStreamModel : SNMsgModel
@property(nonatomic, copy) NSString *streamId;
@property(nonatomic, copy) NSString *accId;
@property(nonatomic, assign) BOOL setStream;
@end

NS_ASSUME_NONNULL_END
