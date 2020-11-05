//
//  SettingTableViewDelegateSourceImpl.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "SettingTableViewDelegateSourceImpl.h"
#import "SettingViewController.h"
#import "PrivateCloudSettingViewController.h"
#import "RTActiveWheel.h"
#import <RongIMLib/RongIMLib.h>

@interface SettingTableViewDelegateSourceImpl ()

@property (nonatomic, weak) SettingViewController *settingViewController;

@end


@implementation SettingTableViewDelegateSourceImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.settingViewController = (SettingViewController *) vc;
    }
    return self;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.settingViewController.indexPath = indexPath;
    NSInteger section = [indexPath section];
    [self.settingViewController.settingViewBuilder.resolutionRatioPickview remove];
    NSString *cellName = [self.settingViewController.settingTableViewCellArray objectAtIndex:section];
    if (cellName) {
        if ([cellName isEqualToString:@"setting_private_environment"]) {
            PrivateCloudSettingViewController *pvc = [[PrivateCloudSettingViewController alloc]init];
            [self.settingViewController.navigationController pushViewController:pvc animated:YES];
        } else if ([cellName isEqualToString:@"setting_resolution"]) {
            [self.settingViewController.settingViewBuilder.resolutionRatioPickview show];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *cellName = [self.settingViewController.settingTableViewCellArray objectAtIndex:section];
    if (cellName) {
        if ([cellName isEqualToString:@"setting_crypto"]) {
            return 2;
        }
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settingViewController.sectionNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSString *identifer = [NSString stringWithFormat:@"Cell%zd%zd", section, row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    NSString *cellName = [self.settingViewController.settingTableViewCellArray objectAtIndex:section];
    if (cellName) {
        if ([cellName isEqualToString:@"setting_private_environment"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"连接设置";
        } else if ([cellName isEqualToString:@"setting_resolution"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSString stringWithFormat:@"%@", self.settingViewController.resolutionRatioArray[kLoginManager.resolutionRatioIndex]];
        } else if ([cellName isEqualToString:@"setting_water_mark"]) {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.waterMarkSwitch];
            cell.textLabel.text = @"后置摄像头水印";
        } else if ([cellName isEqualToString:@"setting_tiny_stream"]) {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.tinyStreamSwitch];
            cell.textLabel.text = @"大小流";
        } else if ([cellName isEqualToString:@"setting_auto_test"]) {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.autoTestSwitch];
            cell.textLabel.text = @"自动化测试";
        } else if ([cellName isEqualToString:@"setting_userid"]) {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.userIDTextField];
        } else if ([cellName isEqualToString:@"setting_audio_scenario"]) {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.audioScenarioSwitch];
            cell.textLabel.text = @"音频场景";
        } else if ([cellName isEqualToString:@"setting_back_camera_mirror"]) {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.videoMirrorSwitch];
            cell.textLabel.text = @"远端镜像开启";
        } else if ([cellName isEqualToString:@"setting_crypto"]) {
            switch (row) {
                case 0:
                {
                    [cell.contentView addSubview:self.settingViewController.settingViewBuilder.audioCryptoSwitch];
                    cell.textLabel.text = @"开启音频加解密";
                }
                    break;
                case 1:
                {
                    [cell.contentView addSubview:self.settingViewController.settingViewBuilder.videoCryptoSwitch];
                    cell.textLabel.text = @"开启视频加解密";
                }
                    break;
                default:
                    break;
            }
        }
    }
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *cellName = [self.settingViewController.settingTableViewCellArray objectAtIndex:section];
    if (cellName) {
        if ([cellName isEqualToString:@"setting_private_environment"]) {
            return @"连接设置";
        } else if ([cellName isEqualToString:@"setting_resolution"]) {
            return @"分辨率";
        } else if ([cellName isEqualToString:@"setting_water_mark"]) {
            return @"本地视频";
        } else if ([cellName isEqualToString:@"setting_tiny_stream"]) {
            return @"大小流";
        } else if ([cellName isEqualToString:@"setting_auto_test"]) {
            return @"自动化测试";
        } else if ([cellName isEqualToString:@"setting_userid"]) {
            return @"用户ID (长按可复制到剪切板)";
        } else if ([cellName isEqualToString:@"setting_audio_scenario"]) {
            return @"音频场景";
        } else if ([cellName isEqualToString:@"setting_back_camera_mirror"]) {
            return @"远端镜像开启";
        } else if ([cellName isEqualToString:@"setting_crypto"]) {
            return @"自定义加解密";
        }
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 30.f : 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

@end

