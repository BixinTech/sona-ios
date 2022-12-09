//
//  CRPopupView.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/15.
//

#import "CRPopupView.h"
#import "UIColor+HEX.h"
#import "Masonry.h"

@interface CRPopupView ()<UIGestureRecognizerDelegate>

@end

@implementation CRPopupView

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
    self.hidden = true;
    self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
}

- (void)onTapGesture {
    [self hide];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isEqual:self]) {
        return YES;
    }
    return NO;
}


- (void)setContent:(UIView *)content {
    if (!content) {
        return;
    }
    _content = content;
    [self addSubview:content];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).offset(content.frame.size.height);
        make.size.mas_equalTo(content.frame.size);
    }];
}

- (void)show {
    self.hidden = false;
    [UIView animateWithDuration:0.3 animations:^{
        [self.content mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).offset(-self.safeAreaInsets.bottom);
        }];
        [self layoutIfNeeded];
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        [self.content mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).offset(self.content.frame.size.height);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            self.hidden = true;
        }
    }];
}

@end
