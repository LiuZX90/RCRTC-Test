//
//  ChatAvatarView.m
//  RongCloud
//
//  Created by Vicky on 2018/3/1.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "ChatAvatarView.h"
#import "UIColor+ColorChange.h"
#import "CommonUtility.h"

@implementation ChatAvatarModel

- (instancetype)initWithShowVoice:(BOOL)isShowVoice showIndicator:(BOOL)isShowIndicator userName:(NSString *)userName userID:(NSString *)userId;
{
    self = [super init];
    if (self) {
        _isShowVoice = isShowVoice;
        _isShowIndicator = isShowIndicator;
        _userID = userId;
        _userName = userName;
    }
    return self;
}

@end


@implementation ChatAvatarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self configUI];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    [self configUI];
}

- (UIImageView *)closeCameraImageView
{
    if (!_closeCameraImageView) {
        _closeCameraImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 76, 90)];
        _closeCameraImageView.contentMode = UIViewContentModeScaleToFill;
        _closeCameraImageView.image = [UIImage imageNamed:@"chat_audio_only"];
    }
    return _closeCameraImageView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.frame.size.width-90)/2,  (self.frame.size.height-90)/2, 90.0, 90.0)];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        _indicatorView.transform = transform;
    }
    return _indicatorView;
}

- (void)configUI
{
    if (CGRectEqualToRect(self.frame, CGRectMake(0, 0, 90, 120))) {
        self.closeCameraImageView.frame = CGRectMake(self.closeCameraImageView.frame.origin.x, self.closeCameraImageView.frame.origin.y, 76/2, 90/2);
    }
    else {
        self.closeCameraImageView.frame = CGRectMake(0, 0, 76, 90);
    }
    
    self.closeCameraImageView.center = self.center;
    [self addSubview:self.closeCameraImageView];
}

- (void)setModel:(ChatAvatarModel *)model
{
    _model = model;
    _closeCameraImageView.hidden = !model.isShowVoice;
    _indicatorView.hidden = !model.isShowIndicator;

    if (model.isShowIndicator)
        [_indicatorView startAnimating];
    else
        [_indicatorView stopAnimating];
}

- (void)hideCloseCameraImage
{
    [self.closeCameraImageView removeFromSuperview];
}

@end
