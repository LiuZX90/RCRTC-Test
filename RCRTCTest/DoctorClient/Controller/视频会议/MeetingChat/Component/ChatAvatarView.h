//
//  ChatAvatarView.h
//  RongCloud
//
//  Created by Vicky on 2018/3/1.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatAvatarModel: NSObject

@property (nonatomic, assign) BOOL isShowVoice, isShowIndicator;
@property (nonatomic, strong) NSString *userID, *userName;

- (instancetype)initWithShowVoice:(BOOL)isShowVoice showIndicator:(BOOL)isShowIndicator userName:(NSString *)userName userID:(NSString *)userId;

@end

@interface ChatAvatarView : UIView

@property (nonatomic, strong) ChatAvatarModel *model;

@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong) UIImageView *closeCameraImageView;

- (void)hideCloseCameraImage;

@end
