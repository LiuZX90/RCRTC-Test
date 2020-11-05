//
//  AppDelegate.m
//  DoctorClient
//
//  Created by ZengPengYuan on 2019/4/22.
//  Copyright © 2019 ZengPengYuan. All rights reserved.
//

#import "AppDelegate.h"

//#import "LaunchViewController.h"
#import <IQKeyboardManager.h>

#import <UserNotifications/UserNotifications.h>
//#import "WechatManager.h"
//#import "UserManager.h"
#import <RongCallKit/RongCallKit.h>
#import <PushKit/PushKit.h>
//#import "RongCloudUserInfoRequest.h"

//#import "TestRequest.h"

//#import "PrescriptionListViewController.h"
//#import "LoginViewController.h"
//#import "InquiryMessageListModel.h"
//#import "RCChatVC.h"
//#import "MinePageVC.h"

#import "PXDTabbarController.h"
//#import "PXDCrashManager.h"

@interface AppDelegate () <RCCallReceiveDelegate, UNUserNotificationCenterDelegate>

//#if TARGET_IPHONE_SIMULATOR
@property (nonatomic, strong) PXDTabbarController *tab;
//#else
//@property (nonatomic, strong) ByronTabBarController *tab;
//#endif

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoLoginResultNotification:) name:AutoLoginNotification object:nil];
    
//    [self AddNotification];

//    [WechatManager registerApp];
    
    // 是否允许通知
//    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
//        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//        center.delegate = self;
//        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
//        }];
//    }
//    [application registerForRemoteNotifications];
    
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager]; // 获取类库的单例变量
    keyboardManager.enable = YES; // 控制整个功能是否启用
    keyboardManager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
    keyboardManager.shouldToolbarUsesTextFieldTintColor = YES; // 控制键盘上的工具条文字颜色是否用户自定义
    keyboardManager.toolbarManageBehaviour = IQAutoToolbarBySubviews; // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
    keyboardManager.enableAutoToolbar = YES; // 控制是否显示键盘上的工具条
    keyboardManager.placeholderFont = [UIFont boldSystemFontOfSize:17]; // 设置占位文字的字体
    keyboardManager.keyboardDistanceFromTextField = 10.0f; // 输入框距离键盘的距离

//    YTKNetworkConfig *networkConfig = [YTKNetworkConfig sharedConfig];
//    networkConfig.baseUrl = kRootUrl;
    
    //服务端返回格式问题，后端返回的结果不是"application/json"，afn 的 jsonResponseSerializer 是不认的。这里做临时处理
    YTKNetworkAgent *agent = [YTKNetworkAgent sharedAgent];
    //[agent setValue:[NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json",@"text/html", nil] forKeyPath:@"jsonResponseSerializer.acceptableContentTypes"];
    [agent setValue:[NSSet setWithArray:@[@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain",@"application/atom+xml",@"application/xml",@"text/xml", @"image/*"]] forKeyPath:@"jsonResponseSerializer.acceptableContentTypes"];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
//    LaunchViewController *launch = [[LaunchViewController alloc] init];
    _tab = [[PXDTabbarController alloc] init];
    
    self.window.rootViewController = _tab;
    [self.window makeKeyAndVisible];

    // 获取版本号
//    [self requestAppVersion];
    
//    [PXDCrashManager registerExceptionHandler];
    //如果有崩溃日志 上传并删除本地日志
//    if ([PXDCrashManager crashLog].length > 0) {
//        NSLog(@"崩溃日志");
//        NSLog(@"log : %@", [[NSString alloc] initWithData:[PXDCrashManager crashLog] encoding:NSUTF8StringEncoding]);
//        [PXDCrashManager clearCrashLog];
//    }
    
//    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Verbose];
//
//    [self redirectNSlogToDocumentFolder];
    
    ///var/mobile/Containers/Data/Application/10631F67-2DE3-42E9-9EBC-59BA975EB4AD/Documents/rc1103085117.log
    
    return YES;
}





//编译运行, 复现后把沙盒中的/Documents/rc******.log 日志 发一下吧
//********************************************************

- (void)redirectNSlogToDocumentFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    NSString *documentDirectory = [paths objectAtIndex:0];



    NSDate *currentDate = [NSDate date];

    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];

    [dateformatter setDateFormat:@"MMddHHmmss"];

    NSString *formattedDate = [dateformatter stringFromDate:currentDate];



    NSString *fileName = [NSString stringWithFormat:@"rc%@.log", formattedDate];

    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];



    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);

    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);

}

/**
远程通知 - 注册设备Token

@param application application
@param deviceToken 设备Token
*/

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
//    [application registerForRemoteNotifications];
    
    NSLog(@"%s", __func__);
    
}
// 注册 APNs 失败接口（可选）
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"注册 APNs 失败接口（可选） : %@", error);
}

