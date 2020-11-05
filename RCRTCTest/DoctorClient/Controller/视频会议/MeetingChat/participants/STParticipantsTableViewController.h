//
//  STParticipantsTableViewController.h
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RCRTCRoom;
@class STParticipantsInfo;
@interface STParticipantsTableViewController : UITableViewController

- (instancetype)initWithRoom:(RCRTCRoom*)room
           participantsInfos:(NSMutableArray<STParticipantsInfo*>*) array;

@end

NS_ASSUME_NONNULL_END
