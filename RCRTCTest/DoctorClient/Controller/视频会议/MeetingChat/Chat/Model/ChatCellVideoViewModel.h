//
//  ChatCellVideoViewModel.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/12/07.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatAvatarView.h"
#import <RongRTCLib/RongRTCLib.h>

@interface ChatCellVideoViewModel : UIView

@property (nonatomic, strong) NSString *streamID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, assign) CGSize originalSize;
@property (nonatomic, strong) UIView *itemCoverView;
@property (nonatomic, copy) NSString* userName;

@property (nonatomic, assign) NSInteger bitRate;
@property (nonatomic, assign) NSInteger frameRateRecv;
@property (nonatomic, assign) NSInteger frameWidthRecv;
@property (nonatomic, assign) NSInteger frameHeightRecv;

@property (nonatomic, assign) NSInteger audioLevel;
@property (nonatomic, strong) UIImageView *audioLevelView;

@property (nonatomic, assign) NSInteger audioVideoType, videoType;
@property (nonatomic, assign) BOOL isCloseMicphone, isCloseCamera;

@property (nonatomic, strong) UIView *cellVideoView;
@property (nonatomic, strong) ChatAvatarView *avatarView;
@property (nonatomic, assign) NSInteger avType, everOnLocalView;
@property (nonatomic, strong) UIImageView *micImageView;
@property (nonatomic, strong) UILabel *infoLabel, *nameLabel;
@property (nonatomic, strong) CAGradientLayer *infoLabelGradLayer;
@property (nonatomic, assign) BOOL isShowVideo;
@property (nonatomic, assign) BOOL isSubscribeSuccess;
@property (nonatomic, assign) BOOL isConnectSuccess;
@property (nonatomic, assign) BOOL isUnpublish;
@property (nonatomic, strong) NSString *subscribeLog;
@property (nonatomic, strong) NSString *connectLog;
@property (nonatomic, strong) RCRTCInputStream *inputAudioStream;
@property (nonatomic, strong) RCRTCInputStream *inputVideoStream;

- (instancetype)initWithView:(UIView *)view;
- (void)removeKeyPathObservers;

@end
