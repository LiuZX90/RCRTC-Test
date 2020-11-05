//
//  STAudioMixerConfiguration.h
//  SealRTC
//
//  Created by birney on 2020/3/12.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, STAudioMixingOption) {
    STAudioMixingOptionPlaying     = 0B001,
    STAudioMixingOptionMixing      = 0B010,
    STAudioMixingOptionReplaceMic  = 0B100,
};

@interface STAudioMixerConfiguration : NSObject

@property (nonatomic, strong) NSURL* audioFileURL;
@property (nonatomic, assign) NSInteger localVolume;
@property (nonatomic, assign) NSInteger micVolume;
@property (nonatomic, assign) NSInteger remoteVolume;
@property (nonatomic, assign) NSInteger mixerModeIndex;
@property (nonatomic, assign)   STAudioMixingOption mixingOption;
@end

NS_ASSUME_NONNULL_END
