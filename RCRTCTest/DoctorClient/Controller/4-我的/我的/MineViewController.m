//
//  MineViewController.m
//  DoctorClient
//
//  Created by ZengPengYuan on 2019/4/22.
//  Copyright © 2019 ZengPengYuan. All rights reserved.
//

#import "MineViewController.h"

//#import "MineHeaderCell.h"
//#import "MineTabCell.h"
//
//#import "UserDataRequest.h"
//#import "RongCloudRefreshUserRequest.h"
//#import "SetInquiryPriceRequest.h"
//
//#import "UserManager.h"
//
//// vc
//#import "LoginViewController.h"
//#import "PersonalInforViewController.h"
//#import "InviteFriendsVC.h"
//#import "IncomeViewController.h"
//#import "PrescriptionListViewController.h"
//#import "EvaluationViewController.h"
//#import "SettingsViewController.h"
//#import "FeedbackViewController.h"
//#import "PresTemplateVC.h"
//#import "MinePageVC.h"


@interface MineViewController () <UITableViewDelegate, UITableViewDataSource, YTKRequestDelegate>

//@property (nonatomic, strong) UserDataRequest *infoRequest;
//@property (nonatomic, strong) SetInquiryPriceRequest *setInquiryPriceRequest;

@property (nonatomic, strong) UIView *view_1;

@property (nonatomic, strong) UITableView *table;

@property (nonatomic, strong) NSMutableArray *m_array;
//@property (nonatomic, strong) DoctorInfoModel *doctorInfoModel;

@end

@implementation MineViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBlueColor];
    
    self.title = @"我的";
}


@end
