//
//  STParticipantsTableViewController.m
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "STParticipantsTableViewController.h"
#import "STParticipantsTableViewHeader.h"
#import <RongRTCLib/RongRTCLib.h>
#import "STParticipantsInfo.h"
#import "STSetRoomInfoMessage.h"
#import "STDeleteRoomInfoMessage.h"
#import "STKickOffInfoMessage.h"
#import "LoginManager.h"

extern NSNotificationName const STParticipantsInfoDidRemove;
extern NSNotificationName const STParticipantsInfoDidAdd;
extern NSNotificationName const STParticipantsInfoDidUpdate;

@interface STParticipantsTableViewController ()

@property (nonatomic, strong) STParticipantsTableViewHeader* tableHeader;
@property (nonatomic, strong) RCRTCRoom* room;
@property (nonatomic, weak) NSMutableArray<STParticipantsInfo*>* dataSource;
@property (nonatomic, strong) NSMutableArray* removeUserButtonArray;
@property (nonatomic, strong) NSMutableSet<NSString*>* userSet;
@property (nonatomic, strong) NSMutableSet<NSString*>* currentAllUser;
@end

@implementation STParticipantsTableViewController

- (instancetype)initWithRoom:(RCRTCRoom*)room
           participantsInfos:(NSMutableArray<STParticipantsInfo*>*) array {
    if (self  = [super initWithStyle:UITableViewStylePlain]) {
        self.room = room;
        for (RCRTCRemoteUser* user  in room.remoteUsers) {
            if (user.userId.length > 0) {
                [self.currentAllUser addObject:user.userId];
            }
        }
        if (room.localUser.userId.length > 0) {
            [self.currentAllUser addObject:room.localUser.userId];
        }
        self.dataSource  = array;
        NSArray* source = [array copy];
        NSMutableIndexSet* mutableSet = [[NSMutableIndexSet alloc] init];
        for (int i = 0; i < source.count; i++) {
            STParticipantsInfo* info  = source[i];
            if (![self.currentAllUser containsObject:info.userId]) {
                [mutableSet addIndex:i];
            }
        }
        [self.dataSource removeObjectsAtIndexes:[mutableSet copy]];
        
        for (STParticipantsInfo* info in source) {
            if (info.userId.length > 0) {
                [self.userSet addObject:info.userId];
            }
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSNotificationCenter* defalutCenter = [NSNotificationCenter defaultCenter];
    [defalutCenter addObserver:self
                      selector:@selector(participantsInfoDidChange:)
                          name:STParticipantsInfoDidRemove
                        object:nil];
    [defalutCenter addObserver:self
                      selector:@selector(participantsInfoDidChange:)
                          name:STParticipantsInfoDidAdd
                        object:nil];
    [defalutCenter addObserver:self
                      selector:@selector(participantsInfoDidChange:)
                          name:STParticipantsInfoDidUpdate
                        object:nil];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.room getRoomAttributes:nil completion:^(BOOL isSuccess, RCRTCCode desc, NSDictionary * _Nullable attr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [attr enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
                NSDictionary* dicInfo = [NSJSONSerialization JSONObjectWithData:[obj dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                STParticipantsInfo* info = [[STParticipantsInfo alloc] initWithDictionary:dicInfo];
                if (![self.userSet containsObject:key]) {
                    if (info.userId.length > 0 && [self.currentAllUser containsObject:key]) {
                        [self.dataSource addObject:info];
                        [self.userSet addObject:info.userId];
                    }
                }
            }];
            
            [self.dataSource sortUsingComparator:^NSComparisonResult(STParticipantsInfo*  _Nonnull obj1, STParticipantsInfo*  _Nonnull obj2) {
                if (obj1.joinTime < obj2.joinTime) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedDescending;
                }
            }];
            
            NSInteger masterIndex = 0;
            for (NSInteger i = 0; i < [self.dataSource count]; i++) {
                STParticipantsInfo *tmpInfo = self.dataSource[i];
                if (tmpInfo.master) {
                    masterIndex = i;
                    break;
                }
            }
            
            if (masterIndex && [self.dataSource count] > masterIndex) {
                STParticipantsInfo *masterInfo = self.dataSource[masterIndex];
                [self.dataSource removeObjectAtIndex:masterIndex];
                [self.dataSource insertObject:masterInfo atIndex:0];
            }
            
            [self.tableView reloadData];
            [self updateParticipantsCount];
        });
    }];
