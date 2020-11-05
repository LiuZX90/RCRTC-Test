//
//  STParticipantsTableViewHeader.m
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "STParticipantsTableViewHeader.h"

@interface STParticipantsTableViewHeader()

@property (nonatomic, strong) UIButton* closeBtn;
@property (nonatomic, strong) UILabel* tipsLabel;
@end


@implementation STParticipantsTableViewHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:self.tipsLabel];
    [self addSubview:self.closeBtn];
    self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight) {
        self.tipsLabel.frame = (CGRect){16 + 44,0,200,44};
    } else {
        self.tipsLabel.frame = (CGRect){16,0,200,44};
    }
    CGSize size = self.bounds.size;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        self.closeBtn.frame = (CGRect){size.width-44-8 - 44,0,44,44};
    } else {
        self.closeBtn.frame = (CGRect){size.width-44-8,0,44,44};
    }
}

#pragma mark  - Getters
- (UIButton*)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] initWithFrame:(CGRect){8,0,44,44}];
        [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        _closeBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    return _closeBtn;
}

- (UILabel*)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:(CGRect){8,0,250,44}];
        _tipsLabel.text = @"在线人数 0 人";
        _tipsLabel.font = [UIFont systemFontOfSize:16.0f];
        _tipsLabel.textColor = [UIColor whiteColor];
    }
    return _tipsLabel;
}

@end
