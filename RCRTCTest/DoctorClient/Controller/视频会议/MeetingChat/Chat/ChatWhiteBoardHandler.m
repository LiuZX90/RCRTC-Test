//
//  ChatWhiteBoardHandler.m
//  SealRTC
//
//  Created by LiuLinhong on 2019/05/06.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ChatWhiteBoardHandler.h"
#import "ChatViewController.h"
#import "CommonUtility.h"
#import "ColorSelectionCollectionViewController.h"

#define kSceneKey @"/rtc"

@interface ChatWhiteBoardHandler () <WhiteRoomCallbackDelegate, WhiteCommonCallbackDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, weak) ChatViewController *chatViewController;
@property (nonatomic, strong) WhiteSDK *whiteSDK;
@property (nonatomic, strong) WhiteRoom *whiteRoom;
@property (nonatomic, strong) WhiteMemberState *memberState;
@property (nonatomic, assign) BOOL isJoined, isOperation;
@property (nonatomic, strong) NSMutableArray *sceneArray, *buttonArray;
@property (nonatomic, strong) NSString *currentSceneDir;
@property (nonatomic, strong) UIButton *closeButton, *lastButton, *nextButton;
@property (nonatomic, strong) ColorSelectionCollectionViewController *popColorController;

@end


@implementation ChatWhiteBoardHandler

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self) {
        self.chatViewController = (ChatViewController *) vc;
        self.memberState = [[WhiteMemberState alloc] init];
        self.isJoined = NO;
        self.isOperation = YES;
    }
    
    return self;
}

#pragma mark - 打开白板
- (void)openWhiteBoardRoom
{
    if (self.isJoined) {
        [self addSubWhiteBoardView];
    }
    else {
        if (!self.roomUuid || self.roomUuid.length == 0 || !self.roomToken || self.roomToken.length == 0) {
            [self createWhiteBoardRoom];
            return;
        }
        else if (self.roomUuid && self.roomToken) {
            [self joinRoomWithToken:self.roomToken];
        }
    }
}

#pragma mark - 关闭白板
- (void)closeWhiteBoardRoom
{
    [self.chatViewController setIsHiddenStatusBar:NO];
    kLoginManager.isWhiteBoardOpen = NO;
    [self.whiteBoardView removeFromSuperview];
}

#pragma mark - 切换道具
- (void)switchWhiteMemberState:(WhiteApplianceNameKey)key
{
    self.memberState.currentApplianceName = key;
    [self.whiteRoom setMemberState:self.memberState];
}

#pragma mark - 设置颜色
- (void)setStrokeColorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b
{
    [self.memberState setStrokeColor:@[@(r), @(g), @(b)]];
}

#pragma mark - 设置粗细
- (void)setStrokeWidth:(CGFloat)w
{
    [self.memberState setStrokeWidth:@(w)];
}

#pragma mark - 清空页面
- (void)cleanCurrentWhiteBoard
{
    [self.whiteRoom cleanScene:NO];
}

#pragma mark - 创建页面
- (void)createNewWhiteBoard
{
    NSString *pageName = [NSString stringWithFormat:@"%@%@", kLoginManager.userID, [CommonUtility getRandomString]];
    WhitePptPage *pptPage = [[WhitePptPage alloc] init];
    WhiteScene *scene = [[WhiteScene alloc] initWithName:pageName ppt:pptPage];
    [self.sceneArray addObject:scene];
    
    NSInteger pageCount = [self.sceneArray count];
    //插入新页面的 API，现在支持传入 ppt 参数（可选），所以插入PPT和插入新页面的 API，合并成了一个。
    [self.whiteRoom putScenes:kSceneKey scenes:@[scene] index:pageCount];
    
    NSString *newScenePath = [self whiteBoardPageName:pageName];
    [self.whiteRoom setScenePath:newScenePath];
    self.currentSceneDir = newScenePath;
    DLog(@"self.currentSceneDir: %@", self.currentSceneDir);
}

#pragma mark - 删除页面
- (void)deleteWhiteBoard
{
//    [self.whiteRoom removeScenes:kSceneKey];
//    return;
//
    if ([self.sceneArray count] <= 1) {
        [self cleanCurrentWhiteBoard];
        return;
    }
    else {
        NSInteger delIndex = 0;
        for (NSInteger i = 0; i < [self.sceneArray count]; i++) {
            WhiteScene *sc = (WhiteScene *)self.sceneArray[i];
            NSString *s = [self whiteBoardPageName:sc.name];
            if ([s isEqualToString:self.currentSceneDir]) {
                delIndex = i;
                break;
            }
        }
        
        [self.sceneArray removeObjectAtIndex:delIndex];
        WhiteScene *sc;
        if (delIndex < [self.sceneArray count]) {
            sc = (WhiteScene *)self.sceneArray[delIndex];
        }
        else {
            sc = (WhiteScene *)[self.sceneArray lastObject];
        }
        
        [self.whiteRoom removeScenes:self.currentSceneDir];
        self.currentSceneDir = [self whiteBoardPageName:sc.name];
    }
}

