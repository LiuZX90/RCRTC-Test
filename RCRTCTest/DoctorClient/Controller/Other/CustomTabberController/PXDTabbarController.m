//
//  PXDTabbarController.m
//  DoctorClient
//
//  Created by company_mac on 2020/9/25.
//  Copyright © 2020 ZengPengYuan. All rights reserved.
//

#import "PXDTabbarController.h"
#import "FMNavBaseViewController.h"

#import "HomeViewController.h"
//#import "MessageListViewController.h"
//#import "InquiryListViewController.h"
#import "MineViewController.h"

@implementation TUITabBarItem
@end


@interface PXDTabbarController ()

@end

@implementation PXDTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    

//    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    
    if (@available(iOS 10.0, *)) {
        self.tabBar.unselectedItemTintColor = [UIColor blackColor];
        self.tabBar.tintColor = [UIColor systemBlueColor];
    }else{
        //全局设置
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor systemBlueColor]} forState:UIControlStateSelected];
    }

    [self setMainController];
}

- (void)setMainController{

    /**
     NSArray *vcs = @[@"HomeViewController",@"MessageListViewController",@"InquiryListViewController",@"MineViewController"];
     NSArray *titles = @[@"首页",@"消息",@"问诊单",@"我的"];
     NSArray *images = @[@"home1",@"message_normal",@"order_normal",@"mine_normal"];
     NSArray *selectImages = @[@"home",@"message_selected",@"order_selected",@"mine_selected"];
     */
    
    
    NSMutableArray *items = [NSMutableArray array];
    TUITabBarItem *msgItem = [[TUITabBarItem alloc] init];
    msgItem.title = @"首页";
    msgItem.selectedImage = [UIImage imageNamed:@"home_selected"];
    msgItem.normalImage = [UIImage imageNamed:@"home_normal"];
    
//    UIViewController * hVC = [[UIViewController alloc] init];
//    hVC.view.backgroundColor = [UIColor systemBlueColor];
//    msgItem.controller = [[FMNavBaseViewController alloc] initWithRootViewController:hVC];
    
    msgItem.controller = [[FMNavBaseViewController alloc] initWithRootViewController:[[HomeViewController alloc] init]];
    [items addObject:msgItem];
    
//    TUITabBarItem *contactItem = [[TUITabBarItem alloc] init];
//    contactItem.title = @"消息";
//    contactItem.selectedImage = [UIImage imageNamed:@"message_selected"];
//    contactItem.normalImage = [UIImage imageNamed:@"message_normal"];
//
////    UIViewController * cVC = [[UIViewController alloc] init];
////    cVC.view.backgroundColor = [UIColor systemRedColor];
////    contactItem.controller = [[FMNavBaseViewController alloc] initWithRootViewController:cVC];
//
//    contactItem.controller = [[FMNavBaseViewController alloc] initWithRootViewController:[[MessageListViewController alloc] init]];
//    [items addObject:contactItem];
//
//    TUITabBarItem *applicationItem = [[TUITabBarItem alloc] init];
//    applicationItem.title = @"问诊单";
//    applicationItem.selectedImage = [UIImage imageNamed:@"order_selected"];
//    applicationItem.normalImage = [UIImage imageNamed:@"order_normal"];
//
////    UIViewController * pVC = [[UIViewController alloc] init];
////    pVC.view.backgroundColor = [UIColor systemYellowColor];
////    applicationItem.controller = [[FMNavBaseViewController alloc] initWithRootViewController:pVC];
//
//    applicationItem.controller = [[FMNavBaseViewController alloc] initWithRootViewController:[[InquiryListViewController alloc] init]];
//    [items addObject:applicationItem];
    
    
    
    TUITabBarItem *setItem = [[TUITabBarItem alloc] init];
    setItem.title = @"我的";
    setItem.selectedImage = [UIImage imageNamed:@"mine_selected"];
    setItem.normalImage = [UIImage imageNamed:@"mine_normal"];
    
//    UIViewController * sVC = [[UIViewController alloc] init];
//    sVC.view.backgroundColor = [UIColor systemPinkColor];
//    setItem.controller = [[FMNavBaseViewController alloc] initWithRootViewController:sVC];
    
    setItem.controller = [[FMNavBaseViewController alloc] initWithRootViewController:[[MineViewController alloc] init]];
    [items addObject:setItem];
 
    
    //tab bar items
    NSMutableArray *controllers = [NSMutableArray array];
    for (TUITabBarItem *item in items) {
        item.controller.tabBarItem = [[UITabBarItem alloc] initWithTitle:item.title image:[item.normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [item.controller.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -2)];
        
        
//        if (@available(iOS 10.0, *)) {
//
//        }else{
//            //普通状态文字颜色
//            [item.controller.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} forState:UIControlStateNormal];
//
//            //选中状态文字颜色
//            [item.controller.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[Configuration mainColor]} forState:UIControlStateSelected];
//        }
        
        [controllers addObject:item.controller];
    }
    self.viewControllers = controllers;
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
