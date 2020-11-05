//
//  RTCLoginViewController.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCLib.h>
#import <RongIMLib/RongIMLib.h>
#import "SettingViewController.h"
#import "LoginViewBuilder.h"
#import "LoginTextFieldDelegateImpl.h"
#import "Reachability.h"
#import "LoginManager.h"


@interface RTCLoginViewController : UIViewController <RCConnectionStatusChangeDelegate>

@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) NSURL *tokenURL;
@property (nonatomic, strong) NSString *userDefinedToken, *userDefinedCMP, *userDefinedAppKey;
@property (nonatomic, strong) SettingViewController *settingViewController;
@property (nonatomic, strong) LoginViewBuilder *loginViewBuilder;
@property (nonatomic, strong) LoginTextFieldDelegateImpl *loginTextFieldDelegateImpl;
@property (nonatomic, assign) BOOL isUserDefinedTokenAndCMP, isRoomNumberInput;
@property (nonatomic, strong) Reachability *networkReachability;
@property (nonatomic, assign) NetworkStatus currentNetworkStatus;

+ (NSDictionary *)selectedConfigData;
- (void)roomNumberTextFieldDidChange:(UITextField *)textField;
- (void)validateSMSTextFieldDidChange:(UITextField *)textField;
- (void)joinRoomButtonPressed:(id)sender;
- (void)sendSMSButtonPressed:(id)sender;
- (void)validateLogonButtonPressed:(id)sender;
- (void)onRadioButtonValueChanged:(RadioButton *)sender;
- (void)loginSettingButtonPressed;
- (void)updateJoinRoomButtonEnable:(BOOL)success textFieldInput:(BOOL)input;

@end
