//
//  STKickOffInfoMessage.m
//  SealRTC
//
//  Created by LiuLinhong on 2019/11/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "STKickOffInfoMessage.h"


@implementation STKickOffInfoMessage

- (instancetype)initKickOffMessage:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.kickOffDict = dict;
    }
    return self;
}

- (NSData *)encode {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.kickOffDict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    return data;
}

- (void)decodeWithData:(NSData *)data {
    if (data) {
        self.kickOffDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
}

///消息是否存储，是否计入未读数
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_STATUS;
}

/// 会话列表中显示的摘要
- (NSString *)conversationDigest {
    return @"SealRTC:KickOff";
}

///消息的类型名
+ (NSString *)getObjectName {
    return @"SealRTC:KickOff";
}

@end
