//
//  RTCLoginViewController.m
//  SealRTC
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "RTCLoginViewController.h"
//#import "SealRTCAppDelegate.h"
#import "ChatViewController.h"
#import "CommonUtility.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+length.h"
#import "RTHttpNetworkWorker.h"
//#import "STCountryTableViewController.h"
//#import "RCDCountry.h"
#import "UIView+Toast.h"
#import "RCFetchTokenManager.h"
#import "RCSelectView.h"
#import "RCBackView.h"
#import "RTActiveWheel.h"

typedef NS_ENUM(NSInteger, TextFieldInputError)
{
    TextFieldInputErrorNil,
    TextFieldInputErrorLength,
    TextFieldInputErrorIllegal,
    TextFieldInputErrorNone
};

typedef NS_ENUM(NSInteger, JoinRoomState)
{
    JoinRoom_Token,
    JoinRoom_Connecting,
    JoinRoom_Disconnected,
};

static NSString * const SegueIdentifierChat = @"Chat";
static NSString * const SegueIdentifierAutoTest = @"AutoTest";
static NSDictionary *selectedServer;

@interface RTCLoginViewController ()<UIAlertViewDelegate,UITextFieldDelegate>
{
    NSUserDefaults *settingUserDefaults;
    TextFieldInputError inputError;
    JoinRoomState joinRoomState;
    NSTimer *countdownTimer;
    NSUInteger countdown;
    RCBackView *_backView;
}

@property(nonatomic, strong) RCRTCRoom* room;
@property(atomic, assign) BOOL isJoiningRoom;

@end


@implementation RTCLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isRoomNumberInput = YES;
    __weak typeof(self) weakSelf = self;
    self.view.userInteractionEnabled = YES;
    self.networkReachability = [Reachability reachabilityForInternetConnection];
    [self.networkReachability startNotifier];
    self.currentNetworkStatus = [self.networkReachability currentReachabilityStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginReachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    kLoginManager;
    
    self.loginTextFieldDelegateImpl = [[LoginTextFieldDelegateImpl alloc] initWithViewController:self];
    self.settingViewController = [[SettingViewController alloc] init];
    self.settingViewController.loginVC = self;
    self.loginViewBuilder = [[LoginViewBuilder alloc] initWithViewController:self];
    
    [UIView animateWithDuration:0.4 animations:^{
        weakSelf.view.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
        weakSelf.loginViewBuilder.loginIconImageView.frame = CGRectMake(weakSelf.loginViewBuilder.loginIconImageView.frame.origin.x, 50, weakSelf.loginViewBuilder.loginIconImageView.frame.size.width, weakSelf.loginViewBuilder.loginIconImageView.frame.size.height);
        CGFloat originY = 130;
        if (weakSelf.view.frame.size.width == 320) {
            originY = originY - 44;
        }
        weakSelf.loginViewBuilder.inputNumPasswordView.frame = CGRectMake(weakSelf.loginViewBuilder.inputNumPasswordView.frame.origin.x, originY, weakSelf.loginViewBuilder.inputNumPasswordView.frame.size.width, weakSelf.loginViewBuilder.inputNumPasswordView.frame.size.height);
        
    } completion:^(BOOL finished) {
    }];
    
    self.loginViewBuilder.roomNumberTextField.text = kLoginManager.roomNumber;
    self.loginViewBuilder.phoneNumTextField.text = kLoginManager.phoneNumber;
    self.loginViewBuilder.phoneNumLoginTextField.text = kLoginManager.phoneNumber;
    self.loginViewBuilder.usernameTextField.text = kLoginManager.username;
    if (kLoginManager.countryCode.length > 0 && kLoginManager.regionName.length > 0) {
        self.loginViewBuilder.countryCodeLabel.text = [NSString stringWithFormat:@"+%@",kLoginManager.countryCode];
        self.loginViewBuilder.loginCountryCodeLabel.text = [NSString stringWithFormat:@"+%@",kLoginManager.countryCode];
        NSString* select_fmt = @"选择国家和地区 %@";
        self.loginViewBuilder.countryTxtField.text = [NSString stringWithFormat:select_fmt,kLoginManager.regionName];
        self.loginViewBuilder.loginCountryTxtField.text = [NSString stringWithFormat:select_fmt,kLoginManager.regionName];
    }
    

    joinRoomState = JoinRoom_Token;
    
    [self updateSendSMSButtonEnable:[CommonUtility validateContactNumber:kLoginManager.phoneNumber]];
    
    if ([self.loginViewBuilder.roomNumberTextField.text isEqualToString:@""])
        self.isRoomNumberInput = NO;
    if (self.loginViewBuilder.usernameTextField.text.length <= 0) {
        self.isRoomNumberInput = NO;
    }
    [self updateJoinRoomButtonEnable:NO textFieldInput:self.isRoomNumberInput];
    
    [[RCIMClient sharedRCIMClient] initWithAppKey:RCIMAPPKey];
    
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Verbose];
#ifndef IS_PRIVATE_ENVIRONMENT
    [self checkAppVersion];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.navigationController.navigationBarHidden = YES;
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
    