#pragma mark - 上一页
- (void)lastWhiteBoardPage
{
    if (![self.sceneArray count]) {
        DLog(@"last page return");
        return;
    }
    else if ([self.sceneArray count] == 1) {
        WhiteScene *sc = (WhiteScene *)[self.sceneArray firstObject];
        self.currentSceneDir = [self whiteBoardPageName:sc.name];
    }
    else {
        NSString *tmpScName = self.currentSceneDir;
        for (WhiteScene *sc in self.sceneArray) {
            NSString *s = [self whiteBoardPageName:sc.name];
            if ([s isEqualToString:self.currentSceneDir]) {
                self.currentSceneDir = tmpScName;
                break;
            }
            else {
                tmpScName = s;
            }
        }
    }
    DLog(@"last page: %@", self.currentSceneDir);
    [self.whiteRoom setScenePath:self.currentSceneDir];
}

#pragma mark - 下一页
- (void)nextWhiteBoardPage
{
    if (![self.sceneArray count]) {
        DLog(@"next page return");
        return;
    }
    else if ([self.sceneArray count] == 1) {
        WhiteScene *sc = (WhiteScene *)[self.sceneArray firstObject];
        self.currentSceneDir = [self whiteBoardPageName:sc.name];
    }
    else {
        NSInteger matchIndex = 0;
        for (NSInteger i = 0; i < [self.sceneArray count]; i++) {
            WhiteScene *sc = (WhiteScene *)self.sceneArray[i];
            NSString *s = [self whiteBoardPageName:sc.name];
            if ([s isEqualToString:self.currentSceneDir]) {
                matchIndex = i + 1;
                break;
            }
        }
        
        WhiteScene *tsc;
        if (matchIndex < [self.sceneArray count]) {
            tsc = (WhiteScene *)self.sceneArray[matchIndex];
        }
        else {
            tsc = (WhiteScene *)[self.sceneArray lastObject];
        }
        self.currentSceneDir = [self whiteBoardPageName:tsc.name];
    }
    DLog(@"next page: %@", self.currentSceneDir);
    [self.whiteRoom setScenePath:self.currentSceneDir];
}

#pragma mark - 创建 & 加入房间
- (void)createWhiteBoardRoom
{
    [WhiteUtils createRoomWithResult:^(BOOL success, id response, NSError *error) {
        if (success) {
            self.roomToken = response[@"msg"][@"roomToken"];
            self.roomUuid = response[@"msg"][@"room"][@"uuid"];
            if (self.roomUuid && self.roomToken) {
                [self joinRoomWithToken:self.roomToken];
                
                //发送白板消息
                NSDictionary *dic = @{kWhiteBoardUUID:self.roomUuid,
                                      kWhiteBoardRoomToken:self.roomToken};
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                RongWhiteBoardMessage *message = [[RongWhiteBoardMessage alloc] initWhiteBoardMessage:dic];
                [self.chatViewController.room setRoomAttributeValue:jsonString forKey:kWhiteBoardMessageKey message:message completion:^(BOOL isSuccess, RCRTCCode desc) {
                    DLog(@"setRoomAttributeValue: %hhd  RCRTCCode: %zd", isSuccess, desc);
                }];
            }
            else {
                DLog(@"创建房间失败，room uuid:%@ roomToken:%@", self.roomUuid, self.roomToken);
                [self showAlert];
            }
        }
        else {
            DLog(@"创建房间失败，error: %@", [error localizedDescription]);
            [self showAlert];
        }
    }];
}

