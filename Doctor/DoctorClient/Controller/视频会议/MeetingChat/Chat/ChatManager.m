//
//  MeetingManager.m
//  SealViewer
//
//  Created by LiuLinhong on 2018/08/22.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "ChatManager.h"

#import "RCRTCVideoCaptureParam.h"


static ChatManager *sharedMeetingManager = nil;

@implementation ChatManager

+ (ChatManager *)sharedInstance
{
    static dispatch_once_t once_dispatch;
    dispatch_once(&once_dispatch, ^{
        sharedMeetingManager = [[ChatManager alloc] init];
    });
    return sharedMeetingManager;
}

- (RCRTCEngine *)rongRTCEngine
{
    return kLoginManager.rongRTCEngine;
}

- (void)clearAllDataArray
{
    _localUserDataModel = nil;
    [_allRemoteUserDataArray removeAllObjects];
    [_recentDataArray removeAllObjects];
}

#pragma mark - 全部远端用户
- (NSMutableArray *)allRemoteUserDataArray
{
    if (!_allRemoteUserDataArray)
        _allRemoteUserDataArray = [NSMutableArray array];
    
    return _allRemoteUserDataArray;
}

- (ChatCellVideoViewModel *)getRemoteUserDataModelFromIndex:(NSInteger)index
{
    ChatCellVideoViewModel *model = self.allRemoteUserDataArray[index];
    return model;
}

- (ChatCellVideoViewModel *)getRemoteUserDataModelFromStreamID:(NSString *)streamID
{
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        if ([model.streamID isEqualToString:streamID])
            return model;
    }
    
    return nil;
}

- (ChatCellVideoViewModel *)getRemoteUserDataModelFromUserID:(NSString *)userID
{
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        if ([model.userID isEqualToString:userID])
            return model;
    }
    return nil;
}

- (void)setRemoteModelUsername:(NSString *)userName userId:(NSString *)userId{
    if (userId.length <= 0) {
        return;
    }
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        NSRange range = [model.streamID rangeOfString:@"_" options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            NSString* uid = [model.streamID substringToIndex:range.location];
            if ([uid isEqualToString:userId]) {
                model.userName = userName;
            }
        }
    }
}

- (ChatCellVideoViewModel *)getRemoteUserDataModelSimilarUserID:(NSString *)userID
{
    if (userID.length <= 0) {
        return nil;
    }
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        NSRange range =  [model.streamID rangeOfString:@"_" options:NSLiteralSearch];
        if (range.location != NSNotFound) {
            NSString* uid = [model.streamID substringToIndex:range.location];
            if ([uid isEqualToString:userID]) {
                return model;
            }
        }
    }
    return nil;
}

- (NSString *)getUserIDOfRemoteUserDataModelFromIndex:(NSInteger)index
{
    ChatCellVideoViewModel *model = self.allRemoteUserDataArray[index];
    return model.streamID;
}

- (NSArray *)getAllRemoteUserIDArray
{
    NSMutableArray *userIDArray = [NSMutableArray array];
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        [userIDArray addObject:model.userID];
    }
    return userIDArray;
}

- (void)addRemoteUserDataModel:(ChatCellVideoViewModel *)model
{
    [self.allRemoteUserDataArray addObject:model];
}

- (void)setRemoteUserDataModel:(ChatCellVideoViewModel *)model atIndex:(NSInteger)index
{
    [_allRemoteUserDataArray insertObject:model atIndex:index];
}

- (void)removeRemoteUserDataModelFromStreamID:(NSString *)streamID
{
    for (ChatCellVideoViewModel *model in _allRemoteUserDataArray)
    {
        if ([model.streamID isEqualToString:streamID])
        {
            [self.allRemoteUserDataArray removeObject:model];
            break;
        }
    }
}

- (void)removeRemoteUserDataModelFromIndex:(NSInteger)index
{
    [_allRemoteUserDataArray removeObjectAtIndex:index];
}

- (NSInteger)indexOfRemoteUserDataArray:(NSString *)streamID
{
    for (NSInteger i = 0; i < [self.allRemoteUserDataArray count]; i++)
    {
        ChatCellVideoViewModel *model = self.allRemoteUserDataArray[i];
        if ([model.streamID isEqualToString:streamID])
            return i;
    }
    return -1;
}

- (NSInteger)countOfRemoteUserDataArray
{
    return [self.allRemoteUserDataArray count];
}