#ifdef IS_PRIVATE_ENVIRONMENT
    if (kLoginManager.isPrivateEnvironment) {
        [[RCIMClient sharedRCIMClient] initWithAppKey:kLoginManager.privateAppKey];
        NSString *naviHost = kLoginManager.privateNavi;
        if (![naviHost hasPrefix:@"http"]) {
            naviHost = [@"https://" stringByAppendingString:naviHost];
        }
        [[RCIMClient sharedRCIMClient] setServerInfo:naviHost fileServer:nil];
    }
#endif
    DLog(@"Cache keyToken: %@", kLoginManager.keyToken);
    [self updateJoinRoomButtonEnable:YES textFieldInput:self.isRoomNumberInput];
    
    if (kLoginManager.isKickOff) {
        kLoginManager.isKickOff = NO;
        [self showAlertMessage:@"你已经被管理员移出房间,\n请稍后再尝试加入"];
    }
    // 如果刚进入这个界面，就代表不是正在加入房间，否则和这个变量定义的意义不符
    self.isJoiningRoom = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [_backView removeFromSuperview];
    _backView = nil;
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
    self.alertController = nil;
}

- (void)loginReachabilityChanged:(NSNotification *)noti
{
    Reachability *reachability = [noti object];
    self.currentNetworkStatus = [reachability currentReachabilityStatus];
    BOOL success = (self.currentNetworkStatus == NotReachable) ? NO : YES;
    if ((self.currentNetworkStatus == NotReachable))
        joinRoomState = JoinRoom_Disconnected;
    else
        joinRoomState = JoinRoom_Connecting;
    
    [self updateJoinRoomButtonEnable:success textFieldInput:self.isRoomNumberInput];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - setter
+ (NSDictionary *)selectedConfigData
{
    return selectedServer;
}

#pragma mark - room number text change
- (void)roomNumberTextFieldDidChange:(UITextField *)textField
{
    if (self.loginViewBuilder.roomNumberTextField.text.length <= 0 ||
        self.loginViewBuilder.usernameTextField.text.length <= 0 ||
        self.loginViewBuilder.phoneNumLoginTextField.text.length <= 0)
        self.isRoomNumberInput = NO;
    else
        self.isRoomNumberInput = YES;
    
    NSString *roomNum = self.loginViewBuilder.roomNumberTextField.text;
    roomNum = [roomNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (roomNum.length > 64) {
        roomNum = [roomNum substringToIndex:64];
    }
    self.loginViewBuilder.roomNumberTextField.text = roomNum;
    
    [self updateJoinRoomButtonEnable:YES textFieldInput:self.isRoomNumberInput];
}

- (void)userNameTextfieldDidChange:(UITextField*)textField {
    if (self.loginViewBuilder.roomNumberTextField.text.length <= 0 ||
        self.loginViewBuilder.usernameTextField.text.length <= 0 ||
        self.loginViewBuilder.phoneNumLoginTextField.text.length <= 0) {
        self.isRoomNumberInput = NO;
    } else {
        self.isRoomNumberInput = YES;
    }
    [self updateJoinRoomButtonEnable:YES textFieldInput:self.isRoomNumberInput];
}

- (void)phoneNumLoginTextFieldDidChange:(UITextField *)textField
{
    if (self.loginViewBuilder.roomNumberTextField.text.length <= 0 ||
        self.loginViewBuilder.usernameTextField.text.length <= 0 ||
        self.loginViewBuilder.phoneNumLoginTextField.text.length <= 0) {
        self.isRoomNumberInput = NO;
    } else  if ([CommonUtility validateContactNumber:self.loginViewBuilder.phoneNumLoginTextField.text]) {
        self.isRoomNumberInput = YES;
    }

    [self updateJoinRoomButtonEnable:YES textFieldInput:self.isRoomNumberInput];
}

- (void)validateSMSTextFieldDidChange:(UITextField *)textField
{
    if (![self.loginViewBuilder.validateSMSTextField.text isEqualToString:@""]
        && [CommonUtility validateContactNumber:self.loginViewBuilder.phoneNumTextField.text])
    {
        [self updateValidateLogonButtonEnable:YES];
    } else {
        [self updateValidateLogonButtonEnable:NO];
    }
}

#pragma mark - change join button enable/unenable
- (void)updateJoinRoomButtonEnable:(BOOL)success textFieldInput:(BOOL)input
{
    dispatch_async(dispatch_get_main_queue(), ^{
    if (success && input)
    {
        self.loginViewBuilder.joinRoomButton.enabled = YES;
        self.loginViewBuilder.joinRoomButton.backgroundColor = JoinButtonEnableBackgroundColor;
        self.loginViewBuilder.audioLiveBtn.enabled = YES;
        self.loginViewBuilder.audioLiveBtn.backgroundColor = JoinButtonEnableBackgroundColor;
        #ifdef IS_LIVE
            [self.loginViewBuilder.joinRoomButton setTitle:@"视频直播" forState:UIControlStateNormal];
            [self.loginViewBuilder.joinRoomButton setTitle:@"视频直播" forState:UIControlStateHighlighted];
        #else
            [self.loginViewBuilder.joinRoomButton setTitle:@"开始会议" forState:UIControlStateNormal];
            [self.loginViewBuilder.joinRoomButton setTitle:@"开始会议" forState:UIControlStateHighlighted];
        #endif
        
    }
    else
    {
        self.loginViewBuilder.joinRoomButton.enabled = NO;
        self.loginViewBuilder.joinRoomButton.backgroundColor = JoinButtonUnableBackgroundColor;
        self.loginViewBuilder.audioLiveBtn.enabled = NO;
        self.loginViewBuilder.audioLiveBtn.backgroundColor = JoinButtonUnableBackgroundColor;
        
        if (input)
        {
            switch (self->joinRoomState)
            {
//                case JoinRoom_Token:
//                {
//                    [self.loginViewBuilder.joinRoomButton setTitle:@"查询Token中" forState:UIControlStateNormal];
//                    [self.loginViewBuilder.joinRoomButton setTitle:@"查询Token中" forState:UIControlStateHighlighted];
//                }
//                    break;
                case JoinRoom_Connecting:
                {
                    [self.loginViewBuilder.joinRoomButton setTitle:@"连接中" forState:UIControlStateNormal];
                    [self.loginViewBuilder.joinRoomButton setTitle:@"连接中" forState:UIControlStateHighlighted];
                }
                    break;
                case JoinRoom_Disconnected:
                {
                    [self.loginViewBuilder.joinRoomButton setTitle:@"当前网络不可用，请检查网络设置" forState:UIControlStateNormal];
                    [self.loginViewBuilder.joinRoomButton setTitle:@"当前网络不可用，请检查网络设置" forState:UIControlStateHighlighted];
                }
                    break;
                default:
                    break;
            }
        }
        else
        {
            [self.loginViewBuilder.joinRoomButton setTitle:@"请输入房间号 ID" forState:UIControlStateNormal];
            [self.loginViewBuilder.joinRoomButton setTitle:@"请输入房间号 ID" forState:UIControlStateHighlighted];
        }
    }
    });
}

- (void)joinRoom {
    
#ifdef IS_LIVE
    [self navToChatViewController:YES];
#else
    [RTActiveWheel showHUDAddedTo:self.view];
    
    [[RCRTCEngine sharedInstance]
     joinRoom:kLoginManager.roomNumber
     completion:^(RCRTCRoom * _Nullable room, RCRTCCode code) {
        [RTActiveWheel dismissForView:self.view];
        if (code == RCRTCCodeSuccess) {
            self.room = room;
            [self navToChatViewController:YES];
        } else if (room.remoteUsers.count >= MAX_NORMAL_PERSONS &&
                   room.remoteUsers.count < MAX_AUDIO_PERSONS) {
            [self showJoinPromptOfAudioMode];
        } else if (room.remoteUsers.count >= MAX_AUDIO_PERSONS) {
            [self showJoinPromtOfObserverMode];
        } else {
            [self showInfomationWithErrorCode:code];
        }
        self.isJoiningRoom = NO;
    }];
#endif
    
}

- (void)showInfomationWithErrorCode:(RCRTCCode)code {
    NSString* message;
    if (code == 40021) {
        message = @"您被禁止加入该房间!";
    } else {
        message = [NSString stringWithFormat:@"加入房间失败: %zd",code];
    }
    UIAlertAction* action =
    [UIAlertAction actionWithTitle:@"确认"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [self showNoTitleAlertWithActions:@[action]
                              message:message];
}

- (void)showJoinPromptOfAudioMode {
    NSString* message = [NSString stringWithFormat:@"会议室中视频通话人数已超过 %d 人，你将以音频模式加入会议室。",MAX_NORMAL_PERSONS];
    
    UIAlertAction* okAction =
    [UIAlertAction actionWithTitle:@"确定"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action) {
        [self navToChatViewController:YES];
    }];
    UIAlertAction* cancelAction =
    [UIAlertAction actionWithTitle:@"取消"
                             style:UIAlertActionStyleDefault
                           handler:nil];
    [self showNoTitleAlertWithActions:@[okAction, cancelAction]
                              message:message];
}

- (void)showJoinPromtOfObserverMode {
    NSString* message = [NSString stringWithFormat:@"会议室中人数已超过 %d 人，你将以旁听者模式加入会议室。",MAX_AUDIO_PERSONS];
    
    UIAlertAction* okAction =
    [UIAlertAction actionWithTitle:@"确定"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action) {
        [self navToChatViewController:YES];
    }];
    UIAlertAction* cancelAction =
    [UIAlertAction actionWithTitle:@"取消"
                             style:UIAlertActionStyleDefault
                           handler:nil];
    [self showNoTitleAlertWithActions:@[okAction, cancelAction]
                              message:message];
}

- (void)showNoTitleAlertWithActions:(NSArray<UIAlertAction*>*)actions
                            message:(NSString*)msg {
    UIAlertController* alert =
        [UIAlertController alertControllerWithTitle:nil
                                            message:msg
                                     preferredStyle:UIAlertControllerStyleAlert];
    for (UIAlertAction* action in actions) {
        [alert addAction:action];
    }
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

#pragma mark - prepareForSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

- (void)navToChatViewController:(BOOL)isHost {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.loginViewBuilder.roomNumberTextField resignFirstResponder];
        
        if (![self.navigationController.topViewController isKindOfClass:[ChatViewController class]]) {
            DLog(@"performSegueWithIdentifier to ChatViewController");
            #ifdef IS_LIVE
                [kLoginManager setIsHost:isHost];
            #else
                
            #endif

            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ChatViewController* cvc =
                [sb instantiateViewControllerWithIdentifier:@"sb_chat_view_controller"];
            cvc.joinRoomCode = RCRTCCodeSuccess;
            cvc.room = self.room;
            self.room.delegate = cvc;
            [self.navigationController pushViewController:cvc animated:YES];
        }
    });
        
}

