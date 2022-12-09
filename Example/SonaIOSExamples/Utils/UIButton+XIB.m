//
//  UIButton+XIB.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "UIButton+XIB.h"

@implementation UIButton (XIB)

- (void)setBorderUIColor:(UIColor *)color {
    self.layer.borderColor = color.CGColor;
}

- (UIColor *)borderUIColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}


@end
