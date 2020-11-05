//
//  LoginManager.h
//  SealViewer
//
//  Created by LiuLinhong on 2018/08/10.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RCRTCEngine.h>

#define kLoginManager ([LoginManager sharedInstance])


@interface LoginManager : NSObject

@property (nonatomic, strong) NSURL *tokenURL;
@property (nonatomic, assign) BOOL isGPUFilter, isSRTPEncrypt, isTinyStream, isWaterMark , isHost, isAudioScenarioMusic , isVideoMirror, isOpenAudioCrypto, isOpenVideoCrypto;
@property (nonatomic, assign) NSInteger resolutionRatioIndex, frameRateIndex, maxCodeRateIndex, minCodeRateIndex, codingStyleIndex, mediaServerSelectedRow;
@property (nonatomic, strong) NSString *roomNumber, *keyToken, *appKey, *phoneNumber, *userID,*username,*countryCode,*regionName , *liveUrl, *navi;
@property (nonatomic, strong) NSString *selectedServer, *mediaServerURL;
@property (nonatomic, strong, readonly) RCRTCEngine *rongRTCEngine;
@property (nonatomic, assign) BOOL isLoginTokenSucc, isIMConnectionSucc, isAutoTest, isMaster;
@property (nonatomic, assign) BOOL isObserver, isBackCamera, isCloseCamera, isSpeaker, isMuteMicrophone, isSwitchCamera, isWhiteBoardOpen;
@property (nonatomic, strong) NSArray *mediaServerArray;
@property (nonatomic, assign) BOOL isKickOff;
@property (nonatomic, assign) long long kickOffTime;
@property (nonatomic, strong) NSString *kickOffRoomNumber;


@property (nonatomic, assign)BOOL isPrivateEnvironment;
@property (nonatomic, copy)NSString *privateAppKey,*privateAppSecret,*privateNavi,*privateIMServer,*privateAppServer,*privateMediaServer;


+ (LoginManager *)sharedInstance;
- (NSString *)keyTokenFrom:(NSString *)num;

@end
