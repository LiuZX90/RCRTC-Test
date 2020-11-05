//
//  ChatRongRTCRoomDelegateImpl.m
//  SealRTC
//
//  Created by LiuLinhong on 2019/02/14.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ChatRongRTCRoomDelegateImpl.h"
#import "ChatViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "STSetRoomInfoMessage.h"
#import "STDeleteRoomInfoMessage.h"
#import "STParticipantsInfo.h"

#define KWidth 360
#define kHeight 640

#import "STKickOffInfoMessage.h"

@interface ChatRongRTCRoomDelegateImpl ()

@property (nonatomic, weak) ChatViewController *chatViewController;

@end

NSNotificationName const STParticipantsInfoDidRemove = @"STParticipantsInfoDidRemove";
NSNotificationName const STParticipantsInfoDidAdd = @"STParticipantsInfoDidAdd";
NSNotificationName const STParticipantsInfoDidUpdate = @"STParticipantsInfoDidUpdate";

@implementation ChatRongRTCRoomDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.chatViewController = (ChatViewController *) vc;
    }
    return self;
}

/**
 有用户加入的回调
 @param user 加入的用户信息
 */
- (void)didJoinUser:(RCRTCRemoteUser*)user
{
    FwLogD(RC_Type_APP,@"A-appReceiveUserJoin-T",@"%@appReceiveUserJoin",@"sealRTCApp:");
    NSString *userId = user.userId;
    DLog(@"didJoinUser userID: %@", userId);
//    [self.chatViewController hideAlertLabel:YES];
//    [self.chatViewController startTalkTimer];
}

/**
 有用户离开时的回调
 @param user 离开的用户
 */
- (void)didLeaveUser:(RCRTCRemoteUser*)user
{
    FwLogD(RC_Type_APP,@"A-appReceiveUserLeave-T",@"%@appReceiveUserLeave",@"sealRTCApp:");
    __weak ChatViewController *weakChatVC = self.chatViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = user.userId;
        DLog(@"didLeaveUser userID: %@", userId);
        
        NSArray *streams = user.remoteStreams;
        for (RCRTCInputStream *stream in streams) {
            NSString *streamID = stream.streamId;
            if ([kChatManager isContainRemoteUserFromStreamID:streamID])
            {
                NSInteger index = [kChatManager indexOfRemoteUserDataArray:streamID];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                ChatCellVideoViewModel *leftUserStream = [kChatManager getRemoteUserDataModelFromStreamID:streamID];
                leftUserStream.isUnpublish = YES;
                if (kLoginManager.isSwitchCamera
                    && [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.streamID isEqualToString:streamID])
                {
                    [weakChatVC.chatCollectionViewDataSourceDelegateImpl collectionView:weakChatVC.collectionView didSelectItemAtIndexPath:indexPath];
                }
                
                [kChatManager removeRemoteUserDataModelFromStreamID:streamID];
                FwLogD(RC_Type_APP,@"A-appReceiveUserLeave-T",@"%@appReceiveUserLeave and remove user",@"sealRTCApp:");
                [weakChatVC.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                [self.chatViewController showAlertLabelWithAnimate:[NSString stringWithFormat:@"%@退出房间", leftUserStream.userName]];
                
                if (weakChatVC.orignalRow > 0)
                    weakChatVC.orignalRow--;
            }
        }
        FwLogD(RC_Type_APP,@"A-appReceiveUserJoin-T",@"usercount: %@",@([kChatManager countOfRemoteUserDataArray]));
        if ([kChatManager countOfRemoteUserDataArray] == 0)
        {
            if (weakChatVC.durationTimer)
            {
                [weakChatVC.durationTimer invalidate];
                weakChatVC.duration = 0;
                weakChatVC.durationTimer = nil;
            }
            
            weakChatVC.dataTrafficLabel.hidden = YES;
            weakChatVC.talkTimeLabel.text = @"";//NSLocalizedString(@"chat_total_time", nil);
            FwLogD(RC_Type_APP,@"A-appReceiveUserJoin-T",@"hideAlertLabel NO");
            [weakChatVC hideAlertLabel:NO];
        }
    });
    [self didLeftMasterUser:user.userId];
}

- (void)didOfflineUser:(RCRTCRemoteUser*)user {
    [self didLeaveUser:user];
}
/**
 数据流第一个关键帧到达
 @param stream 开始接收数据的 stream
 */
- (void)didReportFirstKeyframe:(RCRTCInputStream *)stream
{
}

-(void)didConnectToStream:(RCRTCInputStream *)stream{
    FwLogD(RC_Type_APP,@"A-appConnectToStream-T",@"%@appConnectTostream",@"sealRTCApp:");
    if (stream.streamId) {
        [self.chatViewController didConnectToUser:stream.streamId];
    } else {
        DLog(@"did connect to stream but userId is nil");
    }
}

