//
//  SRChannelConfigModel.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SRChannelConfigModel : NSObject

@property (nonatomic, copy) NSArray<NSString *> *channels;

@property (nonatomic, assign) NSInteger imSendType;

@end

NS_ASSUME_NONNULL_END
