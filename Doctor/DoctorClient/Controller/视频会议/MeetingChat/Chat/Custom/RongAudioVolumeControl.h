//
//  RongAudioVolumeControl.h
//  SealRTC
//
//  Created by jfdreamyang on 2019/10/16.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RongAudioVolumeControlDelegate <NSObject>

-(void)volumeValueChanged:(NSInteger)value;

@end

@interface RongAudioVolumeControl : UIView
@property (nonatomic,strong)id <RongAudioVolumeControlDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
