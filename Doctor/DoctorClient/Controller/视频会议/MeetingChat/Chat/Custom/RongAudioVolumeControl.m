//
//  RongAudioVolumeControl.m
//  SealRTC
//
//  Created by jfdreamyang on 2019/10/16.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RongAudioVolumeControl.h"


@interface  RongAudioVolumeControl()
@property (nonatomic,strong)UILabel *volumeLab;
@end


@implementation RongAudioVolumeControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel *audioControlLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, frame.size.width, 30)];
        audioControlLab.text = @"音量设置";
        audioControlLab.textColor = [UIColor blackColor];
        audioControlLab.textAlignment = NSTextAlignmentCenter;
        audioControlLab.font = [UIFont systemFontOfSize:17];
        [self addSubview:audioControlLab];
        
        UIButton *enlarge = [UIButton buttonWithType:UIButtonTypeCustom];
        enlarge.frame = CGRectMake(frame.size.width - 10 - 156/3, frame.size.height - 10 - 88/3, 156/3, 88/3);
        [enlarge addTarget:self action:@selector(enlargeButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [enlarge setImage:[UIImage imageNamed:@"chat_av_volume_plus"] forState:UIControlStateNormal];
        [self addSubview:enlarge];
        
        _volumeLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
        _volumeLab.text = @"5";
        _volumeLab.textAlignment = NSTextAlignmentCenter;
        _volumeLab.center = CGPointMake(frame.size.width/2, frame.size.height/2 + 20);
        _volumeLab.textColor = [UIColor blackColor];
        _volumeLab.font = [UIFont boldSystemFontOfSize:23];
        [self addSubview:_volumeLab];
        
        UIButton *ensmall = [UIButton buttonWithType:UIButtonTypeCustom];
        ensmall.frame = CGRectMake(10, frame.size.height - 10 - 88/3, 156/3, 88/3);
        [ensmall addTarget:self action:@selector(ensmallButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [ensmall setImage:[UIImage imageNamed:@"chat_av_volume_minus"] forState:UIControlStateNormal];
        [self addSubview:ensmall];
        
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

-(void)enlargeButtonClick{
    NSInteger value = [_volumeLab.text integerValue];
    if (value == 10) {
        return;
    }
    value = value + 1;
    _volumeLab.text = [NSString stringWithFormat:@"%@",@(value)];
    [self.delegate volumeValueChanged:value];
}

-(void)ensmallButtonClick{
    NSInteger value = [_volumeLab.text integerValue];
    if (value == 0) {
        return;
    }
    value = value - 1;
    _volumeLab.text = [NSString stringWithFormat:@"%@",@(value)];
    [self.delegate volumeValueChanged:value];
}

-(void)dealloc{
    
}

@end
