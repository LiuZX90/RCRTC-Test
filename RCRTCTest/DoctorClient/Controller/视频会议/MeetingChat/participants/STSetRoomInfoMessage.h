//
//  STSetRoomInfoMessage.h
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

NS_ASSUME_NONNULL_BEGIN

@class STParticipantsInfo;

@interface STSetRoomInfoMessage : RCMessageContent

- (instancetype)initWithInfo:(STParticipantsInfo*)info
                      forKey:(NSString*)key;

@property (nonatomic, strong, readonly) STParticipantsInfo* info;
@property (nonatomic, copy, readonly) NSString* key;
@end

NS_ASSUME_NONNULL_END
