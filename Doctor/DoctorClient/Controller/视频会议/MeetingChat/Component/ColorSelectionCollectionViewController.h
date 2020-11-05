//
//  ColorSelectionCollectionViewController.h
//  SealRTC
//
//  Created by LiuLinhong on 2019/05/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^SelectColorBlock)(CGFloat r, CGFloat g, CGFloat b);

@interface ColorSelectionCollectionViewController : UICollectionViewController

@property (nonatomic, copy) SelectColorBlock selectColorBlock;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

NS_ASSUME_NONNULL_END
