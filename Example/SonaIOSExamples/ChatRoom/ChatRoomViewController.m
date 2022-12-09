//
//  ChatRoomViewController.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "ChatRoomViewController.h"
#import "ChatRoomViewController+Private.h"
#import "CRMicOperationHandler.h"
#import "CRPublicScreenMessageHandler.h"
#import "CRGiftListRequest.h"
#import "CRGiftModel.h"
#import "CRGiftRewardRequest.h"
#import "CRGiftRewardTarget.h"
#import "CRRewardMessageHandler.h"

static NSString * const cellId = @"msgCell";

#define AVATAR_NAME_PREFIX @"chatroom_img_avatar"

@interface ChatRoomViewController ()

@property (nonatomic, strong) NSMutableArray *receivedMessages;

@property (nonatomic, strong) NSMutableSet<id<CRMessageHandlerProtocol>> *handlers;

@property (nonatomic, strong) CRRoomInfoResult *roomInfo;
@property (weak, nonatomic) IBOutlet UIButton *micBtn;



@end

@implementation ChatRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.receivedMessages = @[].mutableCopy;
    self.handlers = [NSMutableSet new];
    [self registerMessageHandlers];
    [self fetchRoomInfo];
    [self setupUI];
    [self setupSona];
}

- (void)registerMessageHandlers {
    [self.handlers addObject:[[CRMicOperationHandler alloc] initWithChatRoomVC:self]];
    [self.handlers addObject:[CRPublicScreenMessageHandler new]];
    [self.handlers addObject:[[CRRewardMessageHandler alloc] initWithChatRoomVC:self]];
}

- (void)fetchRoomInfo {
    @weakify(self)
    [[[CRRoomInfoRequest fetchRoomInfo:self.roomId] deliverOnMainThread] subscribeNext:^(CRRoomInfoResult *result) {
        @strongify(self)
        [self.giftPanel updateUserList:result.seatList];
        [self setupSeatView:result.seatList];
    } error:^(NSError *error) {
        @strongify(self)
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"进房失败"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:true completion:nil];
        }]];
        [self presentViewController:alert animated:true completion:nil];
    }];
}