#pragma mark - 加入房间
- (void)joinRoomWithToken:(NSString *)roomToken
{
    [self addSubWhiteBoardView];
    //UserId 需要保证每个用户唯一，否则同一个 userId，最先加入的人，会被踢出房间。
    WhiteMemberInformation *memberInfo = [[WhiteMemberInformation alloc] initWithUserId:kLoginManager.userID name:kLoginManager.username avatar:@"https://white-pan.oss-cn-shanghai.aliyuncs.com/40/image/mask.jpg"];
    WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:self.roomUuid roomToken:roomToken memberInfo:memberInfo];
    
    [self.whiteSDK joinRoomWithConfig:roomConfig callbacks:self completionHandler:^(BOOL success, WhiteRoom * _Nonnull room, NSError * _Nonnull error) {
        if (success) {
            DLog(@"加入房间成功");
            self.whiteRoom = room;
            self.isJoined = YES;
            [self.whiteRoom disableOperations:!self.isOperation];
            [self.whiteRoom setViewMode:WhiteViewModeFreedom];
            [self.whiteRoom zoomChange:0.3f];
            [self setStrokeColorWithRed:255.f green:0.f blue:0.f];
            [self switchWhiteMemberState:AppliancePencil];
            
            [self.whiteRoom getSceneStateWithResult:^(WhiteSceneState * _Nonnull state) {
                if (state.scenes) {
                    for (WhiteScene *tmpScene in state.scenes) {
                        if (![tmpScene.name isEqualToString:@"init"]) {
                            [self.sceneArray addObject:tmpScene];
                        }
                    }
                }
                
                DLog(@"state.scenePath: %@", state.scenePath);
                if ([state.scenePath isEqualToString:@"/init"]) {
                    [self createNewWhiteBoard];
                }
                else {
                    self.currentSceneDir = state.scenePath;
                }
            }];
        }
        else {
            DLog(@"加入房间失败，room uuid:%@ roomToken:%@", self.roomUuid, self.roomToken);
            [self showAlert];
        }
    }];
}

#pragma mark - 退出房间
- (void)leaveRoom
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isJoined = NO;
        [self.whiteSDK setCommonCallbackDelegate:nil];
        [self.whiteRoom disconnect:^{
        }];
    });
}

#pragma mark - 删除房间
- (void)deleteRoom
{
    if (self.roomUuid) {
        [WhiteUtils deleteRoomTokenWithUuid:self.roomUuid];
    }
}

#pragma mark - 设置操作可用(默认)/禁用
- (void)setOperationEnable:(BOOL)enable
{
    self.isOperation = enable;
}

- (void)addSubWhiteBoardView
{
    [self.chatViewController setIsHiddenStatusBar:YES];
    [self.chatViewController.view addSubview:self.whiteBoardView];
    [self.chatViewController.view bringSubviewToFront:self.whiteBoardView];
}

#pragma mark - WhiteRoomCallbackDelegate
- (void)firePhaseChanged:(WhiteRoomPhase)phase
{
    DLog(@"%zd", phase);
//    if (self.isJoined) {
//        [self.whiteSDK joinRoomWithUuid:self.roomUuid roomToken:self.roomToken completionHandler:^(BOOL success, WhiteRoom *room, NSError *error) {
//            if (success) {
//                DLog(@"joinRoomWithUuid Success");
//            } else {
//                DLog(@"joinRoomWithUuid Failed: %@", [error localizedDescription]);
//            }
//        }];
//    }
}

- (void)fireRoomStateChanged:(WhiteRoomState *)magixPhase
{
    DLog(@"%@", [magixPhase jsonString]);
    if (magixPhase.sceneState.scenes) {
        self.currentSceneDir = magixPhase.sceneState.scenePath;
        
        for (WhiteScene *tmpScene in magixPhase.sceneState.scenes) {
            DLog(@"tmpScene name: %@", tmpScene.name);
            if (![tmpScene.name isEqualToString:@"init"]) {
                BOOL isContain = NO;
                for (WhiteScene *sc in self.sceneArray) {
                    if ([sc.name isEqualToString:tmpScene.name]) {
                        isContain = YES;
                    }
                }
                if (!isContain) {
                    [self.sceneArray addObject:tmpScene];
                }
            }
        }
    }
}

- (void)fireBeingAbleToCommitChange:(BOOL)isAbleToCommit
{
    DLog(@"%d", isAbleToCommit);
}

- (void)fireDisconnectWithError:(NSString *)error
{
    DLog(@"%@", error);
}

- (void)fireKickedWithReason:(NSString *)reason
{
    DLog(@"%@", reason);
}

- (void)fireCatchErrorWhenAppendFrame:(NSUInteger)userId error:(NSString *)error
{
    DLog(@"%zd %@", userId, error);
}

- (void)fireMagixEvent:(WhiteEvent *)event
{
    DLog(@"fireMagixEvent: %@", [event jsonString]);
}

#pragma mark - WhiteRoomCallbackDelegate
- (void)throwError:(NSError *)error
{
    DLog(@"throwError: %@", error.userInfo);
}

- (NSString *)urlInterrupter:(NSString *)url
{
    return @"https://white-pan-cn.oss-cn-hangzhou.aliyuncs.com/124/image/image.png";
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES;//点击蒙版popover消失， 默认YES
}

