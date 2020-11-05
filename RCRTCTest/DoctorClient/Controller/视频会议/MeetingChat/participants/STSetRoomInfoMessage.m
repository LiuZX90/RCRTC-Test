//
//  STSetRoomInfoMessage.m
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "STSetRoomInfoMessage.h"
#import "STParticipantsInfo.h"

@interface STSetRoomInfoMessage()

@property (nonatomic, strong) STParticipantsInfo* info;
@property (nonatomic, copy) NSString* key;

@end

@implementation STSetRoomInfoMessage

- (instancetype)initWithInfo:(STParticipantsInfo*)info
                      forKey:(NSString*)key {
    if (self = [super init]) {
        self.info = info;
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
    [dataDict setObject:[self.info toDictionary] forKey:@"infoValue"];
    [dataDict setObject:self.key forKey:@"infoKey"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
    return data;
}

///将json解码生成消息内容
- (void)decodeWithData:(NSData *)data {
    if (data) {
        __autoreleasing NSError *error = nil;
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (dictionary) {
            NSDictionary* infoValue = dictionary[@"infoValue"];
            self.info = [[STParticipantsInfo alloc] initWithDictionary:infoValue];
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
    return @"SealRTC:SetRoomInfo";
}

///消息的类型名
+ (NSString *)getObjectName {
    return @"SealRTC:SetRoomInfo";
}

@end