- (void)setupUI {
    
    if (self.roomTitle) {
        self.roomTitileLabel.text = self.roomTitle;
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 40;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    
    self.giftPanel = [[CRGiftPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 310)];
    @weakify(self)
    self.giftPanel.onReward = ^(CRGiftRewardTarget * _Nonnull target) {
        @strongify(self)
        [[[CRGiftRewardRequest rewardWithRoomId:self.roomId
                                        fromUid:[CRUserCenter defaultCenter].uid
                                      targetUid:target.targetUid
                                         giftId:target.giftId] deliverOnMainThread] subscribeNext:^(id x) {
            [self.view makeToast:@"打赏成功"];
        } error:^(NSError *error) {
            @strongify(self)
            [self.view makeToast:@"打赏失败"];
        }];
    };
    self.giftPanelContainer = [[CRPopupView alloc] initWithFrame:self.view.bounds];
    self.giftPanelContainer.content = self.giftPanel;
    [self.view addSubview:self.giftPanelContainer];
    
    self.fullScreenAnimation = [ChatRoomFullScreenAnimationView new];
    self.fullScreenAnimation.frame = self.view.bounds;
    [self.view addSubview:self.fullScreenAnimation];
}

- (void)setupSona {
    self.srRoom = [SRRoom new];
    
    SREnterRoomModel *enterModel = [SREnterRoomModel new];
    enterModel.roomId = self.roomId;
    enterModel.uid = [CRUserCenter defaultCenter].uid;
    
    @weakify(self)
    [[self.srRoom enterRoom:enterModel] subscribeNext:^(id x) {
        @strongify(self)
        RACTupleUnpack(NSNumber *type, __unused SNConfigModel *config) = x;
        if ([type intValue] == SRRoomEnterAudioSuccess) {
            /// handle audio case
            [[self.srRoom.audio startPullAllId] subscribeNext:^(id x) {}];
        }
        if ([type intValue] == SRRoomEnterIMSuccess) {
            [[[self.srRoom.conn.msgSubject deliverOnMainThread] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(SNMsgModel *message) {
                @strongify(self)
                NSInteger msgType = [message.msgType intValue];
                [self.handlers enumerateObjectsUsingBlock:^(id<CRMessageHandlerProtocol>  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([obj canHandleMessage:msgType]) {
                        [obj handleMessage:message];
                        NSString *msg = [obj makePublicScreenMessage:message];
                        if (msg) {
                            [self.receivedMessages addObject:msg];
                            [self.tableView reloadData];
                        }
                        *stop = true;
                    }
                }];
            }];
        }
    }];
}

- (void)setupSeatView:(NSArray *)seatList {
    for (int index = 0; index<6; index++) {
        CRSeatView *seatView = [self.seatViewContainer viewWithTag:1000+index];
        if (seatList.count > index) {
            CRRoomInfoSeatModel *model = seatList[index];
            if (model.uid && model.uid.length > 0) {
                model.avatarName = [NSString stringWithFormat:@"%@_%@", AVATAR_NAME_PREFIX, @(index)];
                [seatView bindModel:model];
            } else {
                [seatView bindModel:nil];
            }
        }
    }
}

- (NSInteger)findEmptySeat {
    NSInteger result = NSNotFound;
    for (int index = 0; index<6; index++) {
        CRSeatView *seatView = [self.seatViewContainer viewWithTag:1000+index];
        if (!seatView.model) {
            result = index;
            break;
        }
    }
    return result;
}

#pragma mark - table view delegate & data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.receivedMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.backgroundColor = UIColor.clearColor;
    cell.textLabel.textColor = UIColor.whiteColor;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.text = self.receivedMessages[indexPath.row];
    return cell;
}

#pragma mark - Action

- (IBAction)joinChat:(UIButton *)sender {
    NSInteger index = NSNotFound;
    BOOL isPublishing = sender.selected;
    if (isPublishing) {
        index = self.mySeat.model.index;
    } else {
        index = [self findEmptySeat];
    }
    if (!isPublishing && index == NSNotFound) {
        [self.view makeToast:@"当前无空位置"];
        return;
    }
    sender.selected = !sender.selected;
    // 开始/停止推流
    [[CRMicOperationRequest micOperationWithRoomId:self.roomId uid:[CRUserCenter defaultCenter].uid index:index operate:isPublishing ? 0 : 1] subscribeNext:^(id x) {
        if (isPublishing) {
            [[[self.srRoom.audio stopPublish] deliverOnMainThread] subscribeNext:^(id x) {
                self.micBtn.hidden = true;
            }];
        } else {
            [[[self.srRoom.audio startPublish] deliverOnMainThread] subscribeNext:^(id x) {
                self.micBtn.hidden = false;
            }];
        }
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (IBAction)micOperation:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.mySeat updateMicState:sender.selected];
    if (sender.selected) {
        [[self.srRoom.audio enableMic] subscribeNext:^(id x) {}];
    } else {
        [[self.srRoom.audio unableMic] subscribeNext:^(id x) {}];
    }
}


- (IBAction)openGiftPanel:(id)sender {
    [self.giftPanel reset];
    [self.giftPanelContainer show];
    [self fetchRoomInfo];
    @weakify(self)
    [[[CRGiftListRequest fetchGiftList] deliverOnMainThread] subscribeNext:^(NSArray <CRGiftModel *> *list) {
        @strongify(self)
        [self.giftPanel updateGiftList:list];
    }];
    
}

- (IBAction)sendMessage:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发送消息"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *tf = alert.textFields.firstObject;
        [self realSendMesasge:tf.text];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    }];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)realSendMesasge:(NSString *)content {
    if (!content || content.length == 0) {
        return;
    }
    SRMsgSendModel *model = [SRMsgSendModel new];
    model.msgFormat = SRMsgFormatText;
    model.msgType = @"901";
    NSDictionary *dict = @{@"content":content,@"uid":[CRUserCenter defaultCenter].uid};
    model.content = [dict mj_JSONString];
    model.uid = [CRUserCenter defaultCenter].uid;
    model.roomId = self.roomId;
    
    [[self.srRoom.conn sendMessageWithModel:model] subscribeNext:^(id x) {
        NSLog(@"receive: %@", x);
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (IBAction)closeChatRoom:(id)sender {
    [[self.srRoom leaveRoom] subscribeNext:^(id x) {
        
    }];
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
