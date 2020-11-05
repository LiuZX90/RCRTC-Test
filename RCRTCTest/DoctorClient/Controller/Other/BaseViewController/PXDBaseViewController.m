//
//  PXDBaseViewController.m
//  DoctorClient
//
//  Created by company_mac on 2020/9/28.
//  Copyright © 2020 ZengPengYuan. All rights reserved.
//

#import "PXDBaseViewController.h"

@interface PXDBaseViewController ()

@end

@implementation PXDBaseViewController

- (UIScrollView *)scroll{
    if (nil == _scroll) {
        _scroll = [[UIScrollView alloc] init];
    }
    return  _scroll;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self view] setBackgroundColor:[UIColor whiteColor]];
}

-(void)reloadData{}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