/**
 远程通知 - 接收消息
 
 @param application application
 @param userInfo userInfo
 @param completionHandler completionHandler
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"远程通知 - 接收消息 = %@",userInfo);
    // 点击通知栏在此响应
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - UNUserNotificationCenterDelegate
// iOS 10收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willPresentNotification" object:nil];
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {//应用处于前台时的远程推送接受
        NSLog(@"应用处于前台时的远程推送接受 userInfo = %@",userInfo);
        
    } else {//应用处于前台时的本地推送接受
        NSLog(@"应用处于前台时的本地推送接受 userInfo = %@",userInfo);
        completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);//
    }
}
// 通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 点击事件远程通知: %@", userInfo);
    }
    else {
        NSLog(@"iOS10 点击事件本地通知: %@",userInfo);
    }
    completionHandler();  // 系统要求执行这个方法
}

#pragma mark - UIApplicationDelegate
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"url.host = %@",url.host);
    if([url.host isEqualToString:@"oauth"] ||
       [url.host isEqualToString:@"pay"] ||
       [url.host isEqualToString:@"resendContextReqByScheme"]) {
//        return [WechatManager handleOpenURL:url];
    }
    return YES;
}
-(BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return YES;
}


#pragma mark - RCCallReceiveDelegate
//- (void)didReceiveCall:(RCCallSession *)callSession {
//    [[[TestRequest alloc] initWithTestToken:[NSString stringWithFormat:@"%s", __func__]] start];
//
//    RCCallSingleCallViewController *singleAudio = [[RCCallSingleCallViewController alloc] initWithIncomingCall:callSession];
//    [self.window.rootViewController presentViewController:singleAudio animated:YES completion:nil];
//}

/*!
 接收到通话呼入的远程通知的回调
 
 @param callId        呼入通话的唯一值
 @param inviterUserId 通话邀请者的UserId
 @param mediaType     通话的媒体类型
 @param userIdList    被邀请者的UserId列表
 @param userDict      远程推送包含的其他扩展信息
 */
//- (void)didReceiveCallRemoteNotification:(NSString *)callId
//                           inviterUserId:(NSString *)inviterUserId
//                               mediaType:(RCCallMediaType)mediaType
//                              userIdList:(NSArray *)userIdList
//                                userDict:(NSDictionary *)userDict {
//    NSDictionary *dict = @{@"callID" : callId ? : @"",
//                           @"inviterUserId" : inviterUserId ? : @"",
//                           @"userIdList" : userIdList ? : @"",
//                           @"userDict" : userDict ? : @""
//                           };
//    NSLog(@"接收到通话呼入的远程通知的回调 = %@",dict);
//    [[[TestRequest alloc] initWithTestToken:[NSString stringWithFormat:@"%s", __func__]] start];
//    [[[TestRequest alloc] initWithTestToken:dict.mj_JSONString] start];
//    [[[RongCloudUserInfoRequest alloc] initWithUserID:inviterUserId] startWithCompletionBlockWithSuccess:^(RongCloudUserInfoRequest * _Nonnull request) {
//        if (request.requestSuccess) {
//            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//            content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"%@%@", request.userName, @"邀请你进行通话..."] arguments:nil];;
//            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
//            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"VoIP_PUSH" content:content trigger:trigger];
//            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//            }];
//        }
//    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//
//    }];
//}

//- (void)didCancelCallRemoteNotification:(NSString *)callId
//                          inviterUserId:(NSString *)inviterUserId
//                              mediaType:(RCCallMediaType)mediaType
//                             userIdList:(NSArray *)userIdList {
//
//    [[[TestRequest alloc] initWithTestToken:[NSString stringWithFormat:@"%s", __func__]] start];
//
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    [center removeDeliveredNotificationsWithIdentifiers:@[@"VoIP_PUSH"]];
//}


#pragma mark - notification
- (void)autoLoginResultNotification:(NSNotification *)notification {
    self.window.rootViewController = nil;
    
//    #if TARGET_IPHONE_SIMULATOR
        _tab = [[PXDTabbarController alloc] init];
       
       self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
       self.window.rootViewController = _tab;
       [self.window makeKeyAndVisible];
//    #else
//        NSArray *vcs = @[@"HomeViewController",@"MessageListViewController",@"InquiryListViewController",@"MineViewController"];
//        NSArray *titles = @[@"首页",@"消息",@"问诊单",@"我的"];
//        NSArray *images = @[@"home_normal",@"message_normal",@"order_normal",@"mine_normal"];
//        NSArray *selectImages = @[@"home_selected",@"message_selected",@"order_selected",@"mine_selected"];
//
//        _tab = [[ByronTabBarController alloc]init];
//        _tab.tabBar.backgroundImage = [UIImage pureColorImages:[UIColor whiteColor] size:CGSizeMake(kScreen_W, kTabBar_H)];
//        [_tab SetupTabBarControllersWithVcs:vcs titles:titles images:images selectImages:selectImages];
//
//        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        self.window.rootViewController = _tab;
//        [self.window makeKeyAndVisible];
//    #endif
    

}
#pragma mark - setter && getter
- (UIWindow *)window {
    if (_window) return _window;
    CGRect bounds = UIScreen.mainScreen.bounds;
    _window = [[UIWindow alloc] initWithFrame:bounds];
    return _window;
}


@end
