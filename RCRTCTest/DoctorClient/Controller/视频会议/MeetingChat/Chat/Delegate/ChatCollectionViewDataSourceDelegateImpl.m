//
//  ChatCollectionViewDataSourceDelegateImpl.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "ChatCollectionViewDataSourceDelegateImpl.h"
#import "ChatViewController.h"
#import "CommonUtility.h"

@interface ChatCollectionViewDataSourceDelegateImpl ()
{
    NSString *originalRemoteUserID;
}

@property (nonatomic, weak) ChatViewController *chatViewController;

@end

@implementation ChatCollectionViewDataSourceDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.chatViewController = (ChatViewController *) vc;
    }
    
    return self;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [kChatManager countOfRemoteUserDataArray];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    if ([kChatManager countOfRemoteUserDataArray] <= indexPath.row)
        return cell;
    
    NSString *streamId = [kChatManager getUserIDOfRemoteUserDataModelFromIndex:indexPath.row];
    NSNumber *videoMute = [self.chatViewController.videoMuteForUids objectForKey:streamId];
    ChatCellVideoViewModel *model = [kChatManager getRemoteUserDataModelFromIndex:indexPath.row];
    
    if (videoMute.boolValue)
        cell.type = ChatTypeAudio;
    else
    {
        cell.type = ChatTypeVideo;
        if ([kChatManager countOfRemoteUserDataArray] <= indexPath.row)
            return cell;
        if (kLoginManager.isSwitchCamera && indexPath.row == self.chatViewController.orignalRow)
            [cell.videoView addSubview:kChatManager.localUserDataModel.cellVideoView];
        else
            [cell.videoView addSubview:model.cellVideoView];
    }
    
    cell.nameLabel.text = model.streamID;
    if (kLoginManager.isAutoTest)
        [cell refreshAutoTestLabel:!model.isSubscribeSuccess connectLabel:!model.isConnectSuccess subscribeLog:model.subscribeLog connectLog:model.connectLog];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    @synchronized (self)
    {
        [self.chatViewController.scrollView zoomToRect:CGRectMake(0, 0, MainscreenWidth, MainscreenHeight) animated:NO];
        NSInteger selectedRow = indexPath.row;
        ChatCellVideoViewModel *selectedViewModel = [kChatManager getRemoteUserDataModelFromIndex:selectedRow];

        ChatCell *cell = (ChatCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
//        NSString *bigStreamUseID = selectedViewModel.streamID;
//        if (kLoginManager.isSwitchCamera) {
//            if (selectedRow == self.chatViewController.orignalRow) {
//                bigStreamUseID = kChatManager.localUserDataModel.streamID;
//            }
//        }
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (kLoginManager.isSwitchCamera)
        {
            if (selectedRow == self.chatViewController.orignalRow)
            {
                //本地: 恢复在大屏上显示
                RCRTCLocalVideoView *localVideoView = (RCRTCLocalVideoView *)kChatManager.localUserDataModel.cellVideoView;
                localVideoView.fillMode = RCRTCVideoFillModeAspect;
                localVideoView.frame = self.chatViewController.scrollView.frame;
                self.chatViewController.zoomView = kChatManager.localUserDataModel.cellVideoView;
                [self.chatViewController.scrollView addSubview:kChatManager.localUserDataModel.cellVideoView];

                
                CGFloat offset = 16;
                if (@available(iOS 11.0, *)) {
                    if (UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom > 0.0) {
                        offset += UIInterfaceOrientationIsLandscape(orientation) ? 34 : 78;
                    }
                }
                kChatManager.localUserDataModel.infoLabel.frame = CGRectMake(13, localVideoView.frame.size.height - offset, localVideoView.frame.size.width - 26, kChatManager.localUserDataModel.infoLabel.frame.size.height);
                kChatManager.localUserDataModel.infoLabelGradLayer.frame = kChatManager.localUserDataModel.infoLabel.frame;
//                [kChatManager.localUserDataModel.cellVideoView addSubview:kChatManager.localUserDataModel.infoLabel];
                
                [self.chatViewController.videoMainView addSubview:kChatManager.localUserDataModel.infoLabel];
                
                if (!kChatManager.localUserDataModel.isShowVideo) {
                    kChatManager.localUserDataModel.avatarView.frame = localVideoView.frame;
                    [kChatManager.localUserDataModel.cellVideoView addSubview:kChatManager.localUserDataModel.avatarView];
                }
                self.chatViewController.selectionModel = kChatManager.localUserDataModel;
                
                //远端: 恢复显示在collection cell中
                RCRTCRemoteVideoView *remoteVideoView = (RCRTCRemoteVideoView *)selectedViewModel.cellVideoView;
                remoteVideoView.fillMode = RCRTCVideoFillModeAspect;
                remoteVideoView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
                [cell.videoView addSubview:selectedViewModel.cellVideoView];
                [cell.videoView addSubview:selectedViewModel.infoLabel];
                
                selectedViewModel.infoLabel.frame = CGRectMake(0, remoteVideoView.frame.size.height - 16, remoteVideoView.frame.size.width, selectedViewModel.infoLabel.frame.size.height);
                selectedViewModel.infoLabelGradLayer.frame = selectedViewModel.infoLabel.frame;
                [selectedViewModel.cellVideoView addSubview:selectedViewModel.infoLabel];
                
                if (!selectedViewModel.isShowVideo) {
                    selectedViewModel.avatarView.frame = remoteVideoView.frame;
                    [selectedViewModel.cellVideoView addSubview:selectedViewModel.avatarView];
                }
                
                if (selectedViewModel.inputVideoStream && !selectedViewModel.isUnpublish) {
                    [self.chatViewController.room.localUser subscribeStream:nil tinyStreams:@[selectedViewModel.inputVideoStream] completion:^(BOOL isSuccess, RCRTCCode desc) {
                    }];
                }
                
                kLoginManager.isSwitchCamera = !kLoginManager.isSwitchCamera;
            }
            else
            {
                //远端: 之前切换到大屏上的远端,先切换回原collection cell上
                RCRTCRemoteVideoView *originalRemoteVideoView = (RCRTCRemoteVideoView *)self.originalSelectedViewModel.cellVideoView;
                originalRemoteVideoView.fillMode = RCRTCVideoFillModeAspect;
                originalRemoteVideoView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
                [self.chatViewController.selectedChatCell.videoView addSubview:self.originalSelectedViewModel.cellVideoView];
                
                self.originalSelectedViewModel.infoLabel.frame = CGRectMake(0, originalRemoteVideoView.frame.size.height - 16, originalRemoteVideoView.frame.size.width, self.originalSelectedViewModel.infoLabel.frame.size.height);
                self.originalSelectedViewModel.infoLabelGradLayer.frame = self.originalSelectedViewModel.infoLabel.frame;
                [self.originalSelectedViewModel.cellVideoView addSubview:self.originalSelectedViewModel.infoLabel];
                
                if (!self.originalSelectedViewModel.isShowVideo) {
                    self.originalSelectedViewModel.avatarView.frame = originalRemoteVideoView.frame;
                    [self.originalSelectedViewModel.cellVideoView addSubview:self.originalSelectedViewModel.avatarView];
                }
                
                if (selectedViewModel.inputVideoStream && !selectedViewModel.isUnpublish) {
                    NSArray *tinys = self.originalSelectedViewModel.inputVideoStream ? @[self.originalSelectedViewModel.inputVideoStream] : nil;
                    [self.chatViewController.room.localUser subscribeStream:@[selectedViewModel.inputVideoStream] tinyStreams:tinys completion:^(BOOL isSuccess, RCRTCCode desc) {
                    }];
                }
                
                //远端: 当前点击的远端,切换到大屏
                self.originalSelectedViewModel = selectedViewModel;
                originalRemoteUserID = selectedViewModel.streamID;
                
                RCRTCRemoteVideoView *remoteVideoView = (RCRTCRemoteVideoView *)selectedViewModel.cellVideoView;

                remoteVideoView.fillMode = RCRTCVideoFillModeAspect;
                remoteVideoView.frame = self.chatViewController.scrollView.frame;
                self.chatViewController.zoomView = selectedViewModel.cellVideoView;
                [self.chatViewController.scrollView addSubview:selectedViewModel.cellVideoView];

                
                CGFloat offset = 16;
                if (@available(iOS 11.0, *)) {
                    if (UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom > 0.0) {
                        offset += UIInterfaceOrientationIsLandscape(orientation) ? 34 : 78;
                    }
                }
                selectedViewModel.infoLabel.frame = CGRectMake(0, remoteVideoView.frame.size.height - offset, remoteVideoView.frame.size.width, selectedViewModel.infoLabel.frame.size.height);
                selectedViewModel.infoLabelGradLayer.frame = selectedViewModel.infoLabel.frame;
//                [selectedViewModel.cellVideoView addSubview:selectedViewModel.infoLabel];
                
                
                [self.chatViewController.videoMainView addSubview:selectedViewModel.infoLabel];
                
                self.chatViewController.selectionModel = selectedViewModel;
                if (!selectedViewModel.isShowVideo) {
                    selectedViewModel.avatarView.frame = remoteVideoView.frame;
                    [selectedViewModel.cellVideoView addSubview:selectedViewModel.avatarView];
                }
                
                //本地: 为在cell上铺满屏,根据所选本地分辨率判断宽高比例,切换到collection cell上
                RCRTCLocalVideoView *localVideoView = (RCRTCLocalVideoView *)kChatManager.localUserDataModel.cellVideoView;
                localVideoView.fillMode = RCRTCVideoFillModeAspect;
                localVideoView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
                [cell.videoView addSubview:kChatManager.localUserDataModel.cellVideoView];
                
                kChatManager.localUserDataModel.infoLabel.frame = CGRectMake(0, localVideoView.frame.size.height - 16, localVideoView.frame.size.width, kChatManager.localUserDataModel.infoLabel.frame.size.height);
                kChatManager.localUserDataModel.infoLabelGradLayer.frame = kChatManager.localUserDataModel.infoLabel.frame;
                [kChatManager.localUserDataModel.cellVideoView addSubview:kChatManager.localUserDataModel.infoLabel];
                
                if (!kChatManager.localUserDataModel.isShowVideo) {
                    kChatManager.localUserDataModel.avatarView.frame = localVideoView.frame;
                    [kChatManager.localUserDataModel.cellVideoView addSubview:kChatManager.localUserDataModel.avatarView];
                }
            }
        }
        else
        {
            //远端: 根据远端设置的分辨率比例显示在大屏上
            self.originalSelectedViewModel = selectedViewModel;
            originalRemoteUserID = selectedViewModel.streamID;
            
            RCRTCRemoteVideoView *remoteVideoView = (RCRTCRemoteVideoView *)selectedViewModel.cellVideoView;

            remoteVideoView.fillMode = RCRTCVideoFillModeAspect;
            remoteVideoView.frame = self.chatViewController.scrollView.frame;
            self.chatViewController.zoomView = selectedViewModel.cellVideoView;
            [self.chatViewController.scrollView addSubview:selectedViewModel.cellVideoView];

            
            CGFloat offset = 16;
            if (@available(iOS 11.0, *)) {
                if (UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom > 0.0) {
                    offset += UIInterfaceOrientationIsLandscape(orientation) ? 34 : 78;
                }
            }
            selectedViewModel.infoLabel.frame = CGRectMake(13, remoteVideoView.frame.size.height - offset, remoteVideoView.frame.size.width - 26, selectedViewModel.infoLabel.frame.size.height);
            selectedViewModel.infoLabelGradLayer.frame = selectedViewModel.infoLabel.frame;
//            [selectedViewModel.cellVideoView addSubview:selectedViewModel.infoLabel];
            
            [self.chatViewController.videoMainView addSubview:selectedViewModel.infoLabel];
            
            self.chatViewController.selectionModel = selectedViewModel;
            if (!selectedViewModel.isShowVideo) {
                selectedViewModel.avatarView.frame = remoteVideoView.frame;
                [selectedViewModel.cellVideoView addSubview:selectedViewModel.avatarView];
            }
            
            if (selectedViewModel.inputVideoStream && !selectedViewModel.isUnpublish) {
                [self.chatViewController.room.localUser subscribeStream:@[selectedViewModel.inputVideoStream] tinyStreams:nil completion:^(BOOL isSuccess,RCRTCCode desc) {
                }];
            }
            
            //本地: 为了在cell上铺满屏,根据所选本地分辨率判断宽高比例,切换到collection cell上
            RCRTCLocalVideoView *localVideoView = (RCRTCLocalVideoView *)kChatManager.localUserDataModel.cellVideoView;
            localVideoView.fillMode = RCRTCVideoFillModeAspect;
            localVideoView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
            [cell.videoView addSubview:kChatManager.localUserDataModel.cellVideoView];
            

            kChatManager.localUserDataModel.infoLabel.frame = CGRectMake(0, localVideoView.frame.size.height - 16, localVideoView.frame.size.width, kChatManager.localUserDataModel.infoLabel.frame.size.height);
            kChatManager.localUserDataModel.infoLabelGradLayer.frame = kChatManager.localUserDataModel.infoLabel.frame;
            [kChatManager.localUserDataModel.cellVideoView addSubview:kChatManager.localUserDataModel.infoLabel];
            
            if (!kChatManager.localUserDataModel.isShowVideo) {
                kChatManager.localUserDataModel.avatarView.frame = localVideoView.frame;
                [kChatManager.localUserDataModel.cellVideoView addSubview:kChatManager.localUserDataModel.avatarView];
            }
            
            kLoginManager.isSwitchCamera = !kLoginManager.isSwitchCamera;
        }
        
        self.chatViewController.selectedChatCell = cell;
        self.chatViewController.orignalRow = selectedRow;
    }
}



@end
