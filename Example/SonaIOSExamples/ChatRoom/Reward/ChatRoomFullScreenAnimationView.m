//
//  ChatRoomFullScreenAnimationView.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/28.
//

#import "ChatRoomFullScreenAnimationView.h"
#import "ChatRoomGiftImage.h"
#import <Masonry/Masonry.h>

@interface ChatRoomFullScreenAnimationView ()

@property (nonatomic, strong) YYAnimatedImageView *apngPlayer;

@end

@implementation ChatRoomFullScreenAnimationView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.userInteractionEnabled = false;
    
    self.apngPlayer = [YYAnimatedImageView new];
    self.apngPlayer.autoPlayAnimatedImage = false;
    [self addSubview:self.apngPlayer];
    [self.apngPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.apngPlayer addObserver:self forKeyPath:@"currentIsPlayingAnimation" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentIsPlayingAnimation"]) {
        self.apngPlayer.hidden = ![change[NSKeyValueChangeNewKey] boolValue];
    }
}

- (void)startAnimation {
    self.apngPlayer.hidden = false;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"gift_reward" ofType:@"apng"];
    self.apngPlayer.image = [ChatRoomGiftImage imageWithContentsOfFile:path];
    
    [self.apngPlayer startAnimating];
}

- (void)stopAnimation {
    [self.apngPlayer stopAnimating];
}

@end