#pragma mark - click join Button
- (void)audioLiveButtonPressed:(id)sender {
    if (self.isJoiningRoom) return;

    self.isJoiningRoom = YES;
    kLoginManager.roomNumber = self.loginViewBuilder.roomNumberTextField.text;
    kLoginManager.phoneNumber = self.loginViewBuilder.phoneNumLoginTextField.text;
    kLoginManager.username = self.loginViewBuilder.usernameTextField.text;
        
    DLog(@"Cache keyToken: %@", kLoginManager.keyToken);
    if (!kLoginManager.keyToken || kLoginManager.keyToken.length == 0) {
        self.loginViewBuilder.phoneNumTextField.text = kLoginManager.phoneNumber;
        [self.loginViewBuilder showValidateView:YES];
        self.loginViewBuilder.countryTxtField.delegate = self;
        DLog(@"To get SMS validate code");
        [self updateSendSMSButtonEnable:[CommonUtility validateContactNumber:kLoginManager.phoneNumber]];
        CGFloat  originY = 186;
        if (self.view.frame.size.width == 320) {
            originY = originY - 44;
        }
        self.loginViewBuilder.inputNumPasswordView.frame = 
            CGRectMake(0, 
                       originY,
                       self.loginViewBuilder.inputNumPasswordView.frame.size.width, 
                       self.loginViewBuilder.inputNumPasswordView.frame.size.height);
        self.isJoiningRoom = NO;
    } else if (kLoginManager.isIMConnectionSucc) {
        DLog(@"navToChatViewController");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"audio"];
        [self navToChatViewController:YES];
        self.isJoiningRoom = NO;
    } else {
        DLog(@"start to connectWithToken");
        [[RCIMClient sharedRCIMClient] connectWithToken:kLoginManager.keyToken
                                               dbOpened:^(RCDBErrorCode code) {
                DLog(@"MClient dbOpened code: %zd", code);
            } success:^(NSString *userId) {
                DLog(@"MClient connectWithToken Success userId: %@", userId);
                kLoginManager.userID = userId;
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"audio"];
                dispatch_async(dispatch_get_main_queue(), ^{
                        [self joinRoom];
                    });
            } error:^(RCConnectErrorCode status) {
                DLog(@"MClient connectWithToken Error: %zd", status);
                self.isJoiningRoom = NO;
                if (kLoginManager.isPrivateEnvironment) {
                    kLoginManager.keyToken = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                            [self.view makeToast:@"连接出错" 
                                        duration:3 
                                        position:CSToastPositionCenter];
                        });
                } else if (status == RC_CONN_TOKEN_INCORRECT) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                            [self.loginViewBuilder showValidateView:YES];
                        });
                }
            }];
    }
}

