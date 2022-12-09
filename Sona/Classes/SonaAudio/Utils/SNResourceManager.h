//
//  SNResourceManager.h
//  SonaAudio
//
//  Created by Ju Liaoyuan on 2022/1/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SNResourceManager : NSObject

+ (NSString *)pathForResource:(NSString *)name type:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
