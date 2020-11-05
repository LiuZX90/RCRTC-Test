//
//  UICollectionView+RongRTCBgView.h
//  RongCloud
//
//  Created by Rongcloud on 2018/1/24.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

@protocol CollectionViewTouchesDelegate <NSObject>

- (void)didTouchedBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event withBlock:(void  (^)(void))block;

@end


@interface UICollectionView (RongRTCBgView)

@property (nonatomic, strong) ChatViewController  *chatVC;

@end
