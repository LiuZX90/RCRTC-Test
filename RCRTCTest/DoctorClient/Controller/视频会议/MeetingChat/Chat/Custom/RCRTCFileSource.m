//
//  RCRTCFileSource.m
//  RongRTCLib
//
//  Created by jfdreamyang on 2019/1/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCRTCFileSource.h"

NSString *const kIMFileVideoCapturerErrorDomain = @"cn.rongcloud.RCRTCFileVideoCapturer";

typedef NS_ENUM(NSInteger, IMFileVideoCapturerErrorCode) {
    RCRTCFileVideoCapturerErrorCode_CapturerRunning = 2000,
    RCRTCFileVideoCapturerErrorCode_FileNotFound
};

typedef NS_ENUM(NSInteger, RCRTCFileVideoCapturerStatus) {
    RCRTCFileVideoCapturerStatusNotInitialized,
    RCRTCFileVideoCapturerStatusStarted,
    RCRTCFileVideoCapturerStatusStopped
};

@implementation RCRTCFileSource
{
    AVAssetReader *_reader;
    AVAssetReaderTrackOutput *_outVideoTrack;
    AVAssetReaderTrackOutput *_outAudioTrack;
    RCRTCFileVideoCapturerStatus _status;
    CMTime _lastPresentationTime;
    dispatch_queue_t _frameQueue;
    NSURL *_fileURL;
    
    Float64 _currentMediaTime;
    Float64 _currentVideoTime;
    NSThread* _audioDecodeThread;
    //dispatch_queue_t _completionQueue;
}

@synthesize observer = _observer;

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];

    if (self) {
        _currentPath = filePath;
        //_completionQueue = dispatch_queue_create("com.rongcloud.file.completion.queue", NULL);
        if (@available(iOS 10, macOS 10.12, tvOS 10, watchOS 3, *)) {
            _frameQueue = 
                dispatch_queue_create_with_target("org.webrtc.filecapturer.video", 
                                                  DISPATCH_QUEUE_SERIAL, 
                                                  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
        } else {
            _frameQueue = 
                dispatch_queue_create("org.webrtc.filecapturer.video", DISPATCH_QUEUE_SERIAL);
            dispatch_set_target_queue(_frameQueue, 
                                      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
        }
    }

    return self;
}

#pragma mark - RCRTCVideoSourceInterface
- (void)setObserver: (id <RCRTCVideoObserverInterface>)observer {
    _observer = observer;
}

- (void)didInit {
}

- (void)didStart {
    [self start];
}

- (void)didStop {
    [self stop];
}

- (BOOL)start {
    if (_status == RCRTCFileVideoCapturerStatusStarted) {
        return NO;
    } else {
        _status = RCRTCFileVideoCapturerStatusStarted;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self->_lastPresentationTime = CMTimeMake(0, 0);
            self->_fileURL = [NSURL fileURLWithPath:self->_currentPath];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:self->_currentPath]) {
                NSLog(@"视频地址存在：%@", self->_currentPath);
            }else{
                NSLog(@"视频地址不存在：%@", self->_currentPath);
            }
            
            [self setupReader];
        });
    }
    return YES;
}

- (BOOL)stop {
    _status = RCRTCFileVideoCapturerStatusStopped;
    [_audioDecodeThread cancel];
    return YES;
}

#pragma mark - Private

- (void)setupAudioTrakOutput:(AVURLAsset*)asset {
    AVAssetTrack* audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    AudioStreamBasicDescription asbd = RCRTCAudioMixer.writeAsbd;
    NSDictionary* settings = @{AVFormatIDKey:               @(kAudioFormatLinearPCM),
                               AVSampleRateKey:             @(asbd.mSampleRate),
                               AVNumberOfChannelsKey:       @(asbd.mChannelsPerFrame),
                               AVLinearPCMIsNonInterleaved: @(NO)};
    _outAudioTrack = 
        [[AVAssetReaderTrackOutput alloc] initWithTrack:audioTrack outputSettings:settings];
    if ([_reader canAddOutput:_outAudioTrack]) {
        [_reader addOutput:_outAudioTrack];
    }
}

- (void)audioDecode {
    SInt64 sampleTime = 0;
    while (![NSThread currentThread].isCancelled) {
        CMSampleBufferRef sample = [_outAudioTrack copyNextSampleBuffer];
        if (!sample) {
            break;
        }
        AudioBufferList abl = {0};
        CMBlockBufferRef blockBuffer;
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sample,
                                                                NULL,
                                                                &abl,
                                                                sizeof(abl),
                                                                NULL,
                                                                NULL,
                                                                0,
                                                                &blockBuffer);
        CMItemCount count =  CMSampleBufferGetNumSamples(sample);
        [[RCRTCAudioMixer sharedInstance] writeAudioBufferList:&abl 
                                                        frames:(UInt32)count 
                                                    sampleTime:sampleTime 
                                                      playback:YES];
        sampleTime += count;
        CFRelease(blockBuffer);
        CFRelease(sample);
    }

    _audioDecodeThread = nil;
    [NSThread exit];
}

