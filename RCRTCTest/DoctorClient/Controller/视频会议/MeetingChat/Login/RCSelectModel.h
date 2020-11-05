//
//  RCSelectModel.h
//  SealRTC
//
//  Created by 孙承秀 on 2019/8/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCSelectModel : NSObject

/**
 roomid
 */
@property(nonatomic , copy)NSString *rooomId;

/**
 room name
 */
@property(nonatomic , copy)NSString *roomName;

/**
 liveUrl
 */
@property(nonatomic , copy)NSString *liveUrl;
@end

NS_ASSUME_NONNULL_END
