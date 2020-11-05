//
//  RCSelectView.m
//  SealRTC
//
//  Created by 孙承秀 on 2019/8/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCSelectView.h"
typedef void (^CallBack)(RCSelectModel *);
@implementation RCSelectView{
    CallBack _callBack;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.dataSource = self;
        self.datas = [NSMutableArray array];
    }
    return self;
}
-(void)setDatas:(NSMutableArray *)datas{
    _datas = datas;
    [self reloadData];
}
- (void)setCallBack:(void (^)(RCSelectModel *))callBack{
    _callBack = callBack;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"selectCell"];
    }
    RCSelectModel *model = self.datas[indexPath.row];
    [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
    cell.textLabel.text = [NSString stringWithFormat:@"roomId:%@ roomName:%@",model.rooomId,model.roomName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"mcuUrl:%@",model.liveUrl];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"select");
    if (_callBack) {
        _callBack(self.datas[indexPath.row]);
    }
}
@end
