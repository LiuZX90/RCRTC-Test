//
//  ColorSelectionCollectionViewController.m
//  SealRTC
//
//  Created by LiuLinhong on 2019/05/15.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ColorSelectionCollectionViewController.h"

@interface ColorSelectionCollectionViewController ()

@end

@implementation ColorSelectionCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (instancetype)init
{
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.footerReferenceSize = CGSizeMake(44*3, 4);
        //[flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        // 每一个网格的尺寸
        flowLayout.itemSize = CGSizeMake(44, 44);
        // 每一行之间的间距
        flowLayout.minimumLineSpacing = 4;
        flowLayout.minimumInteritemSpacing = 4;
        // 上下左右的间距
        //flowLayout.sectionInset = UIEdgeInsetsMake(10, 20, 40, 80);
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(20, 20, 30*3, 30*3) collectionViewLayout:flowLayout];
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
        self.collectionView.scrollEnabled = NO;
        self.collectionView.contentInset = UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0);
        self.collectionView.backgroundColor = [UIColor clearColor];
        //self.collectionView.layer.shadowOffset = CGSizeMake(0, 2);
        //self.collectionView.layer.shadowOpacity = 0.60;
        
        self.view.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
//    cell.frame = CGRectMake(0, 0, 44, 44);
    NSInteger section = [indexPath section];
    NSInteger item = [indexPath item];
    switch (section) {
        case 0:{
            switch (item) {
                case 0:
                    cell.backgroundColor = [UIColor colorWithRed:255.f/255.f green:0.f/255.f blue:0.f/255.f alpha:1.f];
                    break;
                case 1:
                    cell.backgroundColor = [UIColor colorWithRed:255.f/255.f green:165.f/255.f blue:0.f/255.f alpha:1.f];
                    break;
                case 2:
                    cell.backgroundColor = [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:0.f/255.f alpha:1.f];
                    break;
                default:
                    break;
            }
        }
            break;
        case 1: {
            switch (item) {
                case 0:
                    cell.backgroundColor = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:255.f/255.f alpha:1.f];
                    break;
                case 1:
                    cell.backgroundColor = [UIColor colorWithRed:0.f/255.f green:255.f/255.f blue:255.f/255.f alpha:1.f];
                    break;
                case 2:
                    cell.backgroundColor = [UIColor colorWithRed:0.f/255.f green:128.f/255.f blue:0.f/255.f alpha:1.f];
                    break;
                default:
                    break;
            }
        }
            break;
        case 2: {
            switch (item) {
                case 0:
                    cell.backgroundColor = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:1.f];
                    break;
                case 1:
                    cell.backgroundColor = [UIColor colorWithRed:128.f/255.f green:0.f/255.f blue:128.f/255.f alpha:1.f];
                    break;
                case 2:
                    cell.backgroundColor = [UIColor colorWithRed:128.f/255.f green:128.f/255.f blue:128.f/255.f alpha:1.f];
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSInteger item = [indexPath item];
    CGFloat r = 255.f, g = 0.f, b = 0.f;
    switch (section) {
        case 0:{
            switch (item) {
                case 0: {
                    r = 255.f;
                    g = 0.f;
                    b = 0.f;
                }
                    break;
                case 1: {
                    r = 255.f;
                    g = 165.f;
                    b = 0.f;
                }
                    break;
                case 2: {
                    r = 255.f;
                    g = 255.f;
                    b = 0.f;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1: {
            switch (item) {
                case 0: {
                    r = 0.f;
                    g = 0.f;
                    b = 255.f;
                }
                    break;
                case 1: {
                    r = 0.f;
                    g = 255.f;
                    b = 255.f;
                }
                    break;
                case 2: {
                    r = 0.f;
                    g = 128.f;
                    b = 0.f;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2: {
            switch (item) {
                case 0: {
                    r = 0.f;
                    g = 0.f;
                    b = 0.f;
                }
                    break;
                case 1: {
                    r = 128.f;
                    g = 0.f;
                    b = 128.f;
                }
                    break;
                case 2: {
                    r = 128.f;
                    g = 128.f;
                    b = 128.f;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    if (self.selectColorBlock) {
        self.selectColorBlock(r, g, b);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
