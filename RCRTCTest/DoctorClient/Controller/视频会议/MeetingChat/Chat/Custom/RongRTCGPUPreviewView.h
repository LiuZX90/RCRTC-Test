//
//  RongRTCVideoPreviewView.h
//  RongRTCVideoPreviewView
//
//  Created by jfdreamyang on 2019/1/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

@interface RongRTCGPUPreviewView : UIView

/**
 设置视频镜像显示
 */
@property (nonatomic)BOOL mirror;

/**
 设置旋转方向
 */
@property float preferredRotation;

/**
 设置显示区域大小
 */
@property CGSize presentationRect;

/**
 设置色度 默认值是 1
 */
@property (nonatomic)float chroma;

/**
 设置亮度，默认值是 1
 */
@property (nonatomic)float luminance;

/**
 是否 RGB 像素格式
 */
@property (nonatomic)BOOL isRGB;

/**
 渲染视频帧

 @param pixelBuffer 视频帧数据
 */
- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