- (void)setupReader {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_fileURL options:nil];
    NSArray *allTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    // 可以矫正由于时间偏差导致输出不准确的问题，也可以解决循环播放导致的中间播放延迟，中间会丢弃一部分视频帧
    _currentMediaTime = CACurrentMediaTime();
    _currentVideoTime = _currentMediaTime;
    
    _lastPresentationTime = CMTimeMakeWithSeconds(0.0, 1);
    _reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if (error) {
        return;
    }
    
    NSDictionary *options = @{
                              (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
                              };
    _outVideoTrack =
        [[AVAssetReaderTrackOutput alloc] initWithTrack:allTracks.firstObject 
                                         outputSettings:options];
    _outVideoTrack.alwaysCopiesSampleData = NO;
    [_reader addOutput:_outVideoTrack];
    [self setupAudioTrakOutput:asset];
    [_reader startReading];
    if (!_audioDecodeThread) {
        _audioDecodeThread = 
            [[NSThread alloc] initWithTarget:self selector:@selector(audioDecode) object:nil];
    }
    [_audioDecodeThread start];
    [self readNextBuffer];
}

- (void)readBuffer{
    
}

- (nullable NSString *)pathForFileName:(NSString *)fileName {
    NSArray *nameComponents = [fileName componentsSeparatedByString:@"."];
    if (nameComponents.count != 2) {
        return nil;
    }
    
    NSString *path =
    [[NSBundle mainBundle] pathForResource:nameComponents[0] ofType:nameComponents[1]];
    return path;
}

- (void)readNextBuffer {
    if (_status == RCRTCFileVideoCapturerStatusStopped) {
        [_reader cancelReading];
        _reader = nil;
        [_audioDecodeThread cancel];
        _outAudioTrack = nil;
        [self.delegate didReadCompleted];

        return;
    }
    
    if (_reader.status == AVAssetReaderStatusCompleted) {
        [_reader cancelReading];
        _reader = nil;
        [_audioDecodeThread cancel];
        _outAudioTrack = nil;
        [self.delegate didReadCompleted];
        [self setupReader];

        return;
    }
    
    CMSampleBufferRef sampleBuffer = [_outVideoTrack copyNextSampleBuffer];
    if (!sampleBuffer) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf readNextBuffer];
        });
        
        return;
    }
    if (CMSampleBufferGetNumSamples(sampleBuffer) != 1 || !CMSampleBufferIsValid(sampleBuffer) ||
        !CMSampleBufferDataIsReady(sampleBuffer)) {
        CFRelease(sampleBuffer);
        [self readNextBuffer];
        return;
    }
    
    [self publishSampleBuffer:sampleBuffer];
}

- (void)publishSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    Float64 presentationDifference =
    CMTimeGetSeconds(CMTimeSubtract(presentationTime, _lastPresentationTime));
    _lastPresentationTime = presentationTime;
    __weak typeof(self) weakSelf = self;
    if (isnan(presentationDifference)) {
        CFRelease(sampleBuffer);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf readNextBuffer];
        });
        return;
    }
    _currentVideoTime += presentationDifference;
    _currentMediaTime = CACurrentMediaTime();
    
    Float64 delta = fabs(_currentMediaTime - _currentVideoTime);
    if (presentationDifference != 0 && delta > 0.2) {
        if (delta > 2) {
            _currentVideoTime = _currentMediaTime;
        }
        CFRelease(sampleBuffer);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf readNextBuffer];
        });
        return;
    }
    int64_t presentationDifferenceRound = lroundf(presentationDifference * NSEC_PER_SEC);
    
    __block dispatch_source_t timer = [self createStrictTimer];
    // Strict timer that will fire |presentationDifferenceRound| ns from now and never again.
    dispatch_source_set_timer(timer,
                              dispatch_time(DISPATCH_TIME_NOW, presentationDifferenceRound),
                              DISPATCH_TIME_FOREVER,
                              0);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_source_cancel(timer);
        timer = nil;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (!pixelBuffer) {
            CFRelease(sampleBuffer);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [weakSelf readNextBuffer];
            });
            return;
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf readNextBuffer];
        });

        [self.observer write:sampleBuffer error:nil];
        CFRelease(sampleBuffer);
    });
    if (@available(iOS 10.0, *)) {
        dispatch_activate(timer);
    } else {
        // Fallback on earlier versions
    }
    // dispatch_async(_completionQueue, ^{
    // });
}

- (dispatch_source_t)createStrictTimer {
    dispatch_source_t timer =
        dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, DISPATCH_TIMER_STRICT, _frameQueue);

    return timer;
}

- (void)dealloc {
    [self stop];
}

@end

