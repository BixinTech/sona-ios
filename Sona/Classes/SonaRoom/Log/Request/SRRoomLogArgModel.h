//
//  SRRoomLogArgModel.h
//  SonaRoom
//
//  Created by Insomnia on 2020/1/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SRRoomLogArgModel : NSObject
@property (nonatomic, copy) NSString *roomId;
@property(nonatomic, copy) NSString *uid;
@property(nonatomic, copy, nullable) NSString *streamId;
@property(nonatomic, copy) NSString *sdkCode;
@property(nonatomic, copy) NSDictionary *info;
@property(nonatomic, copy) NSString *desc;
@end

NS_ASSUME_NONNULL_END
