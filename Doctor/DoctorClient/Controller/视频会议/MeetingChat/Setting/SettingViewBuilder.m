//
//  SettingViewBuilder.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "SettingViewBuilder.h"
#import "SettingViewController.h"

@interface SettingViewBuilder ()

@property (nonatomic, weak) SettingViewController *settingViewController;

@end

@implementation SettingViewBuilder

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.settingViewController = (SettingViewController *) vc;
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.gpuSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(MainscreenWidth -6-60, 6, 60, 28)];
    [self.gpuSwitch addTarget:self.settingViewController action:@selector(gpuSwitchAction) forControlEvents:UIControlEventValueChanged];
    [self.gpuSwitch setOn:kLoginManager.isGPUFilter];
    
    self.tinyStreamSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(MainscreenWidth -6-60, 6, 60, 28)];
    [self.tinyStreamSwitch addTarget:self.settingViewController action:@selector(tinyStreamSwitchAction) forControlEvents:UIControlEventValueChanged];
    [self.tinyStreamSwitch setOn:kLoginManager.isTinyStream];
    
    self.autoTestSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(MainscreenWidth -6-60, 6, 60, 28)];
    [self.autoTestSwitch addTarget:self.settingViewController action:@selector(autoTestAction) forControlEvents:UIControlEventValueChanged];
    [self.autoTestSwitch setOn:kLoginManager.isAutoTest];
    
    self.waterMarkSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(MainscreenWidth -6-60, 6, 60, 28)];
    [self.waterMarkSwitch addTarget:self.settingViewController action:@selector(waterMarkAction) forControlEvents:UIControlEventValueChanged];
    [self.waterMarkSwitch setOn:kLoginManager.isWaterMark];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MainscreenWidth, MainscreenHeight) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self.settingViewController.settingTableViewDelegateSourceImpl;
    self.tableView.delegate = self.settingViewController.settingTableViewDelegateSourceImpl;
    [self.settingViewController.view addSubview:self.tableView];
    
    self.resolutionRatioPickview = [[ZHPickView alloc] initPickviewWithPlistName:Key_ResolutionRatio isHaveNavControler:NO];
    self.resolutionRatioPickview.delegate = self.settingViewController.settingPickViewDelegateImpl;
    [self.resolutionRatioPickview setSelectedPickerItem:kLoginManager.resolutionRatioIndex];
    
    self.userIDTextField = [[UITextField alloc]initWithFrame:CGRectMake(16, 0, MainscreenWidth -16, 44)];
    self.userIDTextField.font = [UIFont systemFontOfSize:18];
    self.userIDTextField.textAlignment = NSTextAlignmentLeft;
    self.userIDTextField.returnKeyType = UIReturnKeyDone;
    self.userIDTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.userIDTextField.delegate = self.settingViewController.settingTextFieldDelegateImpl;
    
    UILongPressGestureRecognizer *userIDTextFieldLongPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self.settingViewController action:@selector(longPressedGestureAction:)];
    [self.userIDTextField addGestureRecognizer:userIDTextFieldLongPress];
    
    //音频
    self.audioScenarioSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(MainscreenWidth -6-60, 6, 60, 28)];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.audioScenarioSwitch addTarget:self.settingViewController action:@selector(audioScenarioAction) forControlEvents:UIControlEventValueChanged];
#pragma clang diagnostic pop
    [self.audioScenarioSwitch setOn:kLoginManager.isAudioScenarioMusic];
    
    
    //视频镜像
    self.videoMirrorSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(MainscreenWidth -6-60, 6, 60, 28)];
    [self.videoMirrorSwitch addTarget:self.settingViewController action:@selector(setVideoMirror) forControlEvents:UIControlEventValueChanged];
    [self.videoMirrorSwitch setOn:kLoginManager.isVideoMirror];
    
    //音频加解密
    self.audioCryptoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(MainscreenWidth -6-60, 6, 60, 28)];
    [self.audioCryptoSwitch addTarget:self.settingViewController action:@selector(setAudioCryptoSwitch) forControlEvents:UIControlEventValueChanged];
    [self.audioCryptoSwitch setOn:kLoginManager.isOpenAudioCrypto];
    
    //视频加解密
    self.videoCryptoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(MainscreenWidth -6-60, 6, 60, 28)];
    [self.videoCryptoSwitch addTarget:self.settingViewController action:@selector(setVideoCryptoSwitch) forControlEvents:UIControlEventValueChanged];
    [self.videoCryptoSwitch setOn:kLoginManager.isOpenVideoCrypto];
    
}

@end
