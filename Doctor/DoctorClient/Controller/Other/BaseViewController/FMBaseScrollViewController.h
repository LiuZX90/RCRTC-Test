//
//  FMBaseScrollViewController.h
//  FMChat
//
//  Created by PAN on 2020/8/19.
//  Copyright © 2020 zj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMBaseScrollViewController : UIViewController

@property(nonatomic,strong) UIView * contentView;

- (void)setupUI;

@end

NS_ASSUME_NONNULL_END
