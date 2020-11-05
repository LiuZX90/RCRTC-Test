//
//  FMNavBaseViewController.m
//  FMChat
//
//  Created by PAN on 2020/8/20.
//  Copyright © 2020 zj. All rights reserved.
//

#import "FMNavBaseViewController.h"
#import "FMNavigationBar.h"
//#import "FMMacroDefinition.h"

@interface FMNavBaseViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate,UINavigationBarDelegate>
@property(nonatomic,assign)BOOL isForBidden;

@end

@implementation FMNavBaseViewController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    if (self = [super initWithRootViewController:rootViewController]) {
        FMNavigationBar *navBar = [[FMNavigationBar alloc] init];
//        if (APPTYPE == kAPP_GeekChat) {
            [navBar setShadowImageColor:[UIColor clearColor]];
//            [navBar setNavigationBarTinColor:kThemeColor];
//            [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: kMediumFont(20.0f)}];
//        }else{
//            [navBar setShadowImageColor:[UIColor colorWithHexString:@"c9cbca"]];
//            [navBar setNavigationBarTinColor:[UIColor colorWithHexString:@"FFFFFF"]];
//            [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName: kThemeColor, NSFontAttributeName: kMediumFont(20.0f)}];
//        }
//
        [self setValue:navBar forKey:@"navigationBar"];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"EMTNavBaseViewController is dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

//设置状态栏风格
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (UIViewController *)childViewControllerForStatusBarStyle{
    return self.topViewController;
}

#pragma mark - 控制视图旋转方向

- (BOOL)shouldAutorotate{
    return self.topViewController.shouldAutorotate;
}

//支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

//默认方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}


//设置返回手势是否禁止
- (void)setupBackPanGestureIsForbiddden:(BOOL)isForBidden{
    self.isForBidden = isForBidden;
    //设置手势代理
    UIGestureRecognizer *gesture = self.interactivePopGestureRecognizer;
    // 自定义手势 手势加在谁身上, 手势执行谁的什么方法
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:gesture.delegate action:NSSelectorFromString(@"handleNavigationTransition:")];
    //为控制器的容器视图
    [gesture.view addGestureRecognizer:panGesture];

    gesture.delaysTouchesBegan = YES;
    panGesture.delegate = self;
}

#pragma mark - UIGestureRecognizerDelegate 手势代理方法
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //需要过滤根控制器   如果根控制器也要返回手势有效, 就会造成假死状态
    if (self.childViewControllers.count == 1) {
        return NO;
    }
    if (self.isForBidden) {
        return NO;
    }
    return YES;
}


