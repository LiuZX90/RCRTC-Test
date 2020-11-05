//
//  PrivateCloudSettingViewController.m
//  SealRTC
//
//  Created by jfdreamyang on 2019/8/22.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "PrivateCloudSettingViewController.h"
#import "PrivateSettingCell.h"
#import "LoginManager.h"

@interface PrivateCloudSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSArray *placeholders;
@property (nonatomic,strong)NSArray *dataSource;
@end

@implementation PrivateCloudSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"环境设置";
    
    self.placeholders = @[@"应用的 AppKey",@"应用的 App Secret",@"http(s)://cn.xxx.com 或 IP + 端口 地址",@"http(s)://cn.xxx.com 或 IP + 端口 地址",@"http(s)://cn.xxx.com 或 IP + 端口 地址",
        @"http(s)://cn.xxx.com or IP + port address"];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PrivateSettingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PrivateSettingCell"];
    if (!kLoginManager.privateMediaServer) {
        kLoginManager.privateMediaServer = @"";
    }
    if (kLoginManager.isPrivateEnvironment) {
        self.dataSource = @[kLoginManager.privateAppKey,kLoginManager.privateAppSecret,kLoginManager.privateNavi,kLoginManager.privateIMServer,kLoginManager.privateMediaServer];
    }

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    NSArray <PrivateSettingCell *>*cells = self.tableView.visibleCells;
    
    NSString *appKey = cells[0].textField.text;
    NSString *appSecret = cells[1].textField.text;
    NSString *naviServer = cells[2].textField.text;
    NSString *serverApi = cells[3].textField.text;
    NSString *mediaServer = cells[4].textField.text;
    if (!mediaServer) {
        mediaServer = @"";
    }
    if (appKey.length > 5 && appSecret.length > 5 && naviServer.length > 5 && serverApi.length > 5) {
        kLoginManager.isPrivateEnvironment = YES;
        kLoginManager.privateAppKey = appKey;
        kLoginManager.privateNavi = naviServer;
        kLoginManager.privateAppSecret = appSecret;
        kLoginManager.privateIMServer = serverApi;
        kLoginManager.privateMediaServer = mediaServer;
    }
    
    kLoginManager.keyToken = @"";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 30.f : 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PrivateSettingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PrivateSettingCell"];
    cell.textField.placeholder = self.placeholders[indexPath.section];
    if (self.dataSource) {
        cell.textField.text = self.dataSource[indexPath.section];
    }
    return cell;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"AppKey";
        case 1:
            return @"AppSecret";
        case 2:
            return @"私有环境 NavServer 地址";
        case 3:
            return @"私有环境 Server API 地址";
        case 4:
            return @"私有环境 MediaServer 地址（可选）";
        default:
            break;
    }
    return @"";
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
