//
//  SettingPickViewDelegateImpl.h
//  Rongcloud
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHPickView.h"

@interface SettingPickViewDelegateImpl : NSObject <ZHPickViewDelegate>

- (instancetype)initWithViewController:(UIViewController *)vc;

@end
