//
//  ChatRongAudioRTCDecryptorDelegateImpl.m
//  SealRTC
//
//  Created by RongCloud on 2020/7/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "ChatRongAudioRTCDecryptorDelegateImpl.h"

@implementation ChatRongAudioRTCDecryptorDelegateImpl

- (int)DecryptFrame:(const uint8_t *)encryptedFrame
          frameSize:(size_t)encryptedFrameSize
              frame:(nonnull uint8_t *)frame
       bytesWritten:(nonnull size_t *)bytesWritten {
    uint8_t fake_key_ = 0x88;
    
    for (size_t i = 0; i < encryptedFrameSize; i++) {
        frame[i] = encryptedFrame[i]^ fake_key_;
    }
    
    *bytesWritten = encryptedFrameSize;
    return 0;
}

- (size_t)GetMaxPlaintextByteSize:(size_t)frameSize {
    return frameSize;
}

@end
