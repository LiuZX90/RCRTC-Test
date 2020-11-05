//
//  FMNavigationBar.h
//  FMChat
//
//  Created by PAN on 2020/8/21.
//  Copyright © 2020 zj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMNavigationBar : UINavigationBar

- (void)setShadowImageColor:(UIColor *)imageColor;

/**
 *  设置全局的导航栏背景图片
 *
 *  @param globalBackgroundImage 全局导航栏背景图片
 */

+ (void)setGlobalBackGroundImage: (UIImage *)globalBackgroundImage;


/**
 * 设置全局导航栏颜色
 *
 * @param globalTinColor 全局导航栏颜色
 */

+ (void)setGlobalTinColor:(UIColor*)globalTinColor;


/**
 *  设置全局导航栏标题颜色, 和文字大小
 *
 *  @param globalTextColor 全局导航栏标题颜色
 *  @param fontSize        全局导航栏文字大小
 */

+ (void)setGlobalTextColor: (UIColor *)globalTextColor andFontSize: (CGFloat)fontSize;

@end

NS_ASSUME_NONNULL_END
