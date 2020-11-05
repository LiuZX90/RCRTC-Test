//
//  LoginViewBuilder.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "LoginViewBuilder.h"
#import "RTCLoginViewController.h"
#import "NSString+length.h"
#define kMaxInputNum 12

@interface LoginViewBuilder () <UITextFieldDelegate>

@property (nonatomic, strong) RTCLoginViewController *loginViewController;

@end

@implementation LoginViewBuilder

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.loginViewController = (RTCLoginViewController *) vc;
        [self initNewView];
    }
    return self;
}

- (void)initNewView
{
    //设置按钮
    self.loginSettingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginSettingButton.frame = CGRectMake(MainscreenWidth - 36 - 16, 36, 36, 36);
    [self.loginSettingButton setImage:[UIImage imageNamed:@"login_setting"] forState:UIControlStateNormal];
    [self.loginSettingButton setImage:[UIImage imageNamed:@"login_setting"] forState:UIControlStateHighlighted];
    [self.loginSettingButton addTarget:self.loginViewController action:@selector(loginSettingButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.loginSettingButton.backgroundColor = [UIColor clearColor];
    [self.loginViewController.view addSubview:self.loginSettingButton];
    
    //logo
    self.loginIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((MainscreenWidth - 75) / 2, 150, 75, 75)];
#ifdef IS_PRIVATE_ENVIRONMENT
    self.loginIconImageView.image = [UIImage imageNamed:@"splash_logo_private"];
#else
    self.loginIconImageView.image = [UIImage imageNamed:@"splash_logo"];
#endif
    [self.loginViewController.view addSubview:self.loginIconImageView];
    
    //下方输入view
    
    NSInteger passwordViewHeight = MainscreenHeight - 186 + 54;
    if (self.loginViewController.view.frame.size.width == 320) {
        passwordViewHeight = passwordViewHeight - 20 + 64;
    }
    self.inputNumPasswordView = [[UIView alloc] initWithFrame:CGRectMake(0, MainscreenHeight, MainscreenWidth, passwordViewHeight)];
    self.inputNumPasswordView.backgroundColor = [UIColor whiteColor];
    [self.loginViewController.view addSubview:self.inputNumPasswordView];
    
    //分隔线
    self.lineLayer = [CALayer layer];
    self.lineLayer.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
    self.lineLayer.frame = CGRectMake(0, 0, self.inputNumPasswordView.frame.size.width, 0.5);
    [self.inputNumPasswordView.layer addSublayer:self.lineLayer];
    
    //欢迎体验实时高质量的音视频会议
    
    CGFloat originY = 60;
    if (self.loginViewController.view.frame.size.width == 320) {
        originY = originY - 35;
    }
    self.welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, MainscreenWidth, 26)];
    self.welcomeLabel.textAlignment = NSTextAlignmentCenter;
    self.welcomeLabel.font = [UIFont systemFontOfSize:18];
    self.welcomeLabel.textColor = [UIColor colorWithRed:105.0/255.0 green:214.0/255.0 blue:251.0/255.0 alpha:1.0];
    self.welcomeLabel.text = @"欢迎体验高清晰低延迟的实时音视频会议";
    [self.inputNumPasswordView addSubview:self.welcomeLabel];
    
    //SealRTC V3.0.0
    self.versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.welcomeLabel.frame.origin.y + self.welcomeLabel.frame.size.height, MainscreenWidth, 26)];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;
    self.versionLabel.font = [UIFont systemFontOfSize:14];
    self.versionLabel.textColor = [UIColor colorWithRed:105.0/255.0 green:214.0/255.0 blue:251.0/255.0 alpha:1.0];
    self.versionLabel.text = APP_Version;
    [self.inputNumPasswordView addSubview:self.versionLabel];
    
    //请输入会议室名称
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, self.versionLabel.frame.origin.y + self.versionLabel.frame.size.height + 10, MainscreenWidth - 60, 26)];
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = JoinButtonEnableBackgroundColor;
    self.titleLabel.text = @"输入以下信息开始会议";
    [self.inputNumPasswordView addSubview:self.titleLabel];
    
    //房间号
    self.roomNumberTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 10, MainscreenWidth - 60, 44)];
    self.roomNumberTextField.tag = 300936;
    self.roomNumberTextField.font = [UIFont systemFontOfSize:18];
    self.roomNumberTextField.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    self.roomNumberTextField.textAlignment = NSTextAlignmentLeft;
    self.roomNumberTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.roomNumberTextField.returnKeyType = UIReturnKeyDone;
    self.roomNumberTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.roomNumberTextField.placeholder = @"请输入会议室ID";
    self.roomNumberTextField.delegate = self.loginViewController.loginTextFieldDelegateImpl;
    self.roomNumberTextField.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [self.roomNumberTextField addTarget:self.loginViewController action:@selector(roomNumberTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.inputNumPasswordView addSubview:self.roomNumberTextField];
    
    // 用户名称
    self.usernameTextField = [[UITextField alloc]initWithFrame:CGRectMake(30, self.roomNumberTextField.frame.origin.y + self.roomNumberTextField.frame.size.height + 10, MainscreenWidth - 60, 44)];
    self.usernameTextField.tag = 300937;
    self.usernameTextField.font = [UIFont systemFontOfSize:18];
    self.usernameTextField.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    self.usernameTextField.textAlignment = NSTextAlignmentLeft;
    self.usernameTextField.returnKeyType = UIReturnKeyDone;
    self.usernameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.usernameTextField.placeholder = @"请输入用户名称";
    self.usernameTextField.delegate = self.loginViewController.loginTextFieldDelegateImpl;
    self.usernameTextField.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.usernameTextField addTarget:self.loginViewController action:@selector(userNameTextfieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    #pragma clang diagnostic pop
    [self.inputNumPasswordView addSubview:self.usernameTextField];

    CGFloat height;
    
#ifndef IS_PRIVATE_ENVIRONMENT
    //国家和地区
    UITextField* loginCountryTxtField = [[UITextField alloc] initWithFrame:(CGRect){30,self.usernameTextField.frame.origin.y + self.usernameTextField.frame.size.height + 10,MainscreenWidth - 60,44}];
    //loginCountryTxtField.textColor = [UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:153.0f/255.0f alpha:1];
    loginCountryTxtField.font = [UIFont systemFontOfSize:18];
    //countryTxtField.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    loginCountryTxtField.textAlignment = NSTextAlignmentLeft;
    loginCountryTxtField.borderStyle = UITextBorderStyleRoundedRect;
    loginCountryTxtField.text = [NSString stringWithFormat:@"选择国家和地区 %@", kLoginManager.regionName];
    loginCountryTxtField.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    UILabel* loginArrowLabel = [[UILabel alloc] initWithFrame:(CGRect){0,0,44,44}];
    loginArrowLabel.textAlignment = NSTextAlignmentCenter;
    loginArrowLabel.text = @"＞";
    loginArrowLabel.textColor = [UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:153.0f/255.0f alpha:1];
    loginCountryTxtField.rightView = loginArrowLabel;
    loginCountryTxtField.rightViewMode = UITextFieldViewModeAlways;
    loginCountryTxtField.delegate = self.loginViewController;
    [self.inputNumPasswordView addSubview:loginCountryTxtField];
    self.loginCountryTxtField = loginCountryTxtField;
    
    originY = loginCountryTxtField.frame.origin.y;
    height = self.loginCountryTxtField.frame.size.height;
#else
    originY = self.usernameTextField.frame.origin.y;
    height = self.usernameTextField.frame.size.height;
#endif
    //手机号
    self.phoneNumLoginTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, originY + height + 10, MainscreenWidth - 60, 44)];
    self.phoneNumLoginTextField.font = [UIFont systemFontOfSize:18];
    self.phoneNumLoginTextField.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    self.phoneNumLoginTextField.textAlignment = NSTextAlignmentLeft;
    self.phoneNumLoginTextField.keyboardType = UIKeyboardTypePhonePad;
    self.phoneNumLoginTextField.returnKeyType = UIReturnKeySend;
    self.phoneNumLoginTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.phoneNumLoginTextField.placeholder = @"请输入手机号";
    self.phoneNumLoginTextField.delegate = self.loginViewController.loginTextFieldDelegateImpl;
    self.phoneNumLoginTextField.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.phoneNumLoginTextField addTarget:self.loginViewController action:@selector(phoneNumLoginTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
#pragma clang diagnostic pop
    
    UILabel* codelabel = [[UILabel alloc] initWithFrame:(CGRect){0,0,44,44}];
    codelabel.text = @"+86";
    codelabel.textAlignment = NSTextAlignmentCenter;
    self.phoneNumLoginTextField.leftView = codelabel;
    self.loginCountryCodeLabel = codelabel;
    self.phoneNumLoginTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.inputNumPasswordView addSubview:self.phoneNumLoginTextField];
    
    //RadioButton
    UIView *rbView = [[UIView alloc] initWithFrame:CGRectMake(0, self.phoneNumLoginTextField.frame.origin.y + self.phoneNumLoginTextField.frame.size.height + 5, MainscreenWidth, 75)];
    self.radioButtons = [NSMutableArray arrayWithCapacity:3];
    CGRect btnRect = CGRectMake(30, 10, MainscreenWidth - 60, 24);
    NSArray *optionTitles = @[@"音频模式", @"旁听者模式"];
    
    for (NSInteger i = 0; i < [optionTitles count]; i++)
    {
        RadioButton *btn = [[RadioButton alloc] initWithFrame:btnRect];
        btn.tag = i;
        [btn addTarget:self.loginViewController action:@selector(onRadioButtonValueChanged:) forControlEvents:UIControlEventValueChanged];
        btnRect.origin.y += 30;
        [btn setTitle:optionTitles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setImage:[UIImage imageNamed:@"login_radio_uncheck.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"login_radio_check.png"] forState:UIControlStateSelected];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [rbView addSubview:btn];
        [btn setSelected:NO];
        [self.radioButtons addObject:btn];
    }
    
    [self.radioButtons[0] setGroupButtons:self.radioButtons]; // Setting buttons into the group
    //    [self.radioButtons[0] setSelected:YES]; // Making the first button initially selected
    [self.inputNumPasswordView addSubview:rbView];
    
    //加入会议室按钮
    self.joinRoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    #ifdef IS_LIVE
        self.joinRoomButton.frame = CGRectMake(30, self.phoneNumLoginTextField.frame.origin.y + self.phoneNumLoginTextField.frame.size.height + 85, (ScreenWidth - 60) / 2 - 10, 44);
    #else
        self.joinRoomButton.frame = CGRectMake(30, self.phoneNumLoginTextField.frame.origin.y + self.phoneNumLoginTextField.frame.size.height + 85, MainscreenWidth - 60, 44);
    #endif
     
    
    [self.joinRoomButton setTintColor:[UIColor whiteColor]];
    self.joinRoomButton.titleLabel.font = [UIFont systemFontOfSize:18];
    self.joinRoomButton.enabled = NO;
    self.joinRoomButton.backgroundColor = JoinButtonUnableBackgroundColor;
    [self.joinRoomButton.layer setMasksToBounds:YES];
    [self.joinRoomButton.layer setCornerRadius:4.0];
    [self.joinRoomButton addTarget:self.loginViewController action:@selector(joinRoomButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputNumPasswordView addSubview:self.joinRoomButton];
    
    //加入会议室按钮
    self.audioLiveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.audioLiveBtn.frame = CGRectMake(self.joinRoomButton.frame.origin.x + 10 + self.joinRoomButton.frame.size.width, self.phoneNumLoginTextField.frame.origin.y + self.phoneNumLoginTextField.frame.size.height + 85, (MainscreenWidth - 60) / 2 - 10, 44);
    [self.audioLiveBtn setTintColor:[UIColor whiteColor]];
    self.audioLiveBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    self.audioLiveBtn.enabled = NO;
    self.audioLiveBtn.backgroundColor = JoinButtonUnableBackgroundColor;
    [self.audioLiveBtn.layer setMasksToBounds:YES];
    [self.audioLiveBtn.layer setCornerRadius:4.0];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.audioLiveBtn addTarget:self.loginViewController action:@selector(audioLiveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
    [self.audioLiveBtn setTitle:@"音频直播" forState:UIControlStateNormal];
    [self.audioLiveBtn setTitle:@"音频直播" forState:UIControlStateHighlighted];
#ifdef IS_LIVE
    [self.inputNumPasswordView addSubview:self.audioLiveBtn];
#else
    
#endif
    
    
    //观看直播
    self.watchLiveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.watchLiveButton.frame = CGRectMake(30, self.phoneNumLoginTextField.frame.origin.y + self.phoneNumLoginTextField.frame.size.height + 85 + self.joinRoomButton.frame.size.height + 30, MainscreenWidth - 60, 44);
    [self.watchLiveButton setTintColor:[UIColor whiteColor]];
    self.watchLiveButton.titleLabel.font = [UIFont systemFontOfSize:18];
    self.watchLiveButton.enabled = NO;
    self.watchLiveButton.backgroundColor = JoinButtonUnableBackgroundColor;
    [self.watchLiveButton.layer setMasksToBounds:YES];
    [self.watchLiveButton.layer setCornerRadius:4.0];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.watchLiveButton addTarget:self.loginViewController action:@selector(watchLiveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
    self.watchLiveButton.enabled = YES;
    self.watchLiveButton.backgroundColor = JoinButtonEnableBackgroundColor;
    [self.watchLiveButton setTitle:@"观看直播" forState:UIControlStateNormal];
    [self.watchLiveButton setTitle:@"观看直播" forState:UIControlStateHighlighted];
#ifdef IS_LIVE
    [self.inputNumPasswordView addSubview:self.watchLiveButton];
#else
    
#endif
    
    
    
    //短信验证********************************************************************
    self.validateView = [[UIView alloc] initWithFrame:CGRectMake(0, self.versionLabel.frame.origin.y + self.versionLabel.frame.size.height + 10, MainscreenWidth, self.inputNumPasswordView.frame.size.height -  (self.versionLabel.frame.origin.y + self.versionLabel.frame.size.height + 10))];
    if(self.loginViewController.view.frame.size.width == 320){
        CGRect frame =  self.validateView.frame;
        frame.size.height += 54;
        self.validateView.frame = frame;
    }
    self.validateView.backgroundColor = [UIColor whiteColor];
    
    //请输入手机号验证登录
    self.phoneNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, MainscreenWidth - 60, 26)];
    self.phoneNumLabel.textAlignment = NSTextAlignmentCenter;
    self.phoneNumLabel.font = [UIFont systemFontOfSize:18];
    self.phoneNumLabel.textColor = JoinButtonEnableBackgroundColor;
    self.phoneNumLabel.text = @"请输入手机号验证登录";
    [self.validateView addSubview:self.phoneNumLabel];
    
    UITextField* countryTxtField = [[UITextField alloc] initWithFrame:(CGRect){30,0,MainscreenWidth - 60,44}];
    //countryTxtField.textColor = [UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:153.0f/255.0f alpha:1];
    countryTxtField.font = [UIFont systemFontOfSize:18];
    //countryTxtField.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    countryTxtField.textAlignment = NSTextAlignmentLeft;
    countryTxtField.borderStyle = UITextBorderStyleRoundedRect;
    countryTxtField.text = @"选择国家和地区";
    countryTxtField.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    UILabel* arrowLabel = [[UILabel alloc] initWithFrame:(CGRect){0,0,44,44}];
    arrowLabel.textAlignment = NSTextAlignmentCenter;
    arrowLabel.text = @"＞";
    arrowLabel.textColor = [UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:153.0f/255.0f alpha:1];
    countryTxtField.rightView = arrowLabel;
    countryTxtField.rightViewMode = UITextFieldViewModeAlways;
    countryTxtField.delegate = self;
    [self.validateView addSubview:countryTxtField];
    self.countryTxtField = countryTxtField;
    
    //手机号
    self.phoneNumTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, countryTxtField.frame.origin.y + countryTxtField.frame.size.height + 10, MainscreenWidth - 60, 44)];
    //        self.phoneNumTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 0, ScreenWidth - 60, 44)];
    self.phoneNumTextField.font = [UIFont systemFontOfSize:18];
    //self.phoneNumTextField.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    self.phoneNumTextField.textAlignment = NSTextAlignmentLeft;
    self.phoneNumTextField.keyboardType = UIKeyboardTypePhonePad;
    self.phoneNumTextField.returnKeyType = UIReturnKeySend;
    self.phoneNumTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.phoneNumTextField.placeholder = @"请输入手机号";
    self.phoneNumTextField.delegate = self.loginViewController.loginTextFieldDelegateImpl;
    self.phoneNumTextField.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.phoneNumTextField addTarget:self.loginViewController action:@selector(phoneNumLoginTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
#pragma clang diagnostic pop
    UILabel* label = [[UILabel alloc] initWithFrame:(CGRect){0,0,44,44}];
    label.text = @"+86";
    label.textAlignment = NSTextAlignmentCenter;
    self.phoneNumTextField.leftView = label;
    self.countryCodeLabel = label;
    self.phoneNumTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.validateView addSubview:self.phoneNumTextField];
    
    //手机验证码
    self.validateSMSTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, self.phoneNumTextField.frame.origin.y + self.phoneNumTextField.frame.size.height + 10, MainscreenWidth - 180, 44)];
    self.validateSMSTextField.font = [UIFont systemFontOfSize:18];
    self.validateSMSTextField.textColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    self.validateSMSTextField.textAlignment = NSTextAlignmentCenter;
    self.validateSMSTextField.keyboardType = UIKeyboardTypePhonePad;
    self.validateSMSTextField.returnKeyType = UIReturnKeyGo;
    self.validateSMSTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.validateSMSTextField.placeholder = @"手机验证码";
    self.validateSMSTextField.delegate = self.loginViewController.loginTextFieldDelegateImpl;
    self.validateSMSTextField.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [self.validateSMSTextField addTarget:self.loginViewController action:@selector(validateSMSTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.validateView addSubview:self.validateSMSTextField];
    
    //发送验证码
    self.sendSMSButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendSMSButton.frame = CGRectMake(self.validateSMSTextField.frame.origin.x + self.validateSMSTextField.frame.size.width + 10,
                                          self.validateSMSTextField.frame.origin.y,
                                          MainscreenWidth - 60 - self.validateSMSTextField.frame.size.width - 10, 44);
    [self.sendSMSButton setTintColor:[UIColor whiteColor]];
    self.sendSMSButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.sendSMSButton.enabled = NO;
    self.sendSMSButton.backgroundColor = JoinButtonUnableBackgroundColor;
    [self.sendSMSButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.sendSMSButton setTitle:@"获取验证码" forState:UIControlStateHighlighted];
    [self.sendSMSButton.layer setMasksToBounds:YES];
    [self.sendSMSButton.layer setCornerRadius:4.0];
    [self.sendSMSButton addTarget:self.loginViewController action:@selector(sendSMSButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.validateView addSubview:self.sendSMSButton];
    
    //验证登录
    self.validateLogonButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.validateLogonButton.frame = CGRectMake(30, self.validateSMSTextField.frame.origin.y + self.validateSMSTextField.frame.size.height + 20, MainscreenWidth - 60, 44);
    [self.validateLogonButton setTintColor:[UIColor whiteColor]];
    self.validateLogonButton.titleLabel.font = [UIFont systemFontOfSize:18];
    self.validateLogonButton.enabled = NO;
    self.validateLogonButton.backgroundColor = JoinButtonUnableBackgroundColor;
    [self.validateLogonButton setTitle:@"验证登录" forState:UIControlStateNormal];
    [self.validateLogonButton setTitle:@"验证登录" forState:UIControlStateHighlighted];
    [self.validateLogonButton.layer setMasksToBounds:YES];
    [self.validateLogonButton.layer setCornerRadius:4.0];
    [self.validateLogonButton addTarget:self.loginViewController action:@selector(validateLogonButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.validateView addSubview:self.validateLogonButton];
    
    //验证码错误, 请重新获取
    self.alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, self.validateLogonButton.frame.origin.y + self.validateLogonButton.frame.size.height + 10, MainscreenWidth - 60, 26)];
    self.alertLabel.textAlignment = NSTextAlignmentLeft;
    self.alertLabel.font = [UIFont systemFontOfSize:14];
    self.alertLabel.textColor = [UIColor redColor];
    [self.validateView addSubview:self.alertLabel];
}

- (void)showValidateView:(BOOL)isShow
{
    if (isShow) {
        CGFloat y = -120;
        if (self.loginViewController.view.frame.size.width == 320) {
            y += 10;
        }
        if (self.inputNumPasswordView.frame.origin.y == y) {
            y += 84;
            CGRect frame = self.inputNumPasswordView.frame;
            frame.origin.y = y;
            self.inputNumPasswordView.frame = frame;
        }
        [self.inputNumPasswordView addSubview:self.validateView];
    }
    else {
        [self.validateView removeFromSuperview];
    }
}

@end
