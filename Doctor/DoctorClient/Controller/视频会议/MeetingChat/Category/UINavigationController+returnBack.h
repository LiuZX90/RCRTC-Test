//
//  UINavigationController+returnBack.h
//  RongCloud
//
//  Created by Rongcloud on 2018/1/30.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol BackButtonHandlerProtocol <NSObject>

@optional
- (BOOL)navigationShouldPopOnBackButton;

@end


@interface UIViewController (BackButtonHandler) <BackButtonHandlerProtocol>

@end


@interface UINavigationController (returnBack)<BackButtonHandlerProtocol>

@end
