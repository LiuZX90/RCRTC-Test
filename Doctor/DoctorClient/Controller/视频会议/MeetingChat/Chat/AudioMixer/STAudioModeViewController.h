//
//  STAudioModelViewController.h
//  SealRTC
//
//  Created by birney on 2020/3/8.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STAudioMixerConfiguration.h"

NS_ASSUME_NONNULL_BEGIN
@protocol STAudioModeViewControllerDelegate <NSObject>

- (void)didSelectedModeOptions:(STAudioMixingOption)option atIndex:(NSInteger)index;

@end

@interface STAudioModeViewController : UITableViewController

@property (nonatomic, weak) id<STAudioModeViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger mixerModeIndex;

@end

NS_ASSUME_NONNULL_END