- (void)joinRoomButtonPressed:(id)sender {
    if (self.isJoiningRoom) return;

    self.isJoiningRoom = YES;
    if (kLoginManager.kickOffTime + 5 * 60 > [[NSDate date] timeIntervalSince1970]
        && [kLoginManager.kickOffRoomNumber isEqualToString:self.loginViewBuilder.roomNumberTextField.text]) {
        [self showAlertMessage:@"你已经被管理员移出房间,\n请稍后再尝试加入"];
        self.isJoiningRoom = NO;
        return;
    }
    
    kLoginManager.roomNumber = self.loginViewBuilder.roomNumberTextField.text;
    kLoginManager.phoneNumber = self.loginViewBuilder.phoneNumLoginTextField.text;
    kLoginManager.username = self.loginViewBuilder.usernameTextField.text;
    
#ifdef IS_PRIVATE_ENVIRONMENT
    if (!kLoginManager.isPrivateEnvironment) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:@"环境配置错误" duration:1.5 position:CSToastPositionCenter];
        });
        self.isJoiningRoom = NO;
        return;
    }
#endif
    
    DLog(@"Cache keyToken: %@", kLoginManager.keyToken);
    if (!kLoginManager.keyToken || kLoginManager.keyToken.length == 0) {
        if (kLoginManager.isPrivateEnvironment && kLoginManager.privateAppSecret.length > 0) {
            //此处生成私有云UserID
            NSString *userId = [NSString stringWithFormat:@"%@_%@_ios", kLoginManager.phoneNumber, kDeviceUUID];
            [[RCFetchTokenManager sharedManager] fetchTokenWithUserId:userId username:@"" portraitUri:@"" completion:^(BOOL isSucccess, NSString * _Nullable token) {
                if (isSucccess && token.length > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        kLoginManager.keyToken = token;
                        [self joinRoomButtonPressed:nil];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.view makeToast:@"环境配置错误" duration:1.5 position:CSToastPositionCenter];
                    });
                }
            }];
        } else {
//            self.loginViewBuilder.phoneNumTextField.text = kLoginManager.phoneNumber;
//            [self.loginViewBuilder showValidateView:YES];
//            self.loginViewBuilder.countryTxtField.delegate = self;
//            DLog(@"To get SMS validate code");
//            [self updateSendSMSButtonEnable:[CommonUtility validateContactNumber:kLoginManager.phoneNumber]];
//            CGFloat  originY = 186;
//            if (self.view.frame.size.width == 320) {
//                originY = originY - 44;
//            }
//            self.loginViewBuilder.inputNumPasswordView.frame =
//                CGRectMake(0,
//                           originY,
//                           self.loginViewBuilder.inputNumPasswordView.frame.size.width,
//                           self.loginViewBuilder.inputNumPasswordView.frame.size.height);
            
            //小度
//            NSString *userId = [NSString stringWithFormat:@"a44d7a30-147b-49aa-9369-fa474937c2f2"];
            NSString *userId = [NSString stringWithFormat:@"%@_%@_ios", kLoginManager.phoneNumber, kDeviceUUID];
            [[RCFetchTokenManager sharedManager] pxd_fetchTokenWithUserId:userId username:@"小度" portraitUri:@"https://api.yizhitong100.com/IMG/manager/doctor/4cdfa9c4bb9b48c7bcf933af779610dc.jpg" completion:^(BOOL isSucccess, NSString * _Nullable token) {
                if (isSucccess && token.length > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        kLoginManager.keyToken = token;
                        [self joinRoomButtonPressed:nil];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.view makeToast:@"环境配置错误" duration:1.5 position:CSToastPositionCenter];
                    });
                }
            }];
        }
        self.isJoiningRoom = NO;
    } else if (kLoginManager.isIMConnectionSucc) {
        DLog(@"navToChatViewController");
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"audio"];
        //[self navToChatViewController:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self joinRoom];
        });
    } else {
        DLog(@"start to connectWithToken");
        [[RCIMClient sharedRCIMClient] connectWithToken:kLoginManager.keyToken
                                               dbOpened:^(RCDBErrorCode code) {
            DLog(@"MClient dbOpened code: %zd", code);
            
        }
                                                success:^(NSString *userId) {
            DLog(@"MClient connectWithToken Success userId: %@", userId);
            kLoginManager.userID = userId;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"audio"];
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
                    [self.loginViewBuilder showValidateView:YES];
                });
            }
        }];
    }
}

