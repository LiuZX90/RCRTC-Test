//
//  UILabel+Localized.m
//  SealRTC
//
//  Created by birney on 2020/3/18.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "UIViews+Localized.h"


@implementation UILabel (Localized)

- (void)setLocalizedText:(NSString*)key {
    self.text = NSLocalizedString(key, nil);
}

@end

@implementation UINavigationItem (Localized)

- (void)setLocalizedTitle:(NSString*)key {
    self.title = NSLocalizedString(key, nil);
}

@end
