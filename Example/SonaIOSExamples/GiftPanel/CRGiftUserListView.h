//
//  CRGiftUserListView.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CRRoomInfoSeatModel;

@interface CRGiftUserListView : UIView

@property(nonatomic, strong) UICollectionView *rewardUsersList;
@property(nonatomic, strong) UIView *offSeatRewardBgView;
@property(nonatomic, strong) UILabel *sendLabel;
@property(nonatomic, strong) UIImageView *avatarImageView;
@property(nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *cornerBgView;

@property (nonatomic, strong) void(^onSelectedSeat)(NSString *uid);

- (void)updateModel:(NSArray<CRRoomInfoSeatModel *> *)seatList;

@end

NS_ASSUME_NONNULL_END
