//
//  SRSyncConfigModel.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/8/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SRSyncStreamConfigModel : NSObject

@property (nonatomic, assign) NSInteger bitrate;

@property (nonatomic, copy) NSString *pullMode;

@property (nonatomic, copy) NSString *streamUrl;

@property (nonatomic, copy) NSString *supplier;

@property (nonatomic, copy) NSString *streamId;

@end

@interface SRSyncConfigModel : NSObject

@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, strong) SRSyncStreamConfigModel *streamConfig;

@end

NS_ASSUME_NONNULL_END
