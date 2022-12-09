//
//  SRMonitorStreamReqSig.h
//  SonaRoom
//
//  Created by Insomnia on 2020/8/10.
//

#import <Foundation/Foundation.h>

@class RACSignal;

NS_ASSUME_NONNULL_BEGIN

@interface SRMonitorStreamReqSig : NSObject

+ (RACSignal *)monitorStreamWith:(NSDictionary *)arg;

@end

NS_ASSUME_NONNULL_END
