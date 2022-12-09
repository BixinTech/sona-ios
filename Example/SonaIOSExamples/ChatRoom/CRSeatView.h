//
//  CRSeatView.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CRRoomInfoSeatModel;

@interface CRSeatView : UIView

@property (nonatomic, strong, readonly) CRRoomInfoSeatModel *model;

@property (nonatomic, assign) BOOL showMicBtn;

- (void)bindModel:(CRRoomInfoSeatModel * _Nullable)model;

- (void)updateMicState:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
