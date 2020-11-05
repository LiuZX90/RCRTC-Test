//
//  HomeViewController.m
//  DoctorClient
//
//  Created by ZengPengYuan on 2019/4/22.
//  Copyright © 2019 ZengPengYuan. All rights reserved.
//

#import "HomeViewController.h"
//#import "LoopImageRequest.h"
//#import "NewsRequest.h"
//#import "UserManager.h"
//#import "BaseTableView.h"
//#import "WRNavigationBar.h"
//#import <WebKit/WebKit.h>
//#import "WBWebViewController.h"
//#import "ConfirmReceptionRequest.h"
//#import "PXDVideoInterrogationMainViewController.h"

#import "UIView+Toast.h"
#import "LoginViewBuilder.h"
#import "ChatViewController.h"
#import "RTActiveWheel.h"
#import "LoginManager.h"
#import "RCFetchTokenManager.h"

#import <RongRTCLib/RongRTCLib.h>
#import <RongIMLib/RongIMLib.h>


@interface HomeViewController () 

@property(nonatomic, weak) RCRTCRoom* room;
@property(atomic, assign) BOOL isJoiningRoom;

@end

@implementation HomeViewController {
//    HUDManager *_hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[RCIMClient sharedRCIMClient] initWithAppKey:RCIMAPPKey];
    
    UIButton * vBtn = [[UIButton alloc] init];
    vBtn.frame = CGRectMake((MainscreenWidth - 100)/2, 400, 100, 40);
    [vBtn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    [vBtn setTitle:@"进入会议" forState:(UIControlStateNormal)];
//    cBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [vBtn addTarget:self action:@selector(vclick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:vBtn];
    
}

- (void)vclick{
    
    kLoginManager.roomNumber = @"000093";
    kLoginManager.username = @"test1";
    kLoginManager.phoneNumber = @"15900000002";
    
    
//    if (kLoginManager.keyToken) {
//        [self connectWithToken];
//    }else{
        //获取token，连接im
        NSString *userId = [NSString stringWithFormat:@"%@_%@_ios", kLoginManager.phoneNumber, kDeviceUUID];
//        NSString * userId = @"c696737b-c45b-42d7-9402-8f518c6ccc8a";
        [[RCFetchTokenManager sharedManager] pxd_fetchTokenWithUserId:userId username:@"皮gg" portraitUri:@"https://api.yizhitong100.com/IMG/manager/doctor/4cdfa9c4bb9b48c7bcf933af779610dc.jpg" completion:^(BOOL isSucccess, NSString * _Nullable token) {
            
            if (isSucccess && token.length > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    kLoginManager.keyToken = token;
                    [self connectWithToken];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:@"环境配置错误" duration:1.5 position:CSToastPositionCenter];
                });
            }
        }];
//    }
}

-(void)connectWithToken
{
    
    if ([[RCIMClient sharedRCIMClient] getConnectionStatus] == ConnectionStatus_Connected) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self joinRoom];
        });
        
    }else{
        DLog(@"start to connectWithToken");
        [[RCIMClient sharedRCIMClient] connectWithToken:kLoginManager.keyToken
                                               dbOpened:^(RCDBErrorCode code) {
            DLog(@"MClient dbOpened code: %zd", code);
            
        }
                                                success:^(NSString *userId) {
            DLog(@"MClient connectWithToken Success userId: %@", userId);
            kLoginManager.userID = userId;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"audio"];
            
            NSLog(@"streamId_5 = %@",[[[RCRTCEngine sharedInstance] defaultVideoStream] streamId]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self joinRoom];
            });
        }
                                                  error:^(RCConnectErrorCode status) {
            self.isJoiningRoom = NO;
            DLog(@"MClient connectWithToken Error: %zd", status);
            if (kLoginManager.isPrivateEnvironment) {
                kLoginManager.keyToken = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view makeToast:@"连接出错" duration:3 position:CSToastPositionCenter];
                });
            }
            else if (status == RC_CONN_TOKEN_INCORRECT) {
                dispatch_async(dispatch_get_main_queue(), ^{
    //                [self.loginViewBuilder showValidateView:YES];
                });
            }
        }];
    }
    

}

- (void)joinRoom {
    
#ifdef IS_LIVE
    [self navToChatViewController:YES];
#else
    [RTActiveWheel showHUDAddedTo:self.view];
    
    NSLog(@"streamId_2 = %@",[[[RCRTCEngine sharedInstance] defaultVideoStream] streamId]);
    
    
    
    [[RCRTCEngine sharedInstance]
     joinRoom:kLoginManager.roomNumber
     completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
        [RTActiveWheel dismissForView:self.view];
        if (code == RCRTCCodeSuccess) {
            self.room = room;
            [self navToChatViewController:YES];
        } else if (room.remoteUsers.count >= MAX_NORMAL_PERSONS &&
                   room.remoteUsers.count < MAX_AUDIO_PERSONS) {
//            [self showJoinPromptOfAudioMode];
        } else if (room.remoteUsers.count >= MAX_AUDIO_PERSONS) {
//            [self showJoinPromtOfObserverMode];
        } else {
//            [self showInfomationWithErrorCode:code];
        }
        self.isJoiningRoom = NO;
    }];
#endif
    
}

- (void)navToChatViewController:(BOOL)isHost {
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.loginViewBuilder.roomNumberTextField resignFirstResponder];
            if (![self.navigationController.topViewController isKindOfClass:[ChatViewController class]]) {
                DLog(@"performSegueWithIdentifier to ChatViewController");
                #ifdef IS_LIVE
                    [kLoginManager setIsHost:isHost];
                #else
                    
                #endif

                
                ChatViewController * cvc = [[ChatViewController alloc] init];
                cvc.joinRoomCode = RCRTCCodeSuccess;
                cvc.room = self.room;
                self.room.delegate = cvc;
                [self.navigationController pushViewController:cvc animated:YES];
                
//                UIStoryboard* sb = [UIStoryboard storyboardWithName:@"RTCMain" bundle:nil];
//                RTCChatViewController* cvc =
//                    [sb instantiateViewControllerWithIdentifier:@"sb_chat_view_controller"];
//
//                cvc.joinRoomCode = RCRTCCodeSuccess;
//                cvc.room = self.room;
//                self.room.delegate = cvc;
//                [self.navigationController pushViewController:cvc animated:YES];
            }
    });
        
}




@end
