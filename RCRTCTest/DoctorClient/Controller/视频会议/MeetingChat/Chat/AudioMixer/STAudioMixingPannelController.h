//
//  STAudioMixingPannelController.h
//  SealRTC
//
//  Created by birney on 2020/3/8.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class STAudioMixerConfiguration;

@interface STAudioMixingPannelController : UITableViewController

@property (nonatomic, strong) STAudioMixerConfiguration* config;

@end

NS_ASSUME_NONNULL_END
