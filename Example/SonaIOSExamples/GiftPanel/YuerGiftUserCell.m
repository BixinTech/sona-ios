//
//  YuerGiftUserCell.m
//  YppGift
//
//  Created by ypp_ios001 on 2018/9/4.
//

#import "Masonry.h"
#import "YuerGiftUserCell.h"
#import "UIColor+HEX.h"
#import "CRRoomInfoResult.h"

@interface YuerGiftUserCell ()

@property (nonatomic, strong) UIImageView *avatar;

@property (nonatomic, strong) UIView *avatarBg;

@end

@implementation YuerGiftUserCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.avatarBg = [UIView new];
    self.avatarBg.hidden = YES;
    self.avatarBg.userInteractionEnabled = false;
    self.avatarBg.backgroundColor = [UIColor clearColor];
    self.avatarBg.layer.cornerRadius = 22.0f;
    self.avatarBg.layer.borderWidth = 1.0f;
    self.avatarBg.layer.borderColor = [UIColor colorWithHexString:@"#FE3D9C"].CGColor;
    [self.contentView addSubview:self.avatarBg];
    [self.avatarBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.center.equalTo(self.contentView);
    }];
    
    
    self.avatar = [[UIImageView alloc] init];
    self.avatar.backgroundColor = UIColor.yellowColor;
    self.avatar.layer.cornerRadius = 20.f;
    self.avatar.layer.masksToBounds = true;
    [self.contentView addSubview:self.avatar];
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.center.equalTo(self.contentView);
    }];
}

- (void)bindModel:(CRRoomInfoSeatModel *)model {
    self.avatarBg.hidden = !model.selected;
    self.avatar.image = [UIImage imageNamed:[NSString stringWithFormat:@"chatroom_img_avatar_%@", @(model.index)]];
}

@end
