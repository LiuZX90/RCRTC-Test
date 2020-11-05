//
//  SettingPickViewDelegateImpl.m
//  Rongcloud
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "SettingPickViewDelegateImpl.h"
#import "SettingViewController.h"


@interface SettingPickViewDelegateImpl ()

@property (nonatomic, weak) SettingViewController *settingViewController;

@end


@implementation SettingPickViewDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.settingViewController = (SettingViewController *) vc;
    }
    return self;
}

#pragma mark - ZhpickVIewDelegate
- (void)toolbarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString selectedRow:(NSInteger)selectedRow
{
    NSInteger section = self.settingViewController.indexPath.section;
    switch (section)
    {
#ifdef IS_PRIVATE_ENVIRONMENT
        case 1:
#else
        case 0:
#endif
        {
            if (kLoginManager.resolutionRatioIndex != selectedRow)
            {
                kLoginManager.resolutionRatioIndex = selectedRow;

                //max code rate
                NSDictionary *codeRateDictionary = self.settingViewController.codeRateArray[kLoginManager.resolutionRatioIndex];
                //NSInteger min = [codeRateDictionary[Key_Min] integerValue];
                NSInteger max = [codeRateDictionary[Key_Max] integerValue];
                NSInteger defaultValue = [codeRateDictionary[Key_Default] integerValue];
                NSInteger step = [codeRateDictionary[Key_Step] integerValue];

                NSMutableArray *muArray = [NSMutableArray array];
                for (NSInteger temp = 0; temp <= max; temp += step)
                    [muArray addObject:[NSString stringWithFormat:@"%zd", temp]];

                NSInteger defaultIndex = [muArray indexOfObject:[NSString stringWithFormat:@"%zd", defaultValue]];
                kLoginManager.maxCodeRateIndex = defaultIndex;

                //min code rate
                NSMutableArray *minArray = [NSMutableArray array];
                for (NSInteger tmp = 0; tmp <= max; tmp += step)
                    [minArray addObject:[NSString stringWithFormat:@"%zd", tmp]];

                NSInteger minCodeRateDefaultValue = [codeRateDictionary[Key_Min] integerValue];
                kLoginManager.minCodeRateIndex = [minArray indexOfObject:[NSString stringWithFormat:@"%zd", minCodeRateDefaultValue]];
            }
        }
            break;
        default:
            break;
    }
    
    [self.settingViewController.settingViewBuilder.tableView reloadData];
}

- (void)toolbarCancelBtnHaveClick:(ZHPickView *)pickView
{
    NSInteger section = self.settingViewController.indexPath.section;
    switch (section)
    {
        case 0:
            [self.settingViewController.settingViewBuilder.resolutionRatioPickview setSelectedPickerItem:kLoginManager.resolutionRatioIndex];
            break;
        default:
            break;
    }
}

@end
