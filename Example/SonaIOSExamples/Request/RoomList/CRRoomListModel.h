//
//  CRRoomListModel.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRRoomListItem : NSObject

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, copy) NSString *name;

@end

@interface CRRoomListModel : NSObject

@property (nonatomic, copy) NSArray<CRRoomListItem *> *list;

@end

NS_ASSUME_NONNULL_END
