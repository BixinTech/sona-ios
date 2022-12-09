//
//  SNConstant.h
//  SonaRoom
//
//  Created by Ju Liaoyuan on 2021/4/29.
//

#ifndef SNConstant_h
#define SNConstant_h

static NSString * const SNPlayerErrorDomain = @"com.sona.player";

typedef NS_ENUM(NSInteger, SNVoiceReverbMode) {
    /** 关闭混响 */
    SNVoiceReverbModeOff = 0,
    /** 房间模式 */
    SNVoiceReverbModeSoftRoom = 1,
    /** 俱乐部（大房间）模式 */
    SNVoiceReverbModeWarmClub = 2,
    /** 音乐厅模式 */
    SNVoiceReverbModeConcertHall = 3,
    /** 大教堂模式 */
    SNVoiceReverbModeLargeAuditorium = 4,
    /** 录音棚 */
    SNVoiceReverbModeRecordingStudio = 5,
    /** 地下室 */
    SNVoiceReverbModeBasement = 6,
    /** KTV */
    SNVoiceReverbModeKTV = 7,
    /** 流行 */
    SNVoiceReverbModePopular = 8,
    /** 摇滚 */
    SNVoiceReverbModeRock = 9,
    /** 演唱会 */
    SNVoiceReverbModeVocalConcert = 10,
    /** 嘻哈 */
    SNVoiceReverbModeHipHop = 11,
    /** 飘渺（空旷）*/
    SNVoiceReverbModeMisty = 12,
    /** 3D人声 */
    SNVoiceReverbMode3DVoice = 13,
    /** 留声机 */
    SNVoiceReverbModeGramophone = 14,
};

typedef NS_ENUM(NSInteger, SNAudioStreamType) {
    SNAudioStreamTypeMixed = 1,
    SNAudioStreamTypeMulti = 2,
};

typedef NS_ENUM(NSInteger, SRDeviceMode) {
    /// 普通模式。麦上麦下都走媒体模式。不会开启系统的AEC，音质高。
    SRDeviceModeGeneral,
    
    /// 通话模式。麦上通话模式，麦下媒体模式。会先经过系统AEC，音质会劣于 General 。
    SRDeviceModeCommunication
};

#endif /* SNConstant_h */
