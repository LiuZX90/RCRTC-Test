//
//  LoginTextFieldDelegateImpl.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "LoginTextFieldDelegateImpl.h"
#import "RTCLoginViewController.h"
#import "NSString+length.h"


@interface LoginTextFieldDelegateImpl ()

@property (nonatomic, weak) RTCLoginViewController *loginViewController;

@end


@implementation LoginTextFieldDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.loginViewController = (RTCLoginViewController *) vc;
    }
    return self;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGSize size = [UIScreen mainScreen].bounds.size;
        CGFloat y = 0;
        if (size.height <= 568) {
            y = -120;
            if (weakSelf.loginViewController.view.frame.size.width == 320) {
                y += 10;
            }
        }
        if (weakSelf.loginViewController.loginViewBuilder.validateView.superview) {
            y += 84;
        } else {
            y -= 44;
        }
        weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame = CGRectMake(weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.origin.x, y, weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.size.width, weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat originY = 130;
        if (weakSelf.loginViewController.view.frame.size.width == 320) {
            originY = originY - 44;
        }
        weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame = CGRectMake(0, originY, weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.size.width, weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}
 
- (BOOL)textFieldShouldReturn:(UITextField *)textfield
{
    if (self.loginViewController.isRoomNumberInput && kLoginManager.isLoginTokenSucc)
        [self.loginViewController joinRoomButtonPressed:self.loginViewController.loginViewBuilder.joinRoomButton];
    [textfield resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *tobeString = [textField.text stringByAppendingString:string];
    
    if (textField == self.loginViewController.loginViewBuilder.roomNumberTextField) {
        return [self validateRoomID:tobeString withRegex:RegexRoomID];
    }
    else if (textField == self.loginViewController.loginViewBuilder.phoneNumTextField
             || textField == self.loginViewController.loginViewBuilder.phoneNumLoginTextField) {
        return ([tobeString getStringLengthOfBytes] < 12);
    }
    else if (textField == self.loginViewController.loginViewBuilder.validateSMSTextField) {
        return ([tobeString getStringLengthOfBytes] < 7);
    }
    else if (textField == self.loginViewController.loginViewBuilder.usernameTextField){
        return tobeString.length < 32;
    }

    return NO;
}

#pragma mark - validate for username
- (BOOL)validateRoomID:(NSString *)userName withRegex:(NSString *)regex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:userName];
}

@end
