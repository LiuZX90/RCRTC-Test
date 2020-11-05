//
//  PXDBaseTableViewController.h
//  DoctorClient
//
//  Created by company_mac on 2020/9/28.
//  Copyright © 2020 小度. All rights reserved.
//

#import "PXDBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PXDBaseTableViewController : PXDBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
