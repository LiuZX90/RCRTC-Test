//
//  ChatRongVideoRTCDecryptorDelegateImpl.m
//  SealRTC
//
//  Created by RongCloud on 2020/7/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "ChatRongVideoRTCDecryptorDelegateImpl.h"
#import "ChatRongVideoRTCEncryptorDelegateImpl.h"

@implementation ChatRongVideoRTCDecryptorDelegateImpl

- (int)DecryptFrame:(const uint8_t *)encryptedFrame
          frameSize:(size_t)encryptedFrameSize
              frame:(nonnull uint8_t *)frame
       bytesWritten:(nonnull size_t *)bytesWritten {
    uint8_t fake_key_ = 0x88;
    
    for (size_t i = 0; i < encryptedFrameSize; i++) {
        if (i % 2 == 0)
            frame[i] = encryptedFrame[i] ^ fake_key_;
        else
            frame[i] = encryptedFrame[i];
    }
    
    *bytesWritten = encryptedFrameSize;
    
    FwLogD(RC_Type_APP,@"A-DecryptFrame-T",@"frameSize:%@, bytesWritten:%@",@(encryptedFrameSize),@(*bytesWritten));
    
    return 0;
}

- (size_t)GetMaxPlaintextByteSize:(size_t)frameSize {
    return frameSize;
}

@end
