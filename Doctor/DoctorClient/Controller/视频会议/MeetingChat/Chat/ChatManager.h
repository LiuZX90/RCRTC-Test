//
//  MeetingManager.h
//  SealViewer
//
//  Created by LiuLinhong on 2018/08/22.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RCRTCEngine.h>

#import "ChatCellVideoViewModel.h"
#import "LoginManager.h"
#import "ChatRongAudioRTCEncryptorDelegateImpl.h"
#import "ChatRongAudioRTCDecryptorDelegateImpl.h"
#import "ChatRongVideoRTCEncryptorDelegateImpl.h"
#import "ChatRongVideoRTCDecryptorDelegateImpl.h"

@class RCRTCVideoCaptureParam;

#define kChatManager ([ChatManager sharedInstance])
#define kItemRect CGRectMake(0, 0, 112, 84)


@interface ChatManager : NSObject

@property (nonatomic, strong) RCRTCEngine *rongRTCEngine;
@property (nonatomic, strong) RCRTCVideoCaptureParam *videoCaptureParam;
//@property (nonatomic, strong) RCRTCAudioStreamConfig *audioCaptureParam;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSMutableArray *allRemoteUserDataArray, *recentDataArray;
@property (nonatomic, strong) NSMutableArray *observerArray;
@property (nonatomic, strong) ChatCellVideoViewModel *localUserDataModel;
@property (nonatomic, strong) ChatCellVideoViewModel *localFileVideoModel;
@property (nonatomic, strong) NSString *videoOwner;

@property (nonatomic, strong) ChatRongAudioRTCEncryptorDelegateImpl *chatRongAudioRTCEncryptorDelegateImpl;
@property (nonatomic, strong) ChatRongAudioRTCDecryptorDelegateImpl *chatRongAudioRTCDecryptorDelegateImpl;
@property (nonatomic, strong) ChatRongVideoRTCEncryptorDelegateImpl *chatRongVideoRTCEncryptorDelegateImpl;
@property (nonatomic, strong) ChatRongVideoRTCDecryptorDelegateImpl *chatRongVideoRTCDecryptorDelegateImpl;

+ (ChatManager *)sharedInstance;

- (void)clearAllDataArray;

- (ChatCellVideoViewModel *)getRemoteUserDataModelFromIndex:(NSInteger)index;
- (ChatCellVideoViewModel *)getRemoteUserDataModelFromStreamID:(NSString *)streamID;
- (ChatCellVideoViewModel *)getRemoteUserDataModelFromUserID:(NSString *)userID;
- (ChatCellVideoViewModel *)getRemoteUserDataModelSimilarUserID:(NSString *)userID;
- (NSString *)getUserIDOfRemoteUserDataModelFromIndex:(NSInteger)index;
- (NSArray *)getAllRemoteUserIDArray;
- (void)addRemoteUserDataModel:(ChatCellVideoViewModel *)model;
- (void)setRemoteUserDataModel:(ChatCellVideoViewModel *)model atIndex:(NSInteger)index;
- (void)setRemoteModelUsername:(NSString *)userName userId:(NSString *)userId;
- (void)removeRemoteUserDataModelFromStreamID:(NSString *)streamID;
- (void)removeRemoteUserDataModelFromIndex:(NSInteger)index;
- (NSInteger)indexOfRemoteUserDataArray:(NSString *)streamID;
- (NSInteger)countOfRemoteUserDataArray;
- (BOOL)isContainRemoteUserFromStreamID:(NSString *)streamID;
- (BOOL)isContainRemoteUserFromUserID:(NSString *)userId;

- (ChatCellVideoViewModel *)getRecentUserDataModelFromIndex:(NSInteger)index;
- (ChatCellVideoViewModel *)getRecentUserDataModelFromUserID:(NSString *)userID;
- (void)addRecentUserDataModel:(ChatCellVideoViewModel *)model;
- (void)addRecentUserDic:(NSDictionary *)dic;
- (void)removeRecentUserDicFromWebId:(NSString *)webId;
- (void)removeAllRecentUserDic;
- (void)removeRecentUserDataModelFromUserID:(NSString *)userID;
- (NSInteger)indexOfRecentUserDataArray:(NSString *)userID;

- (void)configAudioParameter;
- (void)configVideoParameter;

- (ChatRongAudioRTCEncryptorDelegateImpl *)chatRongAudioRTCEncryptorDelegateImpl;
- (ChatRongAudioRTCDecryptorDelegateImpl *)chatRongAudioRTCDecryptorDelegateImpl;
- (ChatRongVideoRTCEncryptorDelegateImpl *)chatRongVideoRTCEncryptorDelegateImpl;
- (ChatRongVideoRTCDecryptorDelegateImpl *)chatRongVideoRTCDecryptorDelegateImpl;
@end
