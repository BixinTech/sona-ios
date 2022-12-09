//
//  SNEventSignpost.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2021/8/24.
//

#import <Foundation/Foundation.h>

@class RACSubject;

NS_ASSUME_NONNULL_BEGIN

@interface SNEventSignpost : NSObject

- (void)begin:(NSString *)eventName ext:(NSDictionary *)ext;

- (void)end:(NSString *)eventName;

- (void)begin:(NSString *)eventName spid:(NSString *)spid ext:(NSDictionary *)ext;

- (void)end:(NSString *)eventName spid:(NSString *)spid;




@end

NS_ASSUME_NONNULL_END
