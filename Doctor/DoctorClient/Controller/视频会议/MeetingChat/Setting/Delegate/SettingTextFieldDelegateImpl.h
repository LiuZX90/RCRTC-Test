//
//  SettingTextFieldDelegateImpl.h
//  SealRTC
//
//  Created by LiuLinhong on 2020/02/10.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingTextFieldDelegateImpl : NSObject <UITextFieldDelegate>

- (instancetype)initWithViewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