- (BOOL)isContainRemoteUserFromStreamID:(NSString *)streamID
{
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        if ([model.streamID isEqualToString:streamID])
            return YES;
    }
    return NO;
}

- (BOOL)isContainRemoteUserFromUserID:(NSString *)userId
{
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        if ([model.userID isEqualToString:userId])
            return YES;
    }
    return NO;
}


#pragma mark - 最近浏览
- (NSMutableArray *)recentDataArray
{
    if (!_recentDataArray)
        _recentDataArray = [NSMutableArray array];
    
    return [_recentDataArray mutableCopy];
}

- (ChatCellVideoViewModel *)getRecentUserDataModelFromIndex:(NSInteger)index
{
    ChatCellVideoViewModel *model = _recentDataArray[index];
    return model;
}

- (ChatCellVideoViewModel *)getRecentUserDataModelFromUserID:(NSString *)userID
{
    for (ChatCellVideoViewModel *model in _recentDataArray)
    {
        if ([model.streamID isEqualToString:userID])
            return model;
    }
    
    return nil;
}

- (void)addRecentUserDataModel:(ChatCellVideoViewModel *)model
{
    [_recentDataArray addObject:model];
}

- (void)addRecentUserDic:(NSDictionary *)dic
{
    [_recentDataArray addObject:dic];
}

- (void)removeRecentUserDicFromWebId:(NSString *)webId
{
    for (NSDictionary *dic in _recentDataArray)
    {
        if ([dic objectForKey:@"data"]) {
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            if ([[dataDic objectForKey:@"wbId"] isEqualToString:webId])
            {
                [_recentDataArray removeObject:dic];
                break;
            }
        }
    }
}

- (void)removeAllRecentUserDic
{
    [_recentDataArray removeAllObjects];
}

- (void)removeRecentUserDataModelFromUserID:(NSString *)userID
{
    for (ChatCellVideoViewModel *model in _recentDataArray)
    {
        if ([model.streamID isEqualToString:userID])
        {
            [_recentDataArray removeObject:model];
            break;
        }
    }
}

- (NSInteger)indexOfRecentUserDataArray:(NSString *)userID
{
    for (NSInteger i = 0; i < [_recentDataArray count]; i++)
    {
        ChatCellVideoViewModel *model = _recentDataArray[i];
        if ([model.streamID isEqualToString:userID])
            return i;
    }
    
    return -1;
}

#pragma mark - getter
- (RCRTCVideoCaptureParam *)videoCaptureParam
{
    if (!_videoCaptureParam) {
        _videoCaptureParam = [RCRTCVideoCaptureParam new];
    }
    
    return _videoCaptureParam;
}

// - (RCRTCAudioStreamConfig *)audioCaptureParam
// {
//     if (!_audioCaptureParam) {
//         _audioCaptureParam = [RCRTCAudioStreamConfig defaultParameters];
//     }
//     return _audioCaptureParam;
// }

- (NSMutableArray *)observerArray
{
    if (!_observerArray) {
        _observerArray = [NSMutableArray array];
    }
    return _observerArray;
}

