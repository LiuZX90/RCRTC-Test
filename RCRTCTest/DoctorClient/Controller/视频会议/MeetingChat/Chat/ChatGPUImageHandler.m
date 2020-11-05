//
//  ChatGPUImageHandle.m
//  SealRTC
//
//  Created by LiuLinhong on 2019/02/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ChatGPUImageHandler.h"
#import <GPUImage/GPUImage.h>
#import "GPUImageBeautyFilter.h"
#import "GPUImageOutputCamera.h"
#import "LoginManager.h"
#import "ChatManager.h"
#import "RCRTCVideoCaptureParam.h"

@interface ChatGPUImageHandler ()

@property (nonatomic, strong) GPUImageUIElement *uiElement;
@property (nonatomic, strong) GPUImageBeautyFilter *beautyFilter;
@property (nonatomic, strong) GPUImageOutputCamera *outputCamera;
@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageAlphaBlendFilter *blendFilter;
@property (nonatomic, strong) GPUImageFilter *filter, *defaultFilter;
@property (nonatomic, weak) GPUImageFilter *gupfilter;
@property (nonatomic, strong) UIImageView *watermarkImageView;
@property (nonatomic, assign) CGFloat videoWidth, videoHeight;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) BOOL isTransform, isBackCamera;

@end


@implementation ChatGPUImageHandler

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.isTransform = NO;
        self.isBackCamera = NO;
        [self initGPUFilter];
    }
    return self;
}

- (void)initGPUFilter
{
//    self.gupfilter = kLoginManager.isGPUFilter ? self.beautyFilter : self.defaultFilter;
    self.gupfilter = self.defaultFilter;
    [self.outputCamera addTarget:self.gupfilter];
    
    if (kLoginManager.isWaterMark) {
        [self reloadGPUFilter];
        [self.gupfilter addTarget:self.blendFilter];
        [self.uiElement addTarget:self.blendFilter];
        [self.blendFilter addTarget:self.imageView];
        self.filter = self.blendFilter;
    }
    else {
        [self.gupfilter addTarget:self.imageView];
        self.filter = self.gupfilter;
    }
}

- (void)rotateWaterMark:(BOOL)isBack
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isBackCamera = isBack;
        if (isBack) {
            if (self.isTransform) {
                self.watermarkImageView.frame = CGRectMake(self.videoHeight - 100, self.videoWidth - 100, 80, 80);
            }
            else {
                self.watermarkImageView.frame = CGRectMake(self.videoWidth - 100, self.videoHeight - 100, 80, 80);
            }
            
            self.watermarkImageView.transform = CGAffineTransformRotate(self->_watermarkImageView.transform, M_PI);
        }
        else {
            self.watermarkImageView.frame = CGRectMake(20, 20, 80, 80);
            self.watermarkImageView.transform = CGAffineTransformRotate(self->_watermarkImageView.transform, -M_PI);
        }
        self.watermarkImageView.hidden = ([RCRTCEngine sharedInstance].defaultVideoStream.cameraPosition == AVCaptureDevicePositionFront) ? YES : NO;
    });
}

- (void)transformWaterMark:(BOOL)isTrans
{
    self.isTransform = isTrans;
    [_gupfilter setFrameProcessingCompletionBlock:nil];
    [self.uiElement removeTarget:self.blendFilter];
    self.uiElement = nil;
    if (isTrans) {
        //横屏
        if (self.isBackCamera) {
            self.watermarkImageView.frame = CGRectMake(self.videoHeight - 100, self.videoWidth - 100, 80, 80);
        }
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.videoHeight, self.videoWidth);
    }
    else {
        //竖屏
        if (self.isBackCamera) {
            self.watermarkImageView.frame = CGRectMake(self.videoWidth - 100, self.videoHeight - 100, 80, 80);
        }
        
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.videoWidth, self.videoHeight);
    }
    
    [self reloadGPUFilter];
    [self.uiElement addTarget:self.blendFilter];
}

- (void)reloadGPUFilter
{
    self.watermarkImageView.hidden = ([RCRTCEngine sharedInstance].defaultVideoStream.cameraPosition == AVCaptureDevicePositionFront) ? YES : NO;
    [self uiElement];
    __weak typeof(self) weakSelf = self;
    [self.gupfilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        if (weakSelf.uiElement) {
            [weakSelf.uiElement updateWithTimestamp:time];
        }
    }];
}

