//
//  ChatRongRTCRoomDelegateImpl.h
//  SealRTC
//
//  Created by LiuLinhong on 2019/02/14.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>


@class STParticipantsInfo;

NS_ASSUME_NONNULL_BEGIN

@interface ChatRongRTCRoomDelegateImpl : NSObject <RCRTCRoomEventDelegate>

@property (nonatomic, weak) NSMutableArray<STParticipantsInfo*>* infos;
- (instancetype)initWithViewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