#pragma mark - Getter
- (WhiteBoardView *)whiteBoardView
{
    if (!_whiteBoardView) {
        _whiteBoardView = [[WhiteBoardView alloc] init];
        _whiteBoardView.frame = CGRectMake(0, 0, MainscreenWidth, MainscreenHeight);
        
        //关闭
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeButton.frame = CGRectMake(_whiteBoardView.frame.size.width-10-36, 10, 36, 36);
        self.closeButton.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.3f];
        self.closeButton.tintColor = [UIColor blackColor];
        self.closeButton.layer.masksToBounds = YES;
        self.closeButton.layer.cornerRadius = self.closeButton.frame.size.width / 2;
        [CommonUtility setButtonImage:self.closeButton imageName:@"chat_white_close"];
        [self.closeButton addTarget:self action:@selector(closeWhiteBoardRoom) forControlEvents:UIControlEventTouchUpInside];
        [_whiteBoardView addSubview:self.closeButton];
        
        if (self.isOperation) {
            //上一页
            self.lastButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.lastButton.frame = CGRectMake(10, _whiteBoardView.frame.size.height/2 - 18, 36, 36);
            self.lastButton.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.3f];
            self.lastButton.tintColor = [UIColor blackColor];
            self.lastButton.layer.masksToBounds = YES;
            self.lastButton.layer.cornerRadius = self.lastButton.frame.size.width / 2;
            [CommonUtility setButtonImage:self.lastButton imageName:@"chat_white_last"];
            [self.lastButton addTarget:self action:@selector(lastWhiteBoardPage) forControlEvents:UIControlEventTouchUpInside];
            [_whiteBoardView addSubview:self.lastButton];
            
            //下一页
            self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.nextButton.frame = CGRectMake(_whiteBoardView.frame.size.width-10-36, _whiteBoardView.frame.size.height/2 - 18, 36, 36);
            self.nextButton.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.3f];
            self.nextButton.tintColor = [UIColor blackColor];
            self.nextButton.layer.masksToBounds = YES;
            self.nextButton.layer.cornerRadius = self.nextButton.frame.size.width / 2;
            [CommonUtility setButtonImage:self.nextButton imageName:@"chat_white_next"];
            [self.nextButton addTarget:self action:@selector(nextWhiteBoardPage) forControlEvents:UIControlEventTouchUpInside];
            [_whiteBoardView addSubview:self.nextButton];
            
            //工具栏
            [self createMenuItemButtons];
        }
    }
    return _whiteBoardView;
}

- (WhiteSDK *)whiteSDK
{
    if (!_whiteSDK) {
        WhiteSdkConfiguration *config = [WhiteSdkConfiguration defaultConfig];

        //如果不需要拦截图片API，则不需要开启，页面内容较为复杂时，可能会有性能问题
        config.enableInterrupterAPI = YES;
        config.debug = YES;
        //打开用户头像显示信息
        config.userCursor = NO;
        //SDK 只提供数据信息，不实现用户头像
        //config.customCursor = YES;

        _whiteSDK = [[WhiteSDK alloc] initWithWhiteBoardView:self.whiteBoardView config:config commonCallbackDelegate:self];
    }

    return _whiteSDK;
}

- (WhiteMemberState *)memberState
{
    if (!_memberState) {
        _memberState = [[WhiteMemberState alloc] init];
    }
    return _memberState;
}

- (NSMutableArray *)sceneArray
{
    if (!_sceneArray) {
        _sceneArray = [NSMutableArray array];
    }
    return _sceneArray;
}

- (ColorSelectionCollectionViewController *)popColorController
{
    if (!_popColorController) {
        _popColorController = [[ColorSelectionCollectionViewController alloc] init];
    }
    return _popColorController;
}

