//
//  SNMsgDefine.h
//  SonaSDK
//
//  Created by Insomnia on 2019/12/16.
//

#ifndef SNMsgTypeDefine_h
#define SNMsgTypeDefine_h
typedef NS_ENUM(NSUInteger, SNMsgType) {
    /*! @brief 创建房间 */
    SNMsgTypeCreate = 10000,
    /*! @brief 关闭房间 */
    SNMsgTypeClose = 10001,
    /*! @brief 进入房间 */
    SNMsgTypeEnter =  10002,
    /*! @brief 离开房间 */
    SNMsgTypeLeave =  10003,
    /** 管理*/
    SNMsgTypeAdmin = 10004,
    SNMsgTypeBlock = 10005,
    SNMsgTypeMsgMute = 10006,
    SNMsgTypeKick = 10007,
    SNMsgTypeSwitch = 10008,
    SNMsgTypeStreamMute = 10009,
};

#endif /* SNMsgTypeDefine_h */