- (void)didPublishStreams:(NSArray <RCRTCInputStream *>*)streams
{
    // 去掉布局
//    RongRTCMixStreamConfig *streamConfig = [self setOutputConfigWithMode:1 renderMode:2];
//    [[RCRTCEngine sharedInstance] setMixStreamConfig:streamConfig completion:^(BOOL isSuccess, RCRTCCode code) {
//        NSLog(@"%ld",code);
//    }];
    FwLogD(RC_Type_APP,@"A-appPublishStreaam-T",@"%@appPublishStream",@"sealRTCApp:");
    [self.chatViewController receivePublishMessage];
    [self.chatViewController subscribeRemoteResource:streams];
}

/**
 当有用户取消发布资源的时候，通过此方法回调。
 @param streams 取消发布资源
 */
- (void)didUnpublishStreams:(NSArray<RCRTCInputStream *>*)streams
{
    FwLogD(RC_Type_APP,@"A-appReceiveUnpublishStream-T",@"%@app receive unpublishstreams",@"sealRTCApp:");
    
    __weak ChatViewController *weakChatVC = self.chatViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (RCRTCInputStream *stream in streams) {
            NSString *streamID = stream.streamId;
            if ([kChatManager isContainRemoteUserFromStreamID:streamID])
            {
                NSInteger index = [kChatManager indexOfRemoteUserDataArray:streamID];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                ChatCellVideoViewModel *leftUserStream = [kChatManager getRemoteUserDataModelFromStreamID:streamID];
                leftUserStream.isUnpublish = YES;
                if (kLoginManager.isSwitchCamera
                    && [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.streamID isEqualToString:streamID])
                {
                    [weakChatVC.chatCollectionViewDataSourceDelegateImpl collectionView:weakChatVC.collectionView didSelectItemAtIndexPath:indexPath];
                }
                
                [kChatManager removeRemoteUserDataModelFromStreamID:streamID];
                FwLogD(RC_Type_APP,@"A-appReceiveUserLeave-T",@"%@appReceiveUserLeave and remove user",@"sealRTCApp:");
                [weakChatVC.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                
                if (weakChatVC.orignalRow > 0)
                    weakChatVC.orignalRow--;
            }
        }
    });
}

- (void)didKickedOutOfTheRoom:(RCRTCRoom *)room
{
    FwLogD(RC_Type_APP,@"A-appreceiveLeaveRoom-T",@"%@all reveive leave room",@"sealRTCApp:");
    [self.chatViewController didLeaveRoom];
}

- (void)didKickedByServer:(RCRTCRoom *)room
{
    FwLogD(RC_Type_APP,@"A-appReceiveKickedByServer-T",@"%@all reveive leave room",@"sealRTCApp:");
    [self.chatViewController didLeaveRoom];
}

/**
 音频状态改变
 @param stream 流信息
 @param mute 当前流是否可用
 */
- (void)stream:(RCRTCInputStream*)stream didAudioMute:(BOOL)mute
{
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    UIAlertController *controler = [UIAlertController alertControllerWithTitle:@"有人开关麦克风了" message:[NSString stringWithFormat:@"%@把%@这道流的麦克风%@了",stream.userId,stream.streamId,!mute?@"关":@"开"] preferredStyle:(UIAlertControllerStyleAlert)];
//    [controler addAction:action];
//    [self presentViewController:controler animated:YES completion:^{
//    }];
}

/**
 视频状态改变
 @param stream 流信息
 @param enable 当前流是否可用
 */
- (void)stream:(RCRTCInputStream*)stream didVideoEnable:(BOOL)enable {
    ChatCellVideoViewModel *remoteModel = [kChatManager getRemoteUserDataModelFromStreamID:stream.streamId];
    remoteModel.isShowVideo = enable;
    if (!enable) {
        remoteModel.avatarView.frame = remoteModel.cellVideoView.frame;
        [remoteModel.cellVideoView addSubview:remoteModel.avatarView];
    }
    else {
        [remoteModel.avatarView removeFromSuperview];
    }
}

