//
//  CRPopupView.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRPopupView : UIView

@property (nonatomic, strong) UIView *content;

- (void)show;

- (void)hide;

@end

NS_ASSUME_NONNULL_END
