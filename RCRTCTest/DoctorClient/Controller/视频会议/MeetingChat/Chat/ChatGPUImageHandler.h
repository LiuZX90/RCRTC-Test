//
//  ChatGPUImageHandle.h
//  SealRTC
//
//  Created by LiuLinhong on 2019/02/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatGPUImageHandler : NSObject

- (CMSampleBufferRef)onGPUFilterSource:(CMSampleBufferRef)sampleBuffer;
- (void)rotateWaterMark:(BOOL)isBack;
- (void)transformWaterMark:(BOOL)isTrans;

@end

NS_ASSUME_NONNULL_END
