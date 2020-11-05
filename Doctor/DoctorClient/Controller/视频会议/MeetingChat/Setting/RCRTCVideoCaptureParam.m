//
//  RCRTCVideoCaptureParam.m
//  RongRTCLib
//
//  Created by zhaobingdong on 2019/1/10.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RCRTCVideoCaptureParam.h"

#import <AVFoundation/AVFoundation.h>

#import "RCRTCVideoCaptureParam+Private.h"

@interface RCRTCVideoCaptureParam ()  <NSCopying>

@property (nonatomic, assign) NSInteger audioBitrate;
@property (nonatomic, assign) BOOL isUserDefinedMaxBitrate, isUserDefinedMinBitrate;

@end


@implementation RCRTCVideoCaptureParam

- (instancetype)init {
    if (self = [super init]) {
        self.videoSizePreset = RCRTCVideoSizePreset640x480;
        self.cameraPosition = RCRTCCaptureDeviceFront;
        self.videoFrameRate = RCRTCVideoFPS15;
        self.videoOrientation = AVCaptureVideoOrientationPortrait;
        self.turnOnCamera = YES;
        self.tinyStreamEnable = YES;
        self.isUserDefinedMaxBitrate = NO;
        self.isUserDefinedMinBitrate = NO;
        _maxBitrate = [self maxBitateValue];
        _minBitrate = [self minBitateValue];
        self.codecType = RCRTCCodecH264;
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    RCRTCVideoCaptureParam *copy = [[RCRTCVideoCaptureParam alloc] init];
    copy.videoSizePreset = self.videoSizePreset;
    copy.cameraPosition = self.cameraPosition;
    copy.videoFrameRate = self.videoFrameRate;
    copy.videoOrientation = self.videoOrientation;
    copy.turnOnCamera = self.turnOnCamera;
    copy.tinyStreamEnable = self.tinyStreamEnable;
    copy.isUserDefinedMaxBitrate = self.isUserDefinedMaxBitrate;
    copy.isUserDefinedMinBitrate = self.isUserDefinedMinBitrate;
    copy->_maxBitrate = self.maxBitrate;
    copy->_minBitrate = self.minBitrate;
    copy.codecType = self.codecType;
    copy.videoMirrored = self.videoMirrored;

    return copy;
}

- (NSString *)codecTypeValue {
    return @"H264";
}

- (void)setMaxBitrate:(NSUInteger)maxBitrate {
    if (maxBitrate) {
        _maxBitrate = maxBitrate;
        self.isUserDefinedMaxBitrate = YES;
    }
}

- (void)setMinBitrate:(NSUInteger)minBitrate {
    if (minBitrate) {
        _minBitrate = minBitrate;
        self.isUserDefinedMinBitrate = YES;
    }
}

- (NSInteger)maxBitateValue {
    if (self.isUserDefinedMaxBitrate) {
        return _maxBitrate;
    }
    return [self maxBitateValue:self.videoSizePreset frameRate:self.videoFrameRate];
}

- (NSInteger)minBitateValue {
    if (self.isUserDefinedMinBitrate) {
        return _minBitrate;
    }
    return [self minBitateValue:self.videoSizePreset frameRate:self.videoFrameRate];
}

+ (AVCaptureVideoOrientation)valueForOrientation:(RCRTCVideoOrientation)orientation {
    AVCaptureVideoOrientation result = AVCaptureVideoOrientationPortrait;
    switch (orientation) {
        case RCRTCVideoOrientationPortrait:
            result = AVCaptureVideoOrientationPortrait;
            break;
        case RCRTCVideoOrientationPortraitUpsideDown:
            result = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case RCRTCVideoOrientationLandscapeRight:
            result = AVCaptureVideoOrientationPortrait;
            break;
        case RCRTCVideoOrientationLandscapeLeft:
            result = AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            break;
    }
    return result;
}

- (NSInteger)fpsValue {
    return (int32_t)[self fpsValue:self.videoFrameRate];
}

- (CGSize)resolution {
    return [self resolution:self.videoSizePreset];
}

- (NSInteger)maxBitateValue:(RCRTCVideoSizePreset)videoSizePreset frameRate:(RCRTCVideoFPS)fps {
    CGFloat factor = 1.0;
    switch (fps) {
        case RCRTCVideoFPS10:
            factor = 1.0;
            break;
        case RCRTCVideoFPS15:
            factor = 1.0;
            break;
        case RCRTCVideoFPS24:
            factor = 1.5;
            break;
        case RCRTCVideoFPS30:
            factor = 1.5;
            break;
        default:
            break;
    }
    
    NSInteger maxBandWidth = 1000;
    switch (videoSizePreset) {
        case RCRTCVideoSizePreset176x144:
            maxBandWidth = 150;
            break;
        case RCRTCVideoSizePreset256x144:
            maxBandWidth = 240;
            break;
        case RCRTCVideoSizePreset320x180:
            maxBandWidth = 280;
            break;
        case RCRTCVideoSizePreset240x240:
            maxBandWidth = 280;
            break;
        case RCRTCVideoSizePreset320x240:
            maxBandWidth = 400;
            break;
        case RCRTCVideoSizePreset480x360:
            maxBandWidth = 650;
            break;
        case RCRTCVideoSizePreset640x360:
            maxBandWidth = 800;
            break;
        case RCRTCVideoSizePreset480x480:
            maxBandWidth = 800;
            break;
        case RCRTCVideoSizePreset640x480:
            maxBandWidth = 900;
            break;
        case RCRTCVideoSizePreset720x480:
            maxBandWidth = 1000;
            break;
        case RCRTCVideoSizePreset1280x720:
            maxBandWidth = 2200;
            break;
//        case RCRTCVideoSizePreset1920x1080:
//            maxBandWidth = 4000;
//            break;
        default:
            break;
    }
    return maxBandWidth * factor;
}

- (NSInteger)minBitateValue:(RCRTCVideoSizePreset)videoSizePreset frameRate:(RCRTCVideoFPS)fps {
    CGFloat factor = 1.0;
    switch (fps) {
        case RCRTCVideoFPS10:
            factor = 1.0;
            break;
        case RCRTCVideoFPS15:
            factor = 1.0;
            break;
        case RCRTCVideoFPS24:
            factor = 1.5;
            break;
        case RCRTCVideoFPS30:
            factor = 1.5;
            break;
        default:
            break;
    }
    
    NSInteger minBandWidth = 350;
    switch (videoSizePreset) {
        case RCRTCVideoSizePreset176x144:
            minBandWidth = 80;
            break;
        case RCRTCVideoSizePreset256x144:
            minBandWidth = 120;
            break;
        case RCRTCVideoSizePreset320x180:
            minBandWidth = 120;
            break;
        case RCRTCVideoSizePreset240x240:
            minBandWidth = 120;
            break;
        case RCRTCVideoSizePreset320x240:
            minBandWidth = 120;
            break;
        case RCRTCVideoSizePreset480x360:
            minBandWidth = 150;
            break;
        case RCRTCVideoSizePreset640x360:
            minBandWidth = 180;
            break;
        case RCRTCVideoSizePreset480x480:
            minBandWidth = 180;
            break;
        case RCRTCVideoSizePreset640x480:
            minBandWidth = 200;
            break;
        case RCRTCVideoSizePreset720x480:
            minBandWidth = 200;
            break;
        case RCRTCVideoSizePreset1280x720:
            minBandWidth = 250;
            break;
//        case RCRTCVideoSizePreset1920x1080:
//            minBandWidth = 250;
//            break;
        default:
            break;
    }
    
    return minBandWidth * factor;
}

- (NSInteger)fpsValue:(RCRTCVideoFPS)fps {
    NSInteger result = 15;
    switch (fps) {
        case RCRTCVideoFPS10:
            result = 10;
            break;
        case RCRTCVideoFPS15:
            result = 15;
            break;
        case RCRTCVideoFPS24:
            result = 24;
            break;
        case RCRTCVideoFPS30:
            result = 30;
            break;
        default:
            break;
    }
    return result;
}

- (CGSize)resolution:(RCRTCVideoSizePreset)videoSizePreset {
 
    CGSize size = (CGSize){640,480};
    switch (videoSizePreset) {
        case RCRTCVideoSizePreset176x144:
            size = (CGSize){176, 144};
            break;
        case RCRTCVideoSizePreset256x144:
            size = (CGSize){256,144};
            break;
        case RCRTCVideoSizePreset320x180:
            size = (CGSize){320,180};
            break;
        case RCRTCVideoSizePreset240x240:
            size = (CGSize){240,240};
            break;
        case RCRTCVideoSizePreset320x240:
            size = (CGSize){320,240};
            break;
        case RCRTCVideoSizePreset480x360:
            size = (CGSize){480,360};
            break;
        case RCRTCVideoSizePreset640x360:
            size = (CGSize){640,360};
            break;
        case RCRTCVideoSizePreset480x480:
            size = (CGSize){480,480};
            break;
        case RCRTCVideoSizePreset640x480:
            size = (CGSize){640,480};
            break;
        case RCRTCVideoSizePreset720x480:
            size = (CGSize){720,480};
            break;
        case RCRTCVideoSizePreset1280x720:
            size = (CGSize){1280,720};
            break;
//        case RCRTCVideoSizePreset1920x1080:
//            size = @"1920x1080";
//            break;
        default:
            break;
    }
    return size;
}

@end
