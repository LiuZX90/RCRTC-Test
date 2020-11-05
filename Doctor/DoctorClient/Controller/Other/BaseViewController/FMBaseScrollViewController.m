//
//  FMBaseScrollViewController.m
//  FMChat
//
//  Created by PAN on 2020/8/19.
//  Copyright © 2020 zj. All rights reserved.
//

#import "FMBaseScrollViewController.h"
//#import <Masonry/Masonry.h>

@interface FMBaseScrollViewController ()<UIScrollViewDelegate>

@property(nonatomic,strong) UIScrollView * mainScrollView;

@end

@implementation FMBaseScrollViewController

//懒加载实例化mainScrollview
-(UIScrollView *)mainScrollView{
    
    if(_mainScrollView == nil){ //判断是否已经有实例,如果没有
        _mainScrollView = [[UIScrollView alloc]init];//创建实例
        _mainScrollView.frame = self.view.bounds;
        _mainScrollView.backgroundColor = [UIColor clearColor];
        _mainScrollView.alwaysBounceVertical = YES;//默认上下滚动
        _mainScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _mainScrollView.scrollsToTop = YES;
        _mainScrollView.delegate = self;
    }
    return _mainScrollView;
}

- (UIView *)contentView{
    
    if (_contentView == nil) {
        _contentView = [[UIView alloc]init];
//        _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;//**这句话很重要

    }

    return _contentView;
    
}

- (void)dealloc
{
    NSLog(@"FMBaseScrollViewController is dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.edgesForExtendedLayout = UIRectEdgeTop;
}

- (void)setupUI{
    
    [self.view addSubview:self.mainScrollView];
    [_mainScrollView addSubview:self.contentView];
    

//    _mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;

    [self setuiLayout];
}

- (void)setuiLayout{
    
    __weak typeof(self) weakSelf = self;
    [_mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.view);
    }];
    
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.mainScrollView);
        make.width.equalTo(weakSelf.mainScrollView);
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