- (void)didReceiveMessage:(RCMessage *)message {
    if ([message.content isKindOfClass:STSetRoomInfoMessage.class]) {
        STSetRoomInfoMessage* infoMessage = (STSetRoomInfoMessage*)message.content;
        if (infoMessage.key <= 0) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL isFound = NO;
            for (STParticipantsInfo* info in self.infos) {
                if ([info.userId isEqualToString:infoMessage.key]) {
                    isFound = YES;
                    break;
                }
            }
            if (!isFound) {
                [self.infos addObject:infoMessage.info];
                [[NSNotificationCenter defaultCenter] postNotificationName:STParticipantsInfoDidAdd
                                                                    object:[NSIndexPath indexPathForRow:[self.infos count]-1 inSection:0]];
                [self.chatViewController showAlertLabelWithAnimate:[NSString stringWithFormat:@"%@进入房间", infoMessage.info.userName]];
            }
        });
        ChatCellVideoViewModel* model = [kChatManager getRemoteUserDataModelSimilarUserID:infoMessage.key];
        model.userName = infoMessage.info.userName;
        //[[NSNotificationCenter defaultCenter] postNotificationName:STDidRecvSetRoomInfoMessageNotification object:message.content];
    } else if ([message.content isKindOfClass:STDeleteRoomInfoMessage.class]) {
        STDeleteRoomInfoMessage* infoMessage = (STDeleteRoomInfoMessage*)message.content;
        if (infoMessage.key <= 0) {
            return;
        }
        [self didLeftMasterUser:infoMessage.key];
    }
    else if ([message.content isKindOfClass:RongWhiteBoardMessage.class]) {
        RongWhiteBoardMessage *whiteMessage = (RongWhiteBoardMessage *)message.content;
        if (whiteMessage.whiteBoardDict) {
            self.chatViewController.chatWhiteBoardHandler.roomUuid = whiteMessage.whiteBoardDict[kWhiteBoardUUID];
            self.chatViewController.chatWhiteBoardHandler.roomToken = whiteMessage.whiteBoardDict[kWhiteBoardRoomToken];
        }
    }
    else if ([message.content isKindOfClass:STKickOffInfoMessage.class]) {
        STKickOffInfoMessage *kickOffMessage = (STKickOffInfoMessage *)message.content;
        if (kickOffMessage.kickOffDict) {
            NSString *kickedUserId = kickOffMessage.kickOffDict[@"userId"];
            if ([kickedUserId isEqualToString:kLoginManager.userID] && !kLoginManager.isMaster) {
                kLoginManager.kickOffTime = [[NSDate date] timeIntervalSince1970];
                kLoginManager.kickOffRoomNumber = kLoginManager.roomNumber;
                kLoginManager.isKickOff = YES;
                [self.chatViewController didClickHungUpButton];
            }
        }
    }
}

#pragma mark - Private
- (void)didLeftMasterUser:(NSString *)userId {
    BOOL isLeftUserMaster = NO;
    NSInteger index = NSNotFound;
    for (int i = 0; i < self.infos.count; i++) {
        STParticipantsInfo* info = self.infos[i];
        if ([info.userId isEqualToString:userId]) {
            index = i;
            isLeftUserMaster = info.master;
            break;
        }
    }
    
    if (isLeftUserMaster) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
        [self.chatViewController.room getRoomAttributes:nil completion:^(BOOL isSuccess, RCRTCCode desc, NSDictionary * _Nullable attr) {
//            for (id key in attr) {
//                NSString *obj = attr[key];
//                NSDictionary *dicInfo = [NSJSONSerialization JSONObjectWithData:[obj dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//                STParticipantsInfo *info = [[STParticipantsInfo alloc] initWithDictionary:dicInfo];
//                for (int j = 0; j < self.infos.count; j++) {
//                    STParticipantsInfo *tmpInfo = self.infos[j];
//                    if ([tmpInfo.userId isEqualToString:info.userId]) {
//                        tmpInfo.master = info.master;
//                        if (info.master) {
//                            if ([info.userId isEqualToString:kLoginManager.userID]) {
//                                kLoginManager.isMaster = YES;
//                            }
//                            [self.chatViewController showAlertLabelWithAnimate:[NSString stringWithFormat:@"%@成为新管理员", info.userName]];
//                        }
//                    }
//                }
//            }
            
            NSInteger leftUserIndex = NSNotFound;
            for (int i = 0; i < self.infos.count; i++) {
                STParticipantsInfo* info = self.infos[i];
                if ([info.userId isEqualToString:userId]) {
                    leftUserIndex = i;
                    break;
                }
            }
            
            if (leftUserIndex != NSNotFound && [self.infos count] > leftUserIndex) {
                [self.infos removeObjectAtIndex:leftUserIndex];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:STParticipantsInfoDidUpdate object:nil];
        }];
#pragma clang diagnostic pop
    }
    else {
        if (index != NSNotFound) {
            [self.infos removeObjectAtIndex:index];
            if (self.infos.count == 1) {
//                self.infos[0].master = YES;
//                kLoginManager.isMaster = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:STParticipantsInfoDidUpdate
                                                                    object:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:STParticipantsInfoDidRemove
                                                                object:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
}

@end
