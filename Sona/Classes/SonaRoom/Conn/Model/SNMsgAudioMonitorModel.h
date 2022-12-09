//
//  SNMsgAudioMonitorModel.h
//  SonaRoom
//
//  Created by Insomnia on 2020/8/10.
//

#import <Foundation/Foundation.h>
#import "SNMsgModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SNMsgAudioMonitorModel : SNMsgModel
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSArray <NSString *> *streamIds;
@end

NS_ASSUME_NONNULL_END
