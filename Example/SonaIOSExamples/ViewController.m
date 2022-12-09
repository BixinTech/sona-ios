//
//  ViewController.m
//  SonaIOSExamples
//
//  Created by zhaohuazhao on 2022/8/30.
//

#import "ViewController.h"
#import "ChatRoomListViewController.h"
#import "SNConfigurator.h"
#import "MCRConfigurator.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SNConfigurator configurator].requestAddress = <#your host address#>
    [[MCRConfigurator configurator] setupAddress:^MCRSocketAddress * _Nullable{
        return [MCRSocketAddress addressWithHost:<#your host address#> andPort:2180];
    }];
}

#pragma mark - Funcs

- (IBAction)createRoom:(id)sender {
    ChatRoomListViewController *roomList = [ChatRoomListViewController new];
    [self.navigationController pushViewController:roomList animated:true];
}

@end

