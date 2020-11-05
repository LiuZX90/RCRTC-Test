//
//  ChatMembersViewController.h
//  SealRTC
//
//  Created by jfdreamyang on 2019/4/23.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatMembersViewController : UIViewController
@property (nonatomic,strong)RCRTCRoom *currentRoom;
@end

NS_ASSUME_NONNULL_END