- (void)watchLiveButtonPressed:(id)sender
{
    [self get10host:^(NSString *url) {
        if (url) {
            kLoginManager.liveUrl = url;
            kLoginManager.roomNumber = self.loginViewBuilder.roomNumberTextField.text;
                kLoginManager.phoneNumber = self.loginViewBuilder.phoneNumLoginTextField.text;
                kLoginManager.username = self.loginViewBuilder.usernameTextField.text;
                
                DLog(@"Cache keyToken: %@", kLoginManager.keyToken);
                if (!kLoginManager.keyToken || kLoginManager.keyToken.length == 0) {
                    self.loginViewBuilder.phoneNumTextField.text = kLoginManager.phoneNumber;
                    [self.loginViewBuilder showValidateView:YES];
                    self.loginViewBuilder.countryTxtField.delegate = self;
                    DLog(@"To get SMS validate code");
                    [self updateSendSMSButtonEnable:[CommonUtility validateContactNumber:kLoginManager.phoneNumber]];
                    CGFloat  originY = 186;
                    if (self.view.frame.size.width == 320) {
                        originY = originY - 44;
                    }
                    self.loginViewBuilder.inputNumPasswordView.frame = 
                      CGRectMake(0, 
                                 originY,
                                 self.loginViewBuilder.inputNumPasswordView.frame.size.width,
                                 self.loginViewBuilder.inputNumPasswordView.frame.size.height);
                }
                else if (kLoginManager.isIMConnectionSucc) {
                    DLog(@"navToChatViewController");
                    [self navToChatViewController:NO];
                }
                else {
                    DLog(@"start to connectWithToken");
                    [[RCIMClient sharedRCIMClient]
                     connectWithToken:kLoginManager.keyToken
                     dbOpened:^(RCDBErrorCode code) {
                        
                    } success:^(NSString *userId) {
                        DLog(@"MClient connectWithToken Success userId: %@", userId);
                        kLoginManager.userID = userId;
                        [self navToChatViewController:NO];
                    } error:^(RCConnectErrorCode status) {
                        DLog(@"MClient connectWithToken Error: %zd", status);
                        if (status == RC_CONN_TOKEN_INCORRECT) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.loginViewBuilder showValidateView:YES];
                            });
                        }
                    }];
                }
        }
    }];
    
}
- (void)get10host:(void (^)(NSString *url))completion{
    [[RTHttpNetworkWorker shareInstance] query:@"" completion:^(BOOL isSuccess, NSArray * _Nullable list) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isSuccess || !list) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"获取直播列表" message:[NSString stringWithFormat:@"获取直播列表：%@",!isSuccess?@"失败":@"为空" ]preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"朕知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    if (completion) {
                        completion(nil);
                    }
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:^{
                    
                }];
            } else {
                NSMutableArray *arr = [NSMutableArray array];
                for (int i = 0 ; i < list.count; i ++) {
                    RCSelectModel *model = [[RCSelectModel alloc] init];
                    NSDictionary *dic = list[i];
                    model.rooomId = dic[@"roomId"];
                    model.roomName = dic[@"roomName"];
                    model.liveUrl = dic[@"mcuUrl"];
                    [arr addObject:model];
                }
                RCBackView *backView = [[RCBackView alloc] initWithFrame:self.view.bounds];
                [backView reload:arr];
                self->_backView = backView;
                [backView setCallBack:^(RCSelectModel * _Nonnull model) {
                    if (!model) {
                        [self->_backView removeFromSuperview];
                        self->_backView = nil;
                        completion(nil);
                    } else {
                        if (completion) {
                            completion(model.liveUrl);
                        }
                    }
                }];
                [[UIApplication sharedApplication].keyWindow addSubview:backView];
                
            }
        });
    }];
}

