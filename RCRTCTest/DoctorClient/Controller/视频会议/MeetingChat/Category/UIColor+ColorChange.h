//
//  UIColor+ColorChange.h
//  RongCloud
//
//  Created by Rongcloud on 2018/2/8.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorChange)

+ (UIColor *)colorWithHexString: (NSString *)color;
+ (UIColor *)randomColorForAvatarRBG;
+ (UIColor *)observerColor;

@end
