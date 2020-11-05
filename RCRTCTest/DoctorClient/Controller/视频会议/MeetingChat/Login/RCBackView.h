//
//  RCBackView.h
//  SealRTC
//
//  Created by 孙承秀 on 2019/8/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCSelectModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCBackView : UIView
- (void)reload:(NSArray *)arr;
- (void)setCallBack:(void (^)(RCSelectModel *))callBack;
@end

NS_ASSUME_NONNULL_END
