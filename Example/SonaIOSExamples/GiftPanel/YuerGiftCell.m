//
//  YuerGiftCell.m
//  YppGift
//
//  Created by ypp_ios001 on 2018/9/3.
//

#import "YuerGiftCell.h"
#import "Masonry.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "UIColor+HEX.h"
#import "CRGiftModel.h"

@interface YuerGiftCell()

@property (nonatomic, strong) UIImageView *giftImageView;

@property (nonatomic, strong) UILabel *giftNameLabel;

@property (nonatomic, strong) UILabel *giftPriceLabel;

@property (nonatomic, strong) UIImageView *giftSelectBg;

@end

@implementation YuerGiftCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.giftImageView = [UIImageView new];
    self.giftImageView.image = [UIImage imageNamed:@"cr_gift_img"];
    [self.contentView addSubview:self.giftImageView];
    [self.giftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5.f);
        make.size.mas_equalTo(CGSizeMake(40.f, 40.f));
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
    }];
    
    self.giftSelectBg = [UIImageView new];
    self.giftSelectBg.image = [UIImage imageNamed:@"cr_gift_board_select_frame"];
    [self.contentView addSubview:self.giftSelectBg];
    [self.giftSelectBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    self.giftNameLabel = [UILabel new];
    self.giftNameLabel.textColor = UIColor.whiteColor;
    self.giftNameLabel.font = [UIFont systemFontOfSize:12];
    self.giftNameLabel.textAlignment= NSTextAlignmentCenter;
    [self.contentView addSubview:self.giftNameLabel];
    [self.giftNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.giftImageView.mas_bottom).mas_offset(3.f);
    }];
    
    self.giftPriceLabel = [UILabel new];
    self.giftPriceLabel.textColor = UIColor.whiteColor;
    self.giftPriceLabel.font = [UIFont systemFontOfSize:10];
    self.giftPriceLabel.textAlignment= NSTextAlignmentCenter;
    [self.contentView addSubview:self.giftPriceLabel];
    [self.giftPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.giftNameLabel.mas_bottom).mas_offset(3.f);
    }];
    
}

#pragma mark - Public Methods

- (void)bindModel:(CRGiftModel *)model {
    self.giftSelectBg.hidden = !model.selected;
    self.giftPriceLabel.text = model.price;
    self.giftNameLabel.text = model.giftName;
}

@end
