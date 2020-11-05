//
//  PXDBaseViewController.h
//  DoctorClient
//
//  Created by company_mac on 2020/9/28.
//  Copyright © 2020 ZengPengYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PXDBaseViewController : UIViewController

// 滚动视图
@property (nonatomic, strong) UIScrollView *scroll;

-(void)reloadData;

/**
 
 @interface UIViewController (Extension)
 //  在主线程执行操作
 - (void)performSelectorOnMainThread:(void(^)(void))block;

 //  退出 presentViewController  count：次数
 - (void)dismissViewControllerWithCount:(NSInteger)count animated:(BOOL)animated;


 // 退出 presentViewController 到指定的控制器
 - (void)dismissToViewControllerWithClassName:(NSString *)className animated:(BOOL)animated;

 @end


 @class ByronPageModel;
@interface ByronVC : UIViewController
 
 // 滚动视图
 @property (nonatomic, strong) UIScrollView *scroll;
 // 是否已经加载数据
 @property (nonatomic, assign) BOOL firstLoad;
 // 导航栏左边按钮
 @property (nonatomic, strong) UIButton *leftItem;
 // 导航栏右边按钮
 @property (nonatomic, strong) UIButton *rightItem;

 // 分页
 @property (nonatomic, strong) ByronPageModel *pagemodel;
 @property (nonatomic, strong) NSMutableArray *sources;

 #pragma mark - 一、StatusBar

 /// 1、白色状态栏
 - (void)WhiteStatusBarStyleDefault;

 /// 2、黑色状态栏
 - (void)DefaultStatusBarStyleDefault;


 #pragma mark - 二、导航栏

 /// 1、导航栏左边按钮方法
 /// @param sender 导航栏按钮
 - (void)LeftBarItemMethod:(UIButton *)sender;

 /// 2、导航栏右边按钮方法
 /// @param sender 导航栏按钮
 - (void)RightBarItemMethod:(UIButton *)sender;

 /// 3、设置导航栏背景图片
 /// @param image 背景图片
 - (void)NavigationImageWith:(UIImage *)image;

 /// 3-1、设置导航栏背景颜色
 /// @param color 背景颜色
 - (void)NavigationColorWith:(UIColor *)color;

 /// 4、设置导航栏标题颜色
 /// @param color 标题颜色
 - (void)NavigationTitleColorWith:(UIColor *)color;

 /// 5、设置导航栏标题颜色和字体
 /// @param color 标题颜色
 /// @param font 字体
 - (void)NavigationTitleColorWith:(UIColor *)color font:(UIFont *)font;

 /// 6、添加导航栏横线
 - (void)AddNavigationLine;


 #pragma mark - 三、导航栏按钮

 /// 1、左边默认返回按钮
 - (void)AddLeftItemWithDefault;

 /// 2、设置左边导航栏按钮图片
 /// @param image 按钮图片
 - (void)AddLeftItemWithImage:(UIImage *)image;

 /// 3、右边默认更多按钮
 - (void)AddRightItemWithDefault;

 /// 4、设置右边导航栏按钮图片
 /// @param image 按钮图片
 - (void)AddRightItemWithImage:(UIImage *)image;

 /// 5、隐藏返回按钮
 - (void)HideBackItem;

 /// 6、设置导航栏左视图
 /// @param view 自定义左视图
 - (void)AddLeftView:(UIView *)view;

 /// 7、设置导航栏右视图
 /// @param view 自定义右视图
 - (void)AddRightView:(UIView *)view;

 #pragma mark - 四、键盘通知

 /// 1、添加键盘通知
 - (void)AddKeyboardNotification;


 #pragma mark - 五、通知方法

 /// 1、键盘即将显示
 /// @param noti 通知
 - (void)keyboardWillApprear:(NSNotification *)noti;

 /// 2、键盘即将隐藏
 /// @param noti 通知
 - (void)keyboardWillDisAppear:(NSNotification *)noti;

 #pragma mark - 七、数据处理

 /// 1、加入数组数据到数据源中
 /// @param page 当前数据的页码
 /// @param array 待加入数据
 /// @param section section
 - (NSArray<NSIndexPath *> *)AddArrayWith:(NSInteger)page array:(NSArray *)array section:(NSInteger)section;

 /// 2、下一页
 /// @param more 加载更多
 - (NSInteger)nextPageWithMore:(BOOL)more;

 /// 3、下一页
 /// @param more 加载更多
 /// @param model model
 - (NSInteger)nextPageWithMore:(BOOL)more model:(ByronPageModel *)model;

 #pragma mark - 八、diss
 - (void)dismissToRootViewController;

 - (void)reloadData;

 */




@end

NS_ASSUME_NONNULL_END
