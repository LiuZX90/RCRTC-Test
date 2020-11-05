//
//  SettingTextFieldDelegateImpl.m
//  SealRTC
//
//  Created by LiuLinhong on 2020/02/10.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "SettingTextFieldDelegateImpl.h"
#import "SettingViewController.h"

@interface SettingTextFieldDelegateImpl ()

@property (nonatomic, weak) SettingViewController *settingViewController;

@end


@implementation SettingTextFieldDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc {
    self = [super init];
    if (self) {
        self.settingViewController = (SettingViewController *) vc;
    }
    return self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO;
}


@end
