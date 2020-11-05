//
//  UIScrollView+Responder.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/3/17.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "UIScrollView+Responder.h"


@implementation UIScrollView (Responder)
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isMemberOfClass:[UIScrollView class]]) {
        [[self nextResponder] touchesBegan:touches withEvent:event];

    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesEnded:touches withEvent:event];
}
@end
