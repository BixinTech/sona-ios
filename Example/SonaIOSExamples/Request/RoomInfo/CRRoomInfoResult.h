//
//  CRRoomInfoResult.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRRoomInfoSeatModel : NSObject

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, copy) NSString *avatarName;

@end

@interface CRRoomInfoResult : NSObject

@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSArray<CRRoomInfoSeatModel *> *seatList;

@end

NS_ASSUME_NONNULL_END