#pragma mark - MenuItem
- (void)createMenuItemButtons
{
    self.buttonArray = [NSMutableArray array];
    CGFloat iconWidth = 46.f;
    CGFloat buttonInterval = (MainscreenWidth - 20 - iconWidth *6) / 5.f;
    
    for (NSInteger i = 0; i < 6; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(10 + i*iconWidth + i*buttonInterval, self.whiteBoardView.frame.size.height-54-14, iconWidth, 54);
        button.layer.cornerRadius = 4.f;
        button.backgroundColor = [UIColor clearColor];
        button.tintColor = [UIColor blackColor];
        button.imageEdgeInsets = UIEdgeInsetsMake(-16, 4, 0, 0);
        button.titleEdgeInsets = UIEdgeInsetsMake(iconWidth-10, -iconWidth+8, 0, 0);
        button.tag = i;
        [button addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.whiteBoardView addSubview:button];
        [self.buttonArray addObject:button];
        
        NSString *imageName, *buttonName;
        switch (button.tag)
        {
            case 0: //画笔
                buttonName = @"画笔";
                imageName = @"chat_white_pencil";
                break;
            case 1: //文字
                buttonName = @"文字";
                imageName = @"chat_white_text";
                break;
            case 2: //橡皮擦
                buttonName = @"橡皮擦";
                imageName = @"chat_white_eraser";
                break;
            case 3: //清空
                buttonName = @"清空";
                imageName = @"chat_white_clean";
                break;
            case 4: //新建
                buttonName = @"新建";
                imageName = @"chat_white_create";
                break;
            case 5: //删除
                buttonName = @"删除";
                imageName = @"chat_white_delete";
                break;
            default:
                break;
        }
        
        [CommonUtility setButtonImage:button imageName:imageName];
        [button setTitle:buttonName forState:UIControlStateNormal];
        [button setTitle:buttonName forState:UIControlStateHighlighted];
    }
}

- (void)menuButtonPressed:(UIButton *)button
{
    switch (button.tag) {
        case 0: //画笔
        {
            [self switchWhiteMemberState:AppliancePencil];
            
            self.popColorController.view.frame = CGRectMake(0, 0, 12+44*3+8, 12+44*3+8);
            self.popColorController.modalPresentationStyle = UIModalPresentationPopover;
            
            __weak typeof(self) weakSelf = self;
            //        _popColorController.videModeBlock = ^(RongRTCVideoMode mode,NSIndexPath *indexPath) {
            //            //
            //            weakSelf.selectedIndexPath = indexPath;
            //            [weakSelf.rongRTCEngine setVideoMode:mode];
            //        };
            

            self.popColorController.selectColorBlock = ^(CGFloat r, CGFloat g, CGFloat b) {
                [weakSelf setStrokeColorWithRed:r green:g blue:b];
                [weakSelf switchWhiteMemberState:AppliancePencil];
            };
            //        _popColorController.selectedIndexPath = _selectedIndexPath;
            
            UIPopoverPresentationController *popover = [_popColorController popoverPresentationController];
            popover.delegate = self;
            self.popColorController.preferredContentSize = self.popColorController.view.frame.size;//设置浮窗的宽高
            popover.permittedArrowDirections = UIPopoverArrowDirectionDown;//设置箭头位置
            popover.sourceView = (UIButton *)[self.buttonArray firstObject];//设置目标视图
            popover.sourceRect = CGRectMake(26, -2, 0, 0);//弹出视图显示位置
            popover.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4f];//设置弹窗背景颜色(效果图里红色区域)
            [self.chatViewController.navigationController presentViewController:self.popColorController animated:YES completion:nil];
        }
            break;
        case 1: //文字
            [self switchWhiteMemberState:ApplianceText]; break;
        case 2: //橡皮擦
            [self switchWhiteMemberState:ApplianceEraser]; break;
        case 3: //清空
            [self cleanCurrentWhiteBoard]; break;
        case 4: //新建
            [self createNewWhiteBoard]; break;
        case 5: //删除
            [self deleteWhiteBoard]; break;
        default:
            break;
    }
}

#pragma mark - Private
- (void)rotateWhiteBoardView
{
    _whiteBoardView.frame = CGRectMake(0, 0, MainscreenWidth, MainscreenHeight);
    self.closeButton.frame = CGRectMake(_whiteBoardView.frame.size.width-10-36, 10, 36, 36);
    self.lastButton.frame = CGRectMake(10, _whiteBoardView.frame.size.height/2 - 18, 36, 36);
    self.nextButton.frame = CGRectMake(_whiteBoardView.frame.size.width-10-36, _whiteBoardView.frame.size.height/2 - 18, 36, 36);
    
    CGFloat iconWidth = 46.f;
    CGFloat buttonInterval = (MainscreenWidth - 20 - iconWidth *6) / 5.f;
    for (NSInteger i = 0; i < [self.buttonArray count]; i++)
    {
        UIButton *button = (UIButton *)self.buttonArray[i];
        button.frame = CGRectMake(10 + i*iconWidth + i*buttonInterval, self.whiteBoardView.frame.size.height-54-14, iconWidth, 54);
    }
}

- (void)showAlert
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"白板服务错误，请稍后重试" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self closeWhiteBoardRoom];
        }];
        [alert addAction:action];
        [self.chatViewController presentViewController:alert animated:YES completion:^{
        }];
    });
}

- (NSString *)whiteBoardPageName:(NSString *)name
{
    return [NSString stringWithFormat:@"%@/%@", kSceneKey, name];
}

@end
