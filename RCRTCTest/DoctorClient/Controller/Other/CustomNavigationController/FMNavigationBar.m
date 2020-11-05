//
//  FMNavigationBar.m
//  FMChat
//
//  Created by PAN on 2020/8/21.
//  Copyright © 2020 zj. All rights reserved.
//

#import "FMNavigationBar.h"
#import "UINavigationBar+handle.h"
//#import "FMMacroDefinition.h"

@implementation FMNavigationBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setTranslucent:NO];//设置为NO后导航栏下方开始计算位置
//        UIImage * backimage = [[UIImage imageNamed:@"返回-默认"] imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
//        self.backIndicatorImage = backimage;
//        self.backIndicatorTransitionMaskImage = backimage;
        
            self.backIndicatorImage = [UIImage new];
            self.backIndicatorTransitionMaskImage = [UIImage new];
        
    }
    return self;
}


- (void)dealloc
{
    NSLog(@"FMNavBar release");
}

//- (CGSize)intrinsicContentSize {
//    return CGSizeMake(kScreenWidth, 44);
//}


- (void)setShadowImageColor:(UIColor *)imageColor{
    //必须调用setBackgroundImage设置导航栏背景，否则shadowImage无法生效
    //@"f7f7f7"同导航栏的颜色
//    self.shadowImage = [UIImage imageWithColor:imageColor size:CGSizeMake(0.5, 0.5)];
//    self.shadowImage = [UIImage buttonImageFromColor:imageColor imgSize:CGSizeMake(0.5, 0.5)];
}


+(void)setGlobalBackGroundImage:(UIImage *)globalBackgroundImage{
    
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[NSClassFromString(@"EMTNavBaseViewController")]];
    
    [navBar setBackgroundImage:globalBackgroundImage forBarMetrics:UIBarMetricsDefault];
}


+ (void)setGlobalTinColor:(UIColor *)globalTinColor{
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[NSClassFromString(@"EMTNavBaseViewController")]];
    [navBar setBarTintColor:globalTinColor];
    
}


+(void)setGlobalTextColor:(UIColor *)globalTextColor andFontSize:(CGFloat)fontSize{
    
    if (globalTextColor == nil) {
        return;
    }
    if (fontSize < 6 || fontSize > 40) {
        fontSize = 16;
    }
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[NSClassFromString(@"EMTNavBaseViewController")]];
    // 设置导航栏颜色
    NSDictionary *titleDic = @{
                               NSForegroundColorAttributeName: globalTextColor,
                               NSFontAttributeName: [UIFont systemFontOfSize:fontSize]
                               };
    
    [navBar setTitleTextAttributes:titleDic];
    
}

/**
 * 设置当前NavigationBar导航栏颜色
 *
 * @param tinColor 导航栏颜色
 */

- (void)setNavigationBarTinColor:(UIColor*)tinColor
{
    [self setBarTintColor:tinColor];
}


/**
 *  设置当前NavigationBar导航栏标题颜色, 和文字大小
 *
 *  @param textColor 导航栏标题颜色
 *  @param fontSize  导航栏文字大小
 */

- (void)setNavigationBarTextColor: (UIColor *)textColor andFontSize: (CGFloat)fontSize
{
    if (textColor == nil) {
        return;
    }
    if (fontSize < 6 || fontSize > 40) {
        fontSize = 16;
    }
    // 设置导航栏颜色
    NSDictionary *titleDic = @{
                               NSForegroundColorAttributeName: textColor,
                               NSFontAttributeName: [UIFont systemFontOfSize:fontSize]
                               };
    
    [self setTitleTextAttributes:titleDic];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.translucent = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
