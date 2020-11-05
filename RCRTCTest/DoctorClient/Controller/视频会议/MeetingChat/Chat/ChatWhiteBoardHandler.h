//
//  ChatWhiteBoardHandler.h
//  SealRTC
//
//  Created by LiuLinhong on 2019/05/06.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhiteSDK.h"
#import "WhiteUtils.h"
#import "Whiteboard.h"
#import "RongWhiteBoardMessage.h"

#define kWhiteBoardMessageKey @"rongRTCWhite"
#define kWhiteBoardUUID @"uuid"
#define kWhiteBoardRoomToken @"roomToken"

NS_ASSUME_NONNULL_BEGIN

@interface ChatWhiteBoardHandler : NSObject

@property (nonatomic, strong) WhiteBoardView *whiteBoardView;
@property (nonatomic, strong) NSString *roomUuid, *roomToken;

- (instancetype)initWithViewController:(UIViewController *)vc;
- (void)leaveRoom;
- (void)deleteRoom;
- (void)openWhiteBoardRoom;
- (void)closeWhiteBoardRoom;
- (void)switchWhiteMemberState:(WhiteApplianceNameKey)key;
- (void)setStrokeColorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b;
- (void)setStrokeWidth:(CGFloat)w;
- (void)cleanCurrentWhiteBoard;
- (void)createNewWhiteBoard;
- (void)deleteWhiteBoard;
- (void)setOperationEnable:(BOOL)enable;
- (void)rotateWhiteBoardView;

@end

NS_ASSUME_NONNULL_END
