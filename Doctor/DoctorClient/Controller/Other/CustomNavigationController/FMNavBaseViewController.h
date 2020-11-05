//
//  FMNavBaseViewController.h
//  FMChat
//
//  Created by PAN on 2020/8/20.
//  Copyright © 2020 zj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMNavBaseViewController : UINavigationController

// 记录push标志
@property (nonatomic, getter=isPushing) BOOL pushing;

@end

NS_ASSUME_NONNULL_END
