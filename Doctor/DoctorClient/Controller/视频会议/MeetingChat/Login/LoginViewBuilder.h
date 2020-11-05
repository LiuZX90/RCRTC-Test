//
//  LoginViewBuilder.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RadioButton.h"

#define JoinButtonEnableBackgroundColor [UIColor colorWithRed:53.0/255.0 green:129.0/255.0 blue:242.0/255.0 alpha:1.0]
#define JoinButtonUnableBackgroundColor [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0]

@interface LoginViewBuilder : NSObject

@property (nonatomic, strong) UIImageView *loginIconImageView;
@property (nonatomic, strong) UIView *inputNumPasswordView, *validateView;
@property (nonatomic, strong) UILabel *welcomeLabel, *titleLabel, *contentLabel, *versionLabel, *copyrightLabel, *userNameTitleLabel , *watchTitle;
@property (nonatomic, strong) UILabel *phoneNumLabel, *alertLabel;
@property (nonatomic, strong) UITextField *roomNumberTextField, *phoneNumTextField, *validateSMSTextField, *phoneNumLoginTextField, *usernameTextField;
@property (nonatomic, strong) UIButton *joinRoomButton, *sendSMSButton, *validateLogonButton , *watchLiveButton,*audioLiveBtn;
@property (nonatomic, strong) UIButton *loginSettingButton;
@property (nonatomic, strong) NSMutableArray *radioButtons;
@property (nonatomic, strong) CALayer *lineLayer;
@property (nonatomic, strong) UILabel* countryCodeLabel;
@property (nonatomic, strong) UILabel* loginCountryCodeLabel;
@property (nonatomic, strong) UITextField* countryTxtField;
@property (nonatomic, strong) UITextField*  loginCountryTxtField;


- (instancetype)initWithViewController:(UIViewController *)vc;
- (void)showValidateView:(BOOL)isShow;

@end
