//
//  ChatRoomListViewController.m
//  SonaIOSExamples
//
//  Created by Ju Liaoyuan on 2022/11/14.
//

#import "ChatRoomListViewController.h"
#import "SRRoom.h"
#import "CRRoomListRequest.h"
#import "CRUserCenter.h"
#import "Toast.h"
#import "ChatRoomViewController.h"
#import "Toast.h"

static NSString * const cellId = @"roomList";

@interface ChatRoomListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, copy) NSArray<CRRoomListItem *> *roomList;

@property (nonatomic, strong) SRRoom *srRoom;

@end

@implementation ChatRoomListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self fetchRoomList];
}

- (void)setup {
    
    self.title = @"房间列表";
    
    self.srRoom = [SRRoom new];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
}

- (void)fetchRoomList {
    [[[CRRoomListRequest fetchList] deliverOnMainThread] subscribeNext:^(NSArray <CRRoomListItem *> *list) {
        self.roomList = list;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        [self.view makeToast:error.localizedFailureReason];
    }];
}

- (IBAction)createRoom:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"创建房间"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *tf = alert.textFields.firstObject;
        
        SRCreateRoomModel *model = [SRCreateRoomModel new];
        model.productCode = @"CHATROOM";
        model.roomTitle = tf.text;
        model.uid = [CRUserCenter defaultCenter].uid;
        model.password = @"";
        @weakify(self)
        [[[self.srRoom createRoomWithModel:model] deliverOnMainThread] subscribeNext:^(id x) {
            @strongify(self)
            [self showEnterRoomAlert:x[@"roomId"] roomTitle:tf.text];
        } error:^(NSError *error) {
            [self.view makeToast:[NSString stringWithFormat:@"创建失败, reason: %@", error.localizedFailureReason]];
        }];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入房间名字";
    }];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)showEnterRoomAlert:(NSString *)roomId roomTitle:(NSString *)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"创建成功"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"立即进入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self enterRoom:roomId roomTitle:title];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}]];
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark - table view delegate & data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    CRRoomListItem *item = self.roomList[indexPath.row];
    cell.textLabel.text = item.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CRRoomListItem *item = self.roomList[indexPath.row];
    [self enterRoom:item.roomId roomTitle:item.name];
}

#pragma mark - enter room

- (void)enterRoom:(NSString *)roomId roomTitle:(NSString *)roomTitle {
    ChatRoomViewController *chatRoom = [ChatRoomViewController new];
    chatRoom.roomId = roomId;
    chatRoom.roomTitle = roomTitle;
    chatRoom.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:chatRoom animated:true completion:nil];
}

@end
