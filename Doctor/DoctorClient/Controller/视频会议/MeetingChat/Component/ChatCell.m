//
//  ChatCell.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "ChatCell.h"

@interface ChatCell ()
@property (strong, nonatomic) UIView *audioView;
@end

@implementation ChatCell

//@property (strong, nonatomic) UIView *videoView;
//@property (strong, nonatomic) UILabel *nameLabel;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.videoView = [[UIView alloc] init];
        [self.contentView addSubview:self.videoView];
        
        self.audioView = [[UIView alloc] init];
        [self.contentView addSubview:self.audioView];
        
        self.nameLabel = [[UILabel alloc] init];
        [self.audioView addSubview:self.nameLabel];
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.contentView.layer.borderWidth = 1.0f;
        self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return self;
}


- (void)setType:(ChatType)type
{
    _type = type;
    
    if (type == ChatTypeAudio) {
        self.videoView.hidden = YES;
        self.audioView.hidden = NO;
    } else if (type == ChatTypeVideo) {
        self.videoView.hidden = NO;
        self.audioView.hidden = YES;
    } else {
        DLog(@"error: control type not correct");
    }
}
- (void)refreshAutoTestLabel:(BOOL)hideSubscribeLabel connectLabel:(BOOL)hideConnect subscribeLog:(NSString *)log connectLog:(NSString *)log1{
    if (!self.subscribeLabel ) {
        self.subscribeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        [self.subscribeLabel setFont:[UIFont systemFontOfSize:9]];
        [self.subscribeLabel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15]];
        [self.subscribeLabel setTextColor:[UIColor greenColor]];
        [self addSubview:self.subscribeLabel];
    }
    if (!self.connectLabel ) {
        self.connectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, 10)];
        [self.connectLabel setFont:[UIFont systemFontOfSize:9]];
        [self.connectLabel setBackgroundColor:[UIColor colorWithRed:255 green:0 blue:0 alpha:0.15]];
        [self addSubview:self.connectLabel];
        
    }
//    if (hideSubscribeLabel) {
//        self.subscribeLabel.hidden = YES;
//        self.subscribeLabel.text = @"";
//    } else {
//        self.subscribeLabel.hidden = NO;
        self.subscribeLabel.text = log;
    [self.subscribeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.subscribeLabel setFont:[UIFont systemFontOfSize:7]];
        
//    }
    self.connectLabel.text = @"";
    self.connectLabel.text = @"";
    if (hideConnect) {
        self.connectLabel.hidden = YES;
        self.connectLabel.text = log1;
    } else {
        self.connectLabel.hidden = NO;
        self.connectLabel.text = log1;
    }
}
@end