- (CMSampleBufferRef)onGPUFilterSource:(CMSampleBufferRef)sampleBuffer
{
    if (!self.filter || !sampleBuffer)
        return nil;
    
    if (!CMSampleBufferIsValid(sampleBuffer))
        return nil;
    
    [self.filter useNextFrameForImageCapture];
    //CFRetain(sampleBuffer);
    [self.outputCamera processVideoSampleBuffer:sampleBuffer];
    CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    //CFRelease(sampleBuffer);
    
    GPUImageFramebuffer *framebuff = [self.filter framebufferForOutput];
    CVPixelBufferRef pixelBuff = [framebuff pixelBuffer];
    CVPixelBufferLockBaseAddress(pixelBuff, 0);
    
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuff, &videoInfo);
    
    CMSampleTimingInfo timing = {currentTime, currentTime, kCMTimeInvalid};
    if (videoInfo == NULL)
        return nil;
    
    CMSampleBufferRef processedSampleBuffer = NULL;
    CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuff, YES, NULL, NULL, videoInfo, &timing, &processedSampleBuffer);
    
    CFRelease(videoInfo);
    CVPixelBufferUnlockBaseAddress(pixelBuff, 0);
    return processedSampleBuffer;
}

#pragma mark - Getter
- (GPUImageFilter *)defaultFilter
{
    if (!_defaultFilter)  {
        _defaultFilter = [[GPUImageFilter alloc] init];
    }
    return _defaultFilter;
}

- (GPUImageBeautyFilter *)beautyFilter
{
    if (!_beautyFilter) {
        _beautyFilter = [[GPUImageBeautyFilter alloc] init];
    }
    return _beautyFilter;
}

- (GPUImageOutputCamera *)outputCamera
{
    if (!_outputCamera) {
        _outputCamera = [[GPUImageOutputCamera alloc] init];
    }
    return _outputCamera;
}

- (GPUImageAlphaBlendFilter *)blendFilter
{
    if (!_blendFilter) {
        _blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
        _blendFilter.mix = 1.0;
    }
    return _blendFilter;
}

- (GPUImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    }
    return _imageView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        switch (kChatManager.videoCaptureParam.videoSizePreset) {
            case RCRTCVideoSizePreset256x144:
                self.videoWidth = 256;
                self.videoHeight = 144;
                break;
            case RCRTCVideoSizePreset320x240:
                self.videoWidth = 320;
                self.videoHeight = 240;
                break;
            case RCRTCVideoSizePreset480x360:
                self.videoWidth = 480;
                self.videoHeight = 360;
                break;
            case RCRTCVideoSizePreset640x360:
                self.videoWidth = 640;
                self.videoHeight = 360;
                break;
            case RCRTCVideoSizePreset640x480:
                self.videoWidth = 640;
                self.videoHeight = 480;
                break;
            case RCRTCVideoSizePreset720x480:
                self.videoWidth = 720;
                self.videoHeight = 480;
                break;
            case RCRTCVideoSizePreset1280x720:
                self.videoWidth = 1280;
                self.videoHeight = 720;
                break;
            default:
                self.videoWidth = 640;
                self.videoHeight = 480;
                break;
        }
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.videoWidth, self.videoHeight)];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UIImageView *)watermarkImageView
{
    if (!_watermarkImageView) {
        _watermarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 80, 80)];
        _watermarkImageView.image = [UIImage imageNamed:@"chat_water_mark"];
//        _watermarkImageView.layer.cornerRadius = 8.0;
//        _watermarkImageView.layer.masksToBounds = YES;
        _watermarkImageView.transform = CGAffineTransformRotate(_watermarkImageView.transform, -M_PI_2);
    }
    return _watermarkImageView;
}

- (GPUImageUIElement *)uiElement
{
    if (!_uiElement) {
        [self.contentView addSubview:self.watermarkImageView];
        _uiElement = [[GPUImageUIElement alloc] initWithView:self.contentView];
    }
    return _uiElement;
}

@end
