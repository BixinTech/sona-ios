//
//  SNMsgMuteModel.h
//  SonaSDK
//
//  Created by Insomnia on 2019/12/17.
//

#import <Foundation/Foundation.h>
#import "SNMsgModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNMsgStreamMuteItemModel : NSObject
@property(nonatomic, copy) NSString *uid;
@property(nonatomic, copy) NSString *streamId;
@property(nonatomic, copy) NSString *accId;
@end;

@interface SNMsgStreamMuteModel : SNMsgModel
@property(nonatomic, assign) BOOL isMute;
@property(nonatomic, copy) NSArray <SNMsgStreamMuteItemModel *> *streamList;
@end

NS_ASSUME_NONNULL_END
