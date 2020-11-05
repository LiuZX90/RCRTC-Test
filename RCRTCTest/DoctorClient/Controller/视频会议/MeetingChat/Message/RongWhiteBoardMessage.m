//
//  RongWhiteBoardMessage.m
//  SealRTC
//
//  Created by LiuLinhong on 2019/05/06.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RongWhiteBoardMessage.h"

@implementation RongWhiteBoardMessage

- (instancetype)initWhiteBoardMessage:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.whiteBoardDict = dict;
    }
    return self;
}

- (NSData *)encode {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.whiteBoardDict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    return data;
}

- (void)decodeWithData:(NSData *)data {
    if (data) {
        self.whiteBoardDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
}

+(RCMessagePersistent)persistentFlag{
    return MessagePersistent_STATUS;
}
+(NSString *)getObjectName{
    return RTCWhiteBoardMessageObjectName;
}

@end
