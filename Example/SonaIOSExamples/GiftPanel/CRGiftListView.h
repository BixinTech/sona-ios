//
//  CRGiftListView.h
//  ChatRoom
//
//  Created by Apple on 2020/7/24.
//

#import <UIKit/UIKit.h>
#import "YuerGiftCell.h"

NS_ASSUME_NONNULL_BEGIN

#define kDefaultCollectViewCellKey @"kDefaultTableViewCellKey"

@class CRGiftModel;


@interface CRRewardGiftSelectorFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) NSUInteger itemCountPerRow;
@property (nonatomic, assign) NSUInteger rowCount;
@property (nonatomic, assign) CGFloat pContentSizeW;
@property (nonatomic, assign) CGFloat pContentSizeH;
@property (nonatomic, assign) NSUInteger pageCount;

@end



@interface CRGiftListView : UIView

@property (nonatomic, copy) NSArray<CRGiftModel *> *listData;

@property (nonatomic, strong) UICollectionView *listView;

@property (nonatomic, copy) void(^onSelectedGift)(CRGiftModel *gift);

@end

NS_ASSUME_NONNULL_END
