//
//  ChatBubbleMenuViewDelegateImpl.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "ChatBubbleMenuViewDelegateImpl.h"
#import "ChatViewController.h"

@interface ChatBubbleMenuViewDelegateImpl ()

@property (nonatomic, weak) ChatViewController *chatViewController;

@end


@implementation ChatBubbleMenuViewDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.chatViewController = (ChatViewController *) vc;
    }
    return self;
}

#pragma mark - DWBubbleMenuViewDelegate
- (void)bubbleMenuButtonWillExpand:(DWBubbleMenuButton *)expandableView
{
    self.chatViewController.homeImageView.image = [UIImage imageNamed:@"chat_menu_close"];
    self.chatViewController.homeImageView.backgroundColor = redButtonBackgroundColor;
}

- (void)bubbleMenuButtonDidCollapse:(DWBubbleMenuButton *)expandableView
{
    self.chatViewController.homeImageView.image = [UIImage imageNamed:@"chat_menu"];
    self.chatViewController.homeImageView.backgroundColor = [UIColor whiteColor];
}

@end
