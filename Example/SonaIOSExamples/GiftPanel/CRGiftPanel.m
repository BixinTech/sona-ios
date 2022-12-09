//
//  CRGiftPanel.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/15.
//

#import "CRGiftPanel.h"
#import "CRGiftListView.h"
#import "CRGiftUserListView.h"
#import "UIColor+HEX.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "Masonry.h"
#import "CRGiftModel.h"
#import "CRRoomInfoResult.h"
#import "CRGiftRewardTarget.h"

@interface CRGiftPanel ()

@property (nonatomic, strong) CRGiftUserListView *userList;

@property (nonatomic, strong) CRGiftListView *giftList;

@property (nonatomic, strong) UIButton *rewardButton;

@property (nonatomic, copy) NSString *rewardUid;

@property (nonatomic, strong) CRGiftModel *rewardGift;


@end

@implementation CRGiftPanel

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self addSubview:blurView];
    [blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];

    self.userList = [[CRGiftUserListView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 58)];
    @weakify(self)
    self.userList.onSelectedSeat = ^(NSString *uid) {
        @strongify(self)
        self.rewardUid = uid;
        [self updateRewardButtonState];
    };
    [self addSubview:self.userList];
    
    self.giftList = [[CRGiftListView alloc] initWithFrame:CGRectMake(0, 60, UIScreen.mainScreen.bounds.size.width, 206)];
    self.giftList.onSelectedGift = ^(CRGiftModel * _Nonnull gift) {
        @strongify(self)
        self.rewardGift = gift;
        [self updateRewardButtonState];
    };
    self.giftList.backgroundColor = UIColor.clearColor;
    [self addSubview:self.giftList];
    
    self.rewardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rewardButton.backgroundColor = [UIColor colorWithHexString:@"#FE3D9C"];
    self.rewardButton.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width - 70, self.giftList.frame.origin.y + 206 + 5, 60, 30);
    [self.rewardButton setTitle:@"赠送" forState:UIControlStateNormal];
    self.rewardButton.layer.cornerRadius = 13.f;
    self.rewardButton.layer.masksToBounds = YES;
    self.rewardButton.alpha = 0.5;
    [self.rewardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.rewardButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [[self.rewardButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        CRGiftRewardTarget *target = [CRGiftRewardTarget new];
        target.targetUid = self.rewardUid;
        target.giftId = self.rewardGift.giftId;
        !self.onReward ? : self.onReward(target);
    }];
    [self addSubview:self.rewardButton];
}

- (void)updateUserList:(NSArray<CRRoomInfoSeatModel *> *)seatList {
    NSMutableArray *available = @[].mutableCopy;
    [seatList enumerateObjectsUsingBlock:^(CRRoomInfoSeatModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.uid && obj.uid.length != 0) {
            [available addObject:obj];
        }
    }];
    [self.userList updateModel:available.copy];
}

- (void)updateGiftList:(NSArray <CRGiftModel *> *)giftList {
    self.giftList.listData = giftList;
}

- (void)updateRewardButtonState {
    BOOL enable = self.rewardUid && self.rewardGift;
    self.rewardButton.alpha = enable ? 1 : 0.5;
    self.rewardButton.enabled = enable;
    
}

- (void)reset {
    self.rewardGift = nil;
    self.rewardUid = nil;
    [self updateRewardButtonState];
}

@end
