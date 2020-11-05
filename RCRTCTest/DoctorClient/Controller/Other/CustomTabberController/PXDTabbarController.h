//
//  PXDTabbarController.h
//  DoctorClient
//
//  Created by company_mac on 2020/9/25.
//  Copyright © 2020 ZengPengYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUITabBarItem : NSObject
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIViewController *controller;
@end

@interface PXDTabbarController : UITabBarController

@end

NS_ASSUME_NONNULL_END
