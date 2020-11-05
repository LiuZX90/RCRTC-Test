//
//  STDeleteRoomInfoMessage.m
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "STDeleteRoomInfoMessage.h"

@interface STDeleteRoomInfoMessage()

@property (nonatomic, copy) NSString* key;

@end

@implementation STDeleteRoomInfoMessage

- (instancetype)initWithInfoKey:(NSString*)key {
    if (self = [super init]) {
        self.key = key;
    }
    return self;
}


///消息是否存储，是否计入未读数
+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_STATUS;
}


///将消息内容编码成json
- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:self.key forKey:@"infoKey"];
    //    [dataDict setObject:self.content forKey:@"content"];
    //    if (self.extra) {
    //        [dataDict setObject:self.extra forKey:@"extra"];
    //    }
    //
    //    if (self.senderUserInfo) {
    //        [dataDict setObject:[self encodeUserInfo:self.senderUserInfo] forKey:@"user"];
    //    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    return data;
}

///将json解码生成消息内容
- (void)decodeWithData:(NSData *)data {
    if (data) {
        __autoreleasing NSError *error = nil;
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (dictionary) {
            self.key = dictionary[@"infoKey"];
            //            self.content = dictionary[@"content"];
            //            self.extra = dictionary[@"extra"];
            //
            //            NSDictionary *userinfoDic = dictionary[@"user"];
            //            [self decodeUserInfo:userinfoDic];
        }
    }
}

/// 会话列表中显示的摘要
- (NSString *)conversationDigest {
    return @"SealRTC:DeleteRoomInfo";
}

///消息的类型名
+ (NSString *)getObjectName {
    return @"SealRTC:DeleteRoomInfo";
}

@end
