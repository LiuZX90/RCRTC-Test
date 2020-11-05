//
//  RCRTCVideoCaptureParam.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/1/10.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <RongRTCLib/RongRTCLib.h>


NS_ASSUME_NONNULL_BEGIN

/*!
 视频采集器参数
 */
@interface RCRTCVideoCaptureParam : NSObject

/*!
 摄像头输出的视频分辨率, 默认: RCRTCVideoSizePreset640x480
 */
@property (nonatomic,assign) RCRTCVideoSizePreset videoSizePreset;

/*!
 初始化使用前/后摄像头, 默认: 前置摄像头
 */
@property (nonatomic, assign) RCRTCDeviceCamera cameraPosition;

/*!
 初始化时是否打开指定的摄像头, 默认: 打开
 */
@property (nonatomic, assign) BOOL turnOnCamera;

/**
 摄像头是否做镜像翻转
 */
@property(nonatomic , assign)BOOL videoMirrored;

/*!
 视频发送帧率. 默认: 15 FPS
 */
@property (nonatomic, assign) RCRTCVideoFPS videoFrameRate;

/*!
 是否启用视频小流，默认: 开启
 */
@property (nonatomic,assign) BOOL tinyStreamEnable;

/*!
 最大码率, 默认 640x480 分辨率时, 默认: 1000 kbps
 */
@property (nonatomic, assign) NSUInteger maxBitrate;

/*!
 最小码率, 默认 640x480 分辨率时, 默认: 350 kbps
 */
@property (nonatomic, assign) NSUInteger minBitrate;

/*!
 摄像头采集方向，默认: AVCaptureVideoOrientationPortrait 角度进行采集
 */
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

/*!
 视频编解码器，默认: H264
 */
@property (nonatomic, assign) RCRTCCodecType codecType;

@end

NS_ASSUME_NONNULL_END
