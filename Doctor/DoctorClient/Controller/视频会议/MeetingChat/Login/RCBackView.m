//
//  RCBackView.m
//  SealRTC
//
//  Created by 孙承秀 on 2019/8/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCBackView.h"
#import "RCSelectView.h"
typedef void (^CallBack)(RCSelectModel *);
@implementation RCBackView{
    RCSelectView *_selectView;
    CallBack _callBack;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.9];
        RCSelectView *veiw = [[RCSelectView alloc] initWithFrame:CGRectMake(30, (frame.size.height - (frame.size.width - 60)) / 2, frame.size.width - 60, frame.size.width - 60)];
        veiw.userInteractionEnabled = YES;
        veiw.layer.cornerRadius = 4;
        veiw.clipsToBounds = YES;
        _selectView = veiw;
        [self addSubview:veiw];
    }
    return self;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch");
    if (_callBack) {
        _callBack(nil);
    }
}
-(void)reload:(NSArray *)arr{
    _selectView.datas = arr.mutableCopy;
}
- (void)setCallBack:(void (^)(RCSelectModel *))callBack{
    _callBack = callBack;
    [_selectView setCallBack:callBack];
}

@end
