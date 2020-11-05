//
//  RCRTCVideoCaptureParam+Private.h
//  RongRTCLib
//
//  Created by birney on 2019/1/24.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCRTCVideoCaptureParam (Private)

@property (nonatomic, assign, readonly) NSInteger fpsValue;
@property (nonatomic, assign, readonly) CGSize resolution;
@property (nonatomic, assign) BOOL isUserDefinedMaxBitrate, isUserDefinedMinBitrate;

- (NSString *)codecTypeValue;
- (NSInteger)maxBitateValue;
- (NSInteger)minBitateValue;

@end

NS_ASSUME_NONNULL_END
