//
//  RongWhiteBoardMessage.h
//  SealRTC
//
//  Created by LiuLinhong on 2019/05/06.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#define RTCWhiteBoardMessageObjectName @"SealRTC:WhiteBoardInfo"

NS_ASSUME_NONNULL_BEGIN

@interface RongWhiteBoardMessage : RCMessageContent

@property (nonatomic, strong) NSDictionary *whiteBoardDict;

- (instancetype)initWhiteBoardMessage:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
