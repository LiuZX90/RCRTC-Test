//
//  ChatViewController.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCLib.h>

#import "ChatCell.h"
#import "ChatCollectionViewDataSourceDelegateImpl.h"
#import "ChatRongRTCRoomDelegateImpl.h"
#import "ChatRongRTCNetworkMonitorDelegateImpl.h"
#import "ChatViewBuilder.h"
#import "ChatCellVideoViewModel.h"
#import "ChatManager.h"
#import "ChatGPUImageHandler.h"
#import "ChatWhiteBoardHandler.h"

//@class FUSelectView; //LLH_FU

#define TitleHeight 78
#define redButtonBackgroundColor [UIColor colorWithRed:243.0/255.0 green:57.0/255.0 blue:58.0/255.0 alpha:1.0]


typedef enum : NSUInteger {
    AVChatModeNormal,
    AVChatModeAudio,
    AVChatModeObserver,
} AVChatMode;

@interface ChatViewController : UIViewController <RCRTCRoomEventDelegate>

@property (nonatomic, weak) IBOutlet UIButton *speakerControlButton;
@property (nonatomic, weak) IBOutlet UIButton *audioMuteControlButton;
@property (nonatomic, weak) IBOutlet UIView *videoControlView;
@property (nonatomic, strong) UIView *videoMainView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *statusView;
///通话时间
@property (nonatomic, strong) UILabel *talkTimeLabel;
///通话使用流量
@property (nonatomic, strong) UILabel *dataTrafficLabel;
@property (nonatomic, strong) UILabel *alertLabel;
///房间标题
@property (nonatomic, strong) UILabel *titleLabel;
///网络状态
@property (nonatomic, strong) UILabel *networkLabel;
@property (nonatomic, strong) UIScrollView *scrollView ;
@property (nonatomic, strong) UIView *zoomView;
@property (nonatomic, strong) UIImageView *homeImageView;
@property (nonatomic, strong) RCRTCLocalVideoView *localView;
@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) NSMutableArray *alertTypeArray;
@property (nonatomic, strong) NSMutableDictionary *videoMuteForUids;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, assign) NSUInteger duration;
@property (nonatomic, assign) BOOL isHiddenStatusBar;
@property (nonatomic, assign) NSInteger orignalRow;
@property (nonatomic, strong) ChatCell *selectedChatCell;
@property (nonatomic, assign) CGFloat videoHeight, blankHeight;
@property (nonatomic, strong) ChatCollectionViewDataSourceDelegateImpl *chatCollectionViewDataSourceDelegateImpl;
@property (nonatomic, strong) ChatRongRTCRoomDelegateImpl *chatRongRTCRoomDelegateImpl;
@property (nonatomic, strong) ChatRongRTCNetworkMonitorDelegateImpl *chatRongRTCNetworkMonitorDelegateImpl;
@property (nonatomic, strong) ChatViewBuilder *chatViewBuilder;
@property (nonatomic, strong) ChatGPUImageHandler *chatGPUImageHandler;
@property (nonatomic, strong) ChatWhiteBoardHandler *chatWhiteBoardHandler;
@property (nonatomic, assign) BOOL isFinishLeave,isLandscapeLeft, isNotLeaveMeAlone;
@property (nonatomic, assign) UIDeviceOrientation deviceOrientaionBefore;
@property (nonatomic, strong) RCRTCRoom* room;
@property (nonatomic)RCRTCCode joinRoomCode;
@property (nonatomic)AVChatMode chatMode;
@property (nonatomic, weak) ChatCellVideoViewModel* selectionModel;
@property (assign, nonatomic) BOOL openComp;
@property (assign, nonatomic) BOOL enableCameraFocus;

///需要移除上一个视图
@property (assign, nonatomic) BOOL removeNextVC;

- (void)hideAlertLabel:(BOOL)isHidden;
- (void)selectSpeakerButtons:(BOOL)selected;
- (void)updateTalkTimeLabel;
- (void)startTalkTimer;
- (void)didClickHungUpButton;
- (void)menuItemButtonPressed:(UIButton *)sender;
- (void)didClickVideoMuteButton:(UIButton *)btn;
- (void)didClickAudioMuteButton:(UIButton *)btn;
- (void)didClickSwitchCameraButton:(UIButton *)btn;
- (void)showButtons:(BOOL)flag;
- (void)joinChannel;
- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams;
- (void)unsubscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams;
- (void)didConnectToUser:(NSString *)userId;
- (void)receivePublishMessage;
- (void)didLeaveRoom;
- (void)showAlertLabelWithAnimate:(NSString *)text;

@end