#pragma mark - 重写父类方法拦截push方法
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    //避免同一个控制器连续push的问题
    if (self.isPushing) {
        NSLog(@"self.pushing pushViewController --------------");
        return;
    }else{
        self.pushing = YES;
        NSLog(@"self.pushing pushViewController =============");
    }
    
    //判断是否为第一层控制器
    if (self.childViewControllers.count > 0) { //如果push进来的不是第一个控制器
//        EMTNavBar *nb = (EMTNavBar *)self.navigationBar;
//        [nb setTitleTextAttributes:@{NSForegroundColorAttributeName: kTextColor, NSFontAttributeName: kRegularFont(18.0f)}];
//        [nb setNavigationBarTinColor:[UIColor colorWithHexString:@"FFFFFF"]];
//        [nb setShadowImageColor:[UIColor colorWithHexString:@"c9cbca"]];

        
        if ([viewController isKindOfClass:NSClassFromString(@"InviteFriendsVC")] ||
            [viewController isKindOfClass:NSClassFromString(@"ElectorPrescVC")] ||
            [viewController isKindOfClass:NSClassFromString(@"SelectDrugVC")] ||
            [viewController isKindOfClass:NSClassFromString(@"IncomeViewController")]) {
            
            UIImage *highlighted_backImage = [[UIImage imageNamed:@"通用-白色返回"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:highlighted_backImage style:UIBarButtonItemStylePlain target:self action:nil];
            viewController.navigationItem.backBarButtonItem = backButton;
            self.visibleViewController.navigationItem.backBarButtonItem = backButton;
            
        }else{
            UIImage *highlighted_backImage = [[UIImage imageNamed:@"返回-默认"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:highlighted_backImage style:UIBarButtonItemStylePlain target:self action:nil];
            viewController.navigationItem.backBarButtonItem = backButton;
            self.visibleViewController.navigationItem.backBarButtonItem = backButton;
        }

//        UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:(UIBarButtonItemStylePlain) target:self action:nil];
//        self.visibleViewController.navigationItem.backBarButtonItem = backButtonItem;
        
        //当push的时候 隐藏tabbar
        for (UIView *view in self.navigationBar.subviews) {
            if ([NSStringFromClass([view class]) isEqual:@"_UINavigationBarContentView"]) {
                for (UIView* v = nil in view.subviews) {
                    NSLog(@"%@",v);
                    if ([NSStringFromClass([v class]) isEqual:@"_UIButtonBarButton"]) {
                        v.frame = CGRectMake(5, 0, 29, 44);
                    }
                }
            }
        }

        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    //先设置leftItem  再push进去 之后会调用viewdidLoad  用意在于vc可以覆盖上面设置的方法
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController * vc = [super popViewControllerAnimated:animated];
    
//    EMTNavBar *nb = (EMTNavBar *)self.navigationBar;
//    [nb setTitleTextAttributes:@{NSForegroundColorAttributeName : self.viewControllers.count > 1 ? kTextColor : kThemeColor, NSFontAttributeName : self.viewControllers.count > 1 ? kRegularFont(18.0f) : kMediumFont(20.0f)}];
//    if (self.viewControllers.count == 1 && APPTYPE == kAPP_GeekChat) {
//        [self reSetNaviBarThemeStyle];
//    }
    
    return vc;
}

//- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
//
//    if (self.viewControllers.count == 1 && APPTYPE == kAPP_GeekChat) {
//       [self reSetNaviBarThemeStyle];
//    }
//
//    return [super popToViewController:viewController animated:animated];
//}
//
//- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
//{
//    if (APPTYPE == kAPP_GeekChat) {
//        [self reSetNaviBarThemeStyle];
//    }
//    return [super popToRootViewControllerAnimated:animated];
//}

//重置导航栏为主色调的颜色
- (void)reSetNaviBarThemeStyle{
//    EMTNavBar *nb = (EMTNavBar *)self.navigationBar;
//    [nb setNavigationBarTinColor:kThemeColor];
//    [nb setShadowImageColor:kThemeColor];
}

//设置Push后的导航栏颜色
- (void)setPushNaviBarStyle{
//    EMTNavBar *nb = (EMTNavBar *)self.navigationBar;
//    [nb setNavigationBarTinColor:[UIColor colorWithHexString:@"FFFFFF"]];
//    [nb setShadowImageColor:[UIColor colorWithHexString:@"c9cbca"]];
}

- (void)leftBarButtonItemClicked
{
    [self popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;{
    
    self.pushing = NO;
    NSLog(@"self.pushing willShowViewController ************");
    
    UIGestureRecognizer *gesture = self.interactivePopGestureRecognizer;
    
    NSLog(@"gesture.state-----%ld",(long)gesture.state);
    
    __block BOOL  isCancelled = YES;
    id <UIViewControllerTransitionCoordinator>tc = navigationController.topViewController.transitionCoordinator;
    [tc notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        isCancelled = [context isCancelled];
        NSLog(@"isCancelled-----%@",isCancelled ? @"YES":@"NO");
        if (isCancelled) {
//            EMTNavBar *nb = (EMTNavBar *)self.navigationBar;
//            [nb setTitleTextAttributes:@{NSForegroundColorAttributeName: kTextColor, NSFontAttributeName: kRegularFont(18.0f)}];
//            [nb setNavigationBarTinColor:[UIColor colorWithHexString:@"FFFFFF"]];
//            [nb setShadowImageColor:[UIColor colorWithHexString:@"c9cbca"]];
        }
    }];

}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    self.pushing = NO;
    NSLog(@"self.pushing didShowViewController +++++++++++++++");
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
