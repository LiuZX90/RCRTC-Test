//
//  STDeleteRoomInfoMessage.h
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface STDeleteRoomInfoMessage : RCMessageContent

- (instancetype)initWithInfoKey:(NSString*)key;

@property (nonatomic, copy, readonly) NSString* key;

@end

NS_ASSUME_NONNULL_END
