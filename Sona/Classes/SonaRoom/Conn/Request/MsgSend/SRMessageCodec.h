//
//  SRMessageCodec.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2022/11/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SRMsgSendModel;

@interface SRMessageCodec : NSObject

+ (NSDictionary *)decodeWithData:(NSData *)data error:(NSError **)error;

+ (NSDictionary *)encodeWithModel:(SRMsgSendModel *)model;

@end


NS_ASSUME_NONNULL_END
