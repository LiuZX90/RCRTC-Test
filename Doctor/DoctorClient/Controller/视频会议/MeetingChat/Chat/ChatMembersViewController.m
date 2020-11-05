//
//  ChatMembersViewController.m
//  SealRTC
//
//  Created by jfdreamyang on 2019/4/23.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ChatMembersViewController.h"
#import "ChatMemberCell.h"

@interface ChatMembersViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@end

@implementation ChatMembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.title = [NSString stringWithFormat:@"在线成员（%@）",@(self.currentRoom.remoteUsers.count + 1)];
    [self.view addSubview:self.tableView];
 
    [self.tableView registerNib:[UINib nibWithNibName:@"ChatMemberCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ChatMemberCell"];
    
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currentRoom.remoteUsers.count + 1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatMemberCell *cell = (ChatMemberCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatMemberCell"];
    return cell;
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
