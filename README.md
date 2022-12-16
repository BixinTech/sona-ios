# Sona
Sona 平台是一个搭建语音房产品的全端解决方案，包含了房间管理、实时音视频、房间IM、长连接网关等能力。其中，Sona-iOS 是 Sona 在 iOS 端的实现。


# Get Started

## 1. 安装

Sona-iOS 支持源码及 CocoaPods 集成。


### 1.1 源码集成

1. 下载本仓库代码，将 Sona 文件夹拖入到工程中。
2. 添加相关依赖：
    1. ZegoLiveRoom
    2. Mercury-iOS
    3. TXLiteAVSDK_Professional
    4. MJExtension
    5. ReactiveObjC

### 1.2 CocoaPods 集成

1. 在 Podfile 中添加 Sona 
  ```
  pod 'Sona'
  ```
2. 在 Podfile 中添加 Sona 依赖

  ```
  pod 'ZegoLiveRoom',  '6.16.3.25579' // 可根据自身设置依赖的版本，请确保 API 的兼容
  pod 'TXLiteAVSDK_Professional', '10.8.12025' // 可根据自身设置依赖的版本，请确保 API 的兼容

  pod 'Masonry'
  pod 'YYImage'
  pod 'Toast', '4.0.0'
  pod 'AFNetworking', '4.0.1'
  pod 'MJExtension', '3.4.1'
  pod 'ReactiveObjC', '3.1.1'
  ```
3. 执行 `pod install`

*注意，因为使用了 xcframework，请确保本地 CocoaPods 版本在 1.10.2 及以上*

## 2. 使用

### 2.1 初始化 Sona

```
#import "SRRoom.h"

self.srRoom = [SRRoom new];
```

### 2.2 创建房间

```
SRCreateRoomModel *model = [SRCreateRoomModel new];
model.productCode = @"CHATROOM";
model.roomTitle = @"Sona Demo";
model.uid = @"your user id";
model.password = @"";

[[[self.srRoom createRoomWithModel:model] deliverOnMainThread] subscribeNext:^(id x) {
    @strongify(self)
    // handle success
} error:^(NSError *error) {
    // handle error
}];

```

### 2.3 进入房间

```
SREnterRoomModel *enterModel = [SREnterRoomModel new];
enterModel.roomId = @"your room id";
enterModel.uid = @"your user id"

[[self.srRoom enterRoom:enterModel] subscribeNext:^(id x) {
    RACTupleUnpack(NSNumber *type, __unused SNConfigModel *config) = x;
    if ([type intValue] == SRRoomEnterAudioSuccess) {
        // handle audio        
    }
    if ([type intValue] == SRRoomEnterIMSuccess) {
        // handle im 
    }
}];

进房结果会分多次回调，根据 type 来区分是 Audio 或者 IM 进入成功，再进一步业务处理。

```

### 2.4 拉流

在合适的时机，通过调用

```
[[self.srRoom.audio startPullAllId] subscribeNext:^(id x) {}];
```

来拉流，Sona 内部会根据配置来决定是拉单流还是混流。上层调用方无需关心。

### 2.5 推流

通过调用

```
[[self.srRoom.audio startPublish] subscribeNext:^(id x) {
                
}];

```
来发起推流。

### 2.6 消息收发


在 enterRoom 成功回调 SRRoomEnterIMSuccess 后，即可发送消息：

```
SRMsgSendModel *model = [SRMsgSendModel new];
model.msgFormat = SRMsgFormatText;
model.msgType = @"123";
model.content = @"your message";
model.uid = @"your uid";
model.roomId = @"your room id";

[[self.srRoom.conn sendMessageWithModel:model] subscribeNext:^(id x) {
  // send success
} error:^(NSError *error) {
  // send fail
}];

```
其他端，通过监听消息回调（需要保证在进入IM房间成功后）来获取对端发送的内容：
```
[[self.srRoom.conn.msgSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(SNMsgModel *message) {
    // parse message
}];

```

### 2.7 离开房间

当用户退出时，通过调用

```
[[self.srRoom leaveRoom] subscribeNext:^(id x) {
        
}];
```
来离开 Sona，Sona内部会进行反初始化，释放相关资源。

### 2.8 其他

其他能力，参考 [Wiki](https://github.com/BixinTech/sona-ios/wiki)


# Sona Demo 体验

基于以上的使用文档，Sona 提供了一个 Demo 供参考。Demo 中实现了一个简易版的聊天室，涵盖了 Sona 的音视频能力、IM 能力，并进一步实现了简化版的公屏消息，礼物打赏等功能。欢迎下载体验。

## 环境安装
在体验 Sona 前，需要确保以下依赖环境正常：

1. Xcode 12 及以上
2. CocoaPods 1.10.2 及以上

## 运行 Demo

1. 下载源码
 ```
 $ git clone https://github.com/BixinTech/sona-ios.git
 ```
2. 安装依赖
  ```
  $ cd Example && pod install
  ```
3. 编译并启动

需要注意的是，需要你提供 Sona 后端的服务地址。

# License

Mercury is Apache 2.0 licensed, as found in the [LICENSE](https://github.com/BixinTech/sona-ios/blob/main/LICENSE) file.
