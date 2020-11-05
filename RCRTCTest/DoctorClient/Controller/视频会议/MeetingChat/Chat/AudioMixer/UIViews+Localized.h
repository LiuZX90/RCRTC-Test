//
//  UILabel+Localized.h
//  SealRTC
//
//  Created by birney on 2020/3/18.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (Localized)

- (void)setLocalizedText:(NSString*)key;

@end

@interface UINavigationItem (localized)

- (void)setLocalizedTitle:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