#pragma mark - click send SMS button
- (void)sendSMSButtonPressed:(id)sender
{
    [self startSendSMSTimer];
    NSString* code = [self.loginViewBuilder.countryCodeLabel.text substringFromIndex:1];
    [[RTHttpNetworkWorker shareInstance] fetchSMSValidateCode:self.loginViewBuilder.phoneNumTextField.text regionCode:code
                                                      success:^(NSString * _Nonnull code) {
                                                          DLog(@"send SMS respond code: %@", code);
                                                      } error:^(NSError * _Nonnull error) {
                                                          DLog(@"send SMS request Error: %@", error);
                                                      }];
}

#pragma mark - click validate logon button
- (void)validateLogonButtonPressed:(id)sender
{
    NSString* regionCode = [self.loginViewBuilder.countryCodeLabel.text substringFromIndex:1];
    [[RTHttpNetworkWorker shareInstance]
     validateSMSPhoneNum:self.loginViewBuilder.phoneNumTextField.text
     regionCode:regionCode
     code:self.loginViewBuilder.validateSMSTextField.text
     response:^(NSDictionary * _Nonnull respDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger code = [respDict[@"code"] integerValue];
            if (code == 200) {
                kLoginManager.isIMConnectionSucc = NO;
                [self.loginViewBuilder showValidateView:NO];
                kLoginManager.phoneNumber = self.loginViewBuilder.phoneNumTextField.text;
                self.loginViewBuilder.phoneNumLoginTextField.text = kLoginManager.phoneNumber;
                
                kLoginManager.keyToken = respDict[@"result"][@"token"];
                // 根据返回值设置 IM navi
                kLoginManager.navi = respDict[@"result"][@"navi"];
                NSString *fileHost = RCIMFileURL;
                if (![fileHost hasPrefix:@"http"]) {
                    fileHost = [@"https://" stringByAppendingString:RCIMFileURL];
                }
                NSString *navi = kLoginManager.navi;
                
                [[RCIMClient sharedRCIMClient] setServerInfo:navi.length > 0 ? navi : RCIMNavURL fileServer:fileHost];
                kLoginManager.isLoginTokenSucc = YES;
                self->joinRoomState = JoinRoom_Connecting;
                [self updateJoinRoomButtonEnable:YES textFieldInput:self.isRoomNumberInput];
            }
            else {
                self.loginViewBuilder.alertLabel.text = @"验证码错误, 请重新获取";
            }
        });
    } error:^(NSError * _Nonnull error) {
        self.loginViewBuilder.alertLabel.text = @"验证码错误, 请重新获取";
    }];
}

