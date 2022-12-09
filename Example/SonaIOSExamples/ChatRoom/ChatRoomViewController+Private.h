//
//  ChatRoomViewController+Private.h
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/24.
//

#import "ChatRoomViewController.h"
#import "SRRoom.h"
#import "CRUserCenter.h"
#import "CRMicOperationRequest.h"
#import "CRGiftPanel.h"
#import "CRPopupView.h"
#import "CRRoomInfoRequest.h"
#import "CRRoomInfoResult.h"
#import "CRSeatView.h"
#import "Toast.h"
#import "CRMessageConstant.h"
#import "ChatRoomFullScreenAnimationView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatRoomViewController ()

@property (weak, nonatomic) IBOutlet UILabel *roomTitileLabel;
@property (weak, nonatomic) IBOutlet UIView *seatViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) SRRoom *srRoom;

@property (nonatomic, strong) CRGiftPanel *giftPanel;

@property (nonatomic, strong) CRPopupView *giftPanelContainer;

@property (nonatomic, weak) CRSeatView *mySeat;

@property (nonatomic, strong) ChatRoomFullScreenAnimationView *fullScreenAnimation;

@end

NS_ASSUME_NONNULL_END