#pragma clang diagnostic pop
    [self updateParticipantsCount];
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height / 2);
    //[self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"ParticipantsCell"];
    self.tableView.tableHeaderView = self.tableHeader;
    self.tableView.backgroundColor = [UIColor clearColor];
    //bself.tableView.tableFooterView = [UIView new];
    [self.tableHeader.closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    UIVisualEffectView* effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    effectView.alpha = 0.8;
    self.tableView.backgroundView = effectView;
}

- (void)updateParticipantsCount {
    NSString* cout_fmt = @"在线人数 %@ 人";
    self.tableHeader.tipsLabel.text = [NSString stringWithFormat:cout_fmt,@(self.dataSource.count)];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParticipantsCell"];
    NSInteger row = indexPath.row;
    STParticipantsInfo *info = self.dataSource[row];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ParticipantsCell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", info.userName, stringForJoinMode(info.joinMode)]; ;
    cell.detailTextLabel.text = info.master ? @"管理员" : @"";
    
    return cell;
}

#pragma mark - Table view deletate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || !kLoginManager.isMaster) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!kLoginManager.isMaster) {
        return nil;
    }
    if (indexPath.row == 0 ) {
        return nil;
    }
    UITableViewRowAction* deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"移除用户" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        STParticipantsInfo *info = self.dataSource[indexPath.row];
        NSDictionary *msgDict = @{@"userId" : info.userId};
         STKickOffInfoMessage *message = [[STKickOffInfoMessage alloc] initKickOffMessage:msgDict];
         [self.room sendMessage:message success:^(long messageId) {
         } error:^(RCErrorCode nErrorCode, long messageId) {
         }];
    }];
    return @[deleteAction];
}

#pragma mark - notification selector
- (void)participantsInfoDidChange:(NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([notification.name isEqualToString:STParticipantsInfoDidRemove]
            || [notification.name isEqualToString:STParticipantsInfoDidUpdate]) {
            [self.tableView reloadData];;
        } else if ([notification.name isEqualToString:STParticipantsInfoDidAdd]) {
            NSIndexPath *indexPath = notification.object;
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        [self updateParticipantsCount];
    });
}

#pragma mark - Target Action
- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getters
- (STParticipantsTableViewHeader*)tableHeader {
    if (!_tableHeader) {
        _tableHeader = [[STParticipantsTableViewHeader alloc] initWithFrame:(CGRect){0,0,200,44}];
    }
    return _tableHeader;
}

- (NSMutableSet<NSString*>*)userSet {
    if (!_userSet) {
        _userSet = [[NSMutableSet alloc] initWithCapacity:20];
    }
    return _userSet;
}

- (NSMutableSet<NSString*>*)currentAllUser {
    if (!_currentAllUser) {
        _currentAllUser = [[NSMutableSet alloc] initWithCapacity:20];
    }
    return _currentAllUser;
}

- (NSMutableArray *)removeUserButtonArray {
    if (!_removeUserButtonArray) {
        _removeUserButtonArray = [[NSMutableArray alloc] initWithCapacity:20];
    }
    return _removeUserButtonArray;
}

NSString* stringForJoinMode(STJoinMode mode) {
    NSString* result;
    switch (mode) {
        case STJoinModeAV:
            result = @"视频模式";
            break;
        case STJoinModeAudioOnly:
            result = @"音频模式";
            break;
        case STJoinModeObserver:
            result = @"旁听者模式";
            break;
        default:
            break;
    }
    return result;
}

@end
