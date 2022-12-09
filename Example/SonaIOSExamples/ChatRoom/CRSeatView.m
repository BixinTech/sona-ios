//
//  CRSeatView.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "CRSeatView.h"
#import "CRRoomInfoResult.h"

#define EMPTY_SEAT_NAME @"我要上麦"
#define EMPTY_SEAT_IMAGE [UIImage imageNamed:@"cr_seat_bg"]

@interface CRSeatView ()

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIButton *micBtn;

@property (nonatomic, strong) CRRoomInfoSeatModel *model;

@end

@implementation CRSeatView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

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
    self.avatar = [UIImageView new];
    self.avatar.frame = CGRectMake(0, 0, 55, 55);
    self.avatar.layer.cornerRadius = 55/2.0;
    self.avatar.layer.masksToBounds = true;
    self.avatar.image = EMPTY_SEAT_IMAGE;
    [self addSubview:self.avatar];
    
    self.nameLabel = [UILabel new];
    self.nameLabel.frame = CGRectMake(0, 61, 55, 14);
    self.nameLabel.textColor = UIColor.whiteColor;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:10];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.text = EMPTY_SEAT_NAME;
    [self addSubview:self.nameLabel];
    
    self.micBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.micBtn.frame = CGRectMake(36, 36, 18, 18);
    self.micBtn.hidden = true;
    [self.micBtn setImage:[UIImage imageNamed:@"mic_open"] forState:UIControlStateSelected];
    [self.micBtn setImage:[UIImage imageNamed:@"mic_close"] forState:UIControlStateNormal];
    [self addSubview:self.micBtn];
}

- (void)bindModel:(CRRoomInfoSeatModel *)model {
    self.model = model;
    if (model.uid && model.uid.length != 0) {
        self.nameLabel.text = [NSString stringWithFormat:@"用户%@", model.uid];
    } else {
        self.nameLabel.text = EMPTY_SEAT_NAME;
    }
    self.avatar.image = [UIImage imageNamed:model.avatarName] ? : EMPTY_SEAT_IMAGE;
}

- (void)setShowMicBtn:(BOOL)showMicBtn {
    _showMicBtn = showMicBtn;
    self.micBtn.hidden = !showMicBtn;
}

- (void)updateMicState:(BOOL)enabled {
    self.micBtn.selected = enabled;
}

@end
