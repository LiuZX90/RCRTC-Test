//
//  ChatRongVideoRTCEncryptorDelegateImpl.m
//  SealRTC
//
//  Created by RongCloud on 2020/7/29.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "ChatRongVideoRTCEncryptorDelegateImpl.h"

@implementation ChatRongVideoRTCEncryptorDelegateImpl

- (int)EncryptPayloadData:(const uint8_t *)payloadData
              payloadSize:(size_t)payloadSize
           encryptedFrame:(uint8_t *)encryptedFrame
             bytesWritten:(size_t *)bytesWritten {
    uint8_t fake_key_ = 0x88;
    for (size_t i = 0; i < payloadSize; i++) {
        if (i % 2 == 0)
            encryptedFrame[i] = payloadData[i] ^ fake_key_;
        else
            encryptedFrame[i] = payloadData[i];
    }
    *bytesWritten = payloadSize;
    return 0;
}

- (size_t)GetMaxCiphertextByteSize:(size_t)frameSize {
    return frameSize;
}

@end
