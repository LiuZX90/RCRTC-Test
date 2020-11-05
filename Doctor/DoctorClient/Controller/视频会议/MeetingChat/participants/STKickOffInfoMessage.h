//
//  STKickOffInfoMessage.h
//  SealRTC
//
//  Created by LiuLinhong on 2019/11/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface STKickOffInfoMessage : RCMessageContent

@property (nonatomic, strong) NSDictionary *kickOffDict;

- (instancetype)initKickOffMessage:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