#pragma mark - click setting button
- (void)loginSettingButtonPressed
{
    if (![self.navigationController.topViewController isKindOfClass:[SettingViewController class]])
        [self.navigationController pushViewController:self.settingViewController animated:YES];
}

#pragma mark - click redio button
- (void)onRadioButtonValueChanged:(RadioButton *)radioButton
{
    if (radioButton.tag == 0)
    {
        if (radioButton.selected)
        {
            kLoginManager.isCloseCamera = YES;
            kLoginManager.isObserver = NO;
        }
        else
            kLoginManager.isCloseCamera = NO;
    }
    else if (radioButton.tag == 1)
    {
        if (radioButton.selected)
        {
            kLoginManager.isCloseCamera = NO;
            kLoginManager.isObserver = YES;
        }
        else
            kLoginManager.isObserver = NO;
    }
    
    [self.loginViewBuilder.roomNumberTextField resignFirstResponder];
    [self.loginViewBuilder.phoneNumLoginTextField resignFirstResponder];
}

#pragma mark - gesture selector method
- (IBAction)didTapHideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - Private
- (void)startSendSMSTimer
{
    if (countdown == 0 && !countdownTimer)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateSendSMSButtonEnable:NO];
            NSString *cTime = [NSString stringWithFormat:@"60%@", @"秒"];
            [self.loginViewBuilder.sendSMSButton setTitle:cTime forState:UIControlStateNormal];
            [self.loginViewBuilder.sendSMSButton setTitle:cTime forState:UIControlStateHighlighted];
            
            self->countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountDownLabel) userInfo:nil repeats:YES];
        });
    }
}