#pragma mark - 视频参数
- (void)configVideoParameter
{
    self.videoCaptureParam.tinyStreamEnable = kLoginManager.isTinyStream;
    
    switch (kLoginManager.resolutionRatioIndex) {
        case 0:
            self.videoCaptureParam.videoSizePreset = RCRTCVideoSizePreset176x144;
            break;
        case 1:
            self.videoCaptureParam.videoSizePreset = RCRTCVideoSizePreset256x144;
            break;
        case 2:
            self.videoCaptureParam.videoSizePreset = RCRTCVideoSizePreset320x180;
            break;
        case 3:
            self.videoCaptureParam.videoSizePreset = RCRTCVideoSizePreset240x240;
            break;
        case 4:
            self.videoCaptureParam.videoSizePreset = RCRTCVideoSizePreset320x240;
            break;
        case 5:
            self.videoCaptureParam.videoSizePreset = RCRTCVideoSizePreset480x360;
            break;
        case 6:
            self.videoCaptureParam.videoSizePreset = RCRTCVideoSizePreset640x360;
            break;
        case 7:
            self.videoCaptureParam.videoSizePreset = RCRTCVideoSizePreset480x480;
            break;
        case 8:
            self.videoCaptureParam.videoSizePreset = RCRTCVideoSizePreset640x480;
            break;
        case 9:
            self.videoCaptureParam.videoSizePreset = RCRTCVideoSizePreset720x480;
            break;
        case 10:
            self.videoCaptureParam.videoSizePreset = RCRTCVideoSizePreset1280x720;
            break;
        default:
            self.videoCaptureParam.videoSizePreset = RCRTCVideoSizePreset640x480;
            break;
    }
    
    //最大码率
    NSString *codeRatePath = [[NSBundle mainBundle] pathForResource:@"CodeRate" ofType:@"plist"];
    NSArray *codeRateArray = [[NSArray alloc] initWithContentsOfFile:codeRatePath];
    NSDictionary *codeRateDictionary = codeRateArray[kLoginManager.resolutionRatioIndex];
    NSInteger max = [codeRateDictionary[@"max"] integerValue];
    NSInteger step = [codeRateDictionary[@"step"] integerValue];
    
    NSMutableArray *muArray = [NSMutableArray array];
    for (NSInteger temp = 0; temp <= max; temp += step)
        [muArray addObject:[NSString stringWithFormat:@"%zd", temp]];
    
    if ([muArray count] > kLoginManager.maxCodeRateIndex)
        self.videoCaptureParam.maxBitrate = [muArray[kLoginManager.maxCodeRateIndex] integerValue];
    
    //最小码率
    if ([muArray count] > kLoginManager.minCodeRateIndex)
        self.videoCaptureParam.minBitrate = [muArray[kLoginManager.minCodeRateIndex] integerValue];
    
    //帧率
    switch (kLoginManager.frameRateIndex) {
        case 0:
            self.videoCaptureParam.videoFrameRate = RCRTCVideoFPS10;
            break;
        case 1:
            self.videoCaptureParam.videoFrameRate = RCRTCVideoFPS15;
            break;
        case 2:
            self.videoCaptureParam.videoFrameRate = RCRTCVideoFPS24;
            break;
        case 3:
            self.videoCaptureParam.videoFrameRate = RCRTCVideoFPS30;
            break;
        default:
            self.videoCaptureParam.videoFrameRate = RCRTCVideoFPS15;
            break;
    }
    
    //关闭摄像头
    self.videoCaptureParam.turnOnCamera = !kLoginManager.isCloseCamera;
    
    //编码方式
    switch (kLoginManager.codingStyleIndex) {
        case 0:
            self.videoCaptureParam.codecType = RCRTCCodecH264;
            break;
        default:
            break;
    }
}

- (void)configAudioParameter
{
    self.rongRTCEngine.defaultAudioStream.audioScenario = kLoginManager.isAudioScenarioMusic ? RCRTCAudioScenarioMusic : RCRTCAudioScenarioDefault;
}

- (ChatRongAudioRTCEncryptorDelegateImpl *)chatRongAudioRTCEncryptorDelegateImpl {
    if (!_chatRongAudioRTCEncryptorDelegateImpl) {
        _chatRongAudioRTCEncryptorDelegateImpl = [[ChatRongAudioRTCEncryptorDelegateImpl alloc] init];
    }
    return _chatRongAudioRTCEncryptorDelegateImpl;
}

- (ChatRongAudioRTCDecryptorDelegateImpl *)chatRongAudioRTCDecryptorDelegateImpl {
    if (!_chatRongAudioRTCDecryptorDelegateImpl) {
        _chatRongAudioRTCDecryptorDelegateImpl = [[ChatRongAudioRTCDecryptorDelegateImpl alloc] init];
    }
    return _chatRongAudioRTCDecryptorDelegateImpl;
}

- (ChatRongVideoRTCEncryptorDelegateImpl *)chatRongVideoRTCEncryptorDelegateImpl {
    if (!_chatRongVideoRTCEncryptorDelegateImpl) {
        _chatRongVideoRTCEncryptorDelegateImpl = [[ChatRongVideoRTCEncryptorDelegateImpl alloc] init];
    }
    return _chatRongVideoRTCEncryptorDelegateImpl;
}

- (ChatRongVideoRTCDecryptorDelegateImpl *)chatRongVideoRTCDecryptorDelegateImpl {
    if (!_chatRongVideoRTCDecryptorDelegateImpl) {
        _chatRongVideoRTCDecryptorDelegateImpl = [[ChatRongVideoRTCDecryptorDelegateImpl alloc] init];
    }
    return _chatRongVideoRTCDecryptorDelegateImpl;
}

@end
