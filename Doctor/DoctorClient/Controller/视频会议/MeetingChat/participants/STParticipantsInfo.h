//
//  STParticipantsInfo.h
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STJSONModel.h"

typedef NS_ENUM(NSInteger,STJoinMode) {
    STJoinModeAV = 0, /// 以⾳音视频⽅方式加⼊入
    STJoinModeAudioOnly = 1, /// 仅以⾳音频加⼊入
    STJoinModeObserver = 2 /// 以观察者加⼊入
};

NS_ASSUME_NONNULL_BEGIN

@interface STParticipantsInfo : STJSONModel

@property (nonatomic, copy, readonly) NSString* userId;
@property (nonatomic, copy, readonly) NSString* userName;
@property (nonatomic, assign, readonly) long long joinTime;
@property (nonatomic, assign, readonly) STJoinMode joinMode;
@property (nonatomic, assign) NSInteger master;

@end

NS_ASSUME_NONNULL_END
