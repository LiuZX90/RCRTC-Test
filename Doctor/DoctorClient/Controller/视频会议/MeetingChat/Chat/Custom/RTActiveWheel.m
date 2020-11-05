//
//  RCEActiveWheel.m
//  RongEnterpriseApp
//
//  Created by zhaobindong on 2017/6/8.
//  Copyright © 2017年 rongcloud. All rights reserved.
//

#import "RTActiveWheel.h"

@interface RTActiveWheel ()
@property(nonatomic) BOOL *ptimeoutFlag;
@end

@implementation RTActiveWheel

- (id)initWithView:(UIView *)view {
    self = [super initWithView:view];
    if (self) {
        self.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.tintColor = [UIColor blackColor];
    }
    return self;
}


- (void)dealloc {
    //self.processString = nil;
}

+ (RTActiveWheel *)showHUDAddedTo:(UIView *)view {
    RTActiveWheel *hud = [[RTActiveWheel alloc] initWithView:view];
    hud.contentColor = [UIColor whiteColor];
    [view addSubview:hud];
    [hud showAnimated:YES];
    return hud;
}

+ (void)showPromptHUDAddedTo:(UIView *)view text:(NSString *)text {
    RTActiveWheel *hud = [RTActiveWheel showHUDAddedTo:view];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabel.text = text;
    hud.detailsLabel.textColor = [UIColor whiteColor];

    [hud hideAnimated:YES afterDelay:2.0f];
}

+ (void)dismissForView:(UIView *)view {
    MBProgressHUD *hud = [super HUDForView:view];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES];
}

+ (void)dismissViewDelay:(NSTimeInterval)interval forView:(UIView *)view warningText:(NSString *)text;
{
    RTActiveWheel *wheel = (RTActiveWheel *)[super HUDForView:view];
    ;
    [wheel performSelector:@selector(setWarningString:) withObject:text afterDelay:0];
    [RTActiveWheel performSelector:@selector(dismissForView:) withObject:view afterDelay:interval];
}

+ (void)dismissViewDelay:(NSTimeInterval)interval forView:(UIView *)view processText:(NSString *)text {
    RTActiveWheel *wheel = (RTActiveWheel *)[super HUDForView:view];
    ;
    wheel.processString = text;
    [RTActiveWheel performSelector:@selector(dismissForView:) withObject:view afterDelay:interval];
}

+ (void)dismissForView:(UIView *)view delay:(NSTimeInterval)interval {
    [RTActiveWheel performSelector:@selector(dismissForView:) withObject:view afterDelay:interval];
}

- (void)setProcessString:(NSString *)processString {
    // self.labelColor = [UIColor colorWithRed:219/255.0f green:78/255.0f blue:32/255.0f alpha:1];
    self.label.text = processString;
}

- (void)setWarningString:(NSString *)warningString {
    self.label.textColor = [UIColor redColor];
    self.label.text = warningString;
}


+ (void)hidePromptHUDDelay:(UIView *)view text:(NSString *)text {
    RTActiveWheel *wheel = (RTActiveWheel *)[super HUDForView:view];
    //  hud.square = YES;
    wheel.mode = MBProgressHUDModeText;
    wheel.label.text = nil;
    wheel.detailsLabel.text = text;
    wheel.detailsLabel.textColor = [UIColor whiteColor];
    [wheel hideAnimated:YES afterDelay:2.0f];
}

@end