- (void)updateCountDownLabel
{
    countdown++;
    if (countdown < 60) {
        NSInteger cdSec = 60 - countdown;
        NSString *cTime = [NSString stringWithFormat:@"%zd%@", cdSec, @"秒"];
        [self.loginViewBuilder.sendSMSButton setTitle:cTime forState:UIControlStateNormal];
        [self.loginViewBuilder.sendSMSButton setTitle:cTime forState:UIControlStateHighlighted];
    }
    else {
        countdown = 0;
        [countdownTimer invalidate];
        countdownTimer = nil;
        [self updateSendSMSButtonEnable:[CommonUtility validateContactNumber:self.loginViewBuilder.phoneNumTextField.text]];
        [self.loginViewBuilder.sendSMSButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.loginViewBuilder.sendSMSButton setTitle:@"获取验证码" forState:UIControlStateHighlighted];
    }
}

- (void)updateSendSMSButtonEnable:(BOOL)isEnable
{
    self.loginViewBuilder.sendSMSButton.enabled = isEnable;
    self.loginViewBuilder.sendSMSButton.backgroundColor = isEnable ? JoinButtonEnableBackgroundColor : JoinButtonUnableBackgroundColor;
}

- (void)updateValidateLogonButtonEnable:(BOOL)isEnable
{
    self.loginViewBuilder.validateLogonButton.enabled = isEnable;
    self.loginViewBuilder.validateLogonButton.backgroundColor = isEnable ? JoinButtonEnableBackgroundColor : JoinButtonUnableBackgroundColor;
}

- (void)showAlertMessage:(NSString *)msg {
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertController *controler = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    [controler addAction:okAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:controler animated:YES completion:^{}];
    });
}

#pragma mark - RCConnectionStatusChangeDelegate
- (void)onConnectionStatusChanged:(RCConnectionStatus)status
{
    switch (status) {
        case ConnectionStatus_Connected:
        {
            kLoginManager.isIMConnectionSucc = YES;
            [self updateJoinRoomButtonEnable:kLoginManager.isIMConnectionSucc textFieldInput:self.isRoomNumberInput];
        }
            break;
        case ConnectionStatus_Unconnected:
        {
            kLoginManager.isIMConnectionSucc = NO;
        }
            break;
        case ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT:
        {
            kLoginManager.isIMConnectionSucc = NO;
//            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:nil message:@"此用户已在其他设备登录，可修改用户名后再尝试登录" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//            [alertV show];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            }];
            [self showNoTitleAlertWithActions:@[action] message:@"此用户已在其他设备登录，可修改用户名后再尝试登录"];
        }
        default:
            break;
    }
}

//- (void)fetchCountryPhoneCode:(RCDCountry*)info {
//    self.loginViewBuilder.countryCodeLabel.text = [NSString stringWithFormat:@"+%@",info.phoneCode];
//    self.loginViewBuilder.loginCountryCodeLabel.text = [NSString stringWithFormat:@"+%@",info.phoneCode];
//    NSString* select_fmt = NSLocalizedString(@"select_country_fmt", nil);
//    self.loginViewBuilder.countryTxtField.text = [NSString stringWithFormat:select_fmt,info.countryName];
//    self.loginViewBuilder.loginCountryTxtField.text = [NSString stringWithFormat:select_fmt,info.countryName];
//    kLoginManager.countryCode = info.phoneCode;
//    kLoginManager.regionName = info.countryName;
//}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.loginViewBuilder.countryTxtField ||
        textField == self.loginViewBuilder.loginCountryTxtField ) {
//        STCountryTableViewController* stc = [[STCountryTableViewController alloc] init];
//        stc.delegate = self;
//        [self.navigationController pushViewController:stc animated:YES];
        return NO;
    }
    return  YES;
}

- (void)checkAppVersion
{
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait ;
}

@end
