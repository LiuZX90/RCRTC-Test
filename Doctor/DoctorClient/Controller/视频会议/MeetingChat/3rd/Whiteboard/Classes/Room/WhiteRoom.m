//
//  WhiteRoom.m
//  dsBridge
//
//  Created by leavesster on 2018/8/11.
//

#import "WhiteRoom.h"
#import "WhiteRoom+Private.h"
#import "WhiteBoardView.h"
#import "WhiteConsts.h"
#import "WhiteDisplayer+Private.h"

@interface WhiteRoom()
@property (nonatomic, assign, readwrite) NSTimeInterval delay;
@property (nonatomic, assign, readwrite) WhiteRoomPhase phase;
@property (nonatomic, strong, readwrite) WhiteRoomState *state;
@property (nonatomic, assign, readwrite) BOOL disconnectedBySelf;

@end

#import "WhiteRoomCallbacks+Private.h"

@implementation WhiteRoom

- (instancetype)initWithUuid:(NSString *)uuid bridge:(WhiteBoardView *)bridge state:(WhiteRoomState *)roomState
{
    self = [super initWithUuid:uuid bridge:bridge];
    if (self) {
        bridge.room = self;
        _state = roomState;
        _globalState = [[WhiteGlobalState alloc] init];
        _uuid = uuid;
    }
    return self;
}

- (instancetype)initWithUuid:(NSString *)uuid bridge:(WhiteBoardView *)bridge;
{
    WhiteRoomState *roomState = [[WhiteRoomState alloc] init];
    self = [self initWithUuid:uuid bridge:bridge state:roomState];
    return self;
}

#pragma mark - Property

- (void)setGlobalState:(WhiteGlobalState *)modifyState
{
    [self.bridge callHandler:@"room.setGlobalState" arguments:@[modifyState]];
    NSDictionary *update = [modifyState jsonDict];
//    [_globalState yy_modelSetWithJSON:update];
    [_globalState modelSetWithJSON:update];
}

- (void)setMemberState:(WhiteMemberState *)modifyState
{
    [self.bridge callHandler:@"room.setMemberState" arguments:@[modifyState]];
    NSDictionary *update = [modifyState jsonDict];
//    [_memberState yy_modelSetWithJSON:update];
    [_memberState modelSetWithJSON:update];
}

- (NSArray<WhiteRoomMember *>*)roomMembers
{
    return self.state.roomMembers;
}

- (WhiteBroadcastState *)broadcastState
{
    return self.state.broadcastState;
}

- (CGFloat)scale
{
    return [self.state.zoomScale floatValue];
}

- (WhiteSceneState *)sceneState
{
    return self.state.sceneState;
}

#pragma mark - Private
- (void)updatePhase:(WhiteRoomPhase)phase
{
    _phase = phase;
}

- (void)updateRoomState:(WhiteRoomState *)state {
//    [_state yy_modelSetWithJSON:[state yy_modelToJSONObject]];
    [_state modelSetWithJSON:[state modelToJSONObject]];
}

#pragma mark - Set Action
- (void)setViewMode:(WhiteViewMode)viewMode;
{
    NSString *viewModeString;
    switch (viewMode) {
        case WhiteViewModeFreedom:
            viewModeString = @"Freedom";
            break;
        case WhiteViewModeFollower:
            viewModeString = @"Follower";
            break;
        case WhiteViewModeBroadcaster:
            viewModeString = @"Broadcaster";
            break;
        default:
            viewModeString = @"Freedom";
            break;
    }
    [self.bridge callHandler:@"room.setViewMode" arguments:@[viewModeString]];
}

#pragma mark - action API

- (void)disconnect:(void (^ _Nullable) (void))completeHandler
{
    self.disconnectedBySelf = YES;
    [self.bridge callHandler:@"room.disconnect" completionHandler:^(id  _Nullable value) {
        if (completeHandler) {
            completeHandler();
        }
    }];
}

- (void)disableCameraTransform:(BOOL)disableCameraTransform
{
    [self.bridge callHandler:@"room.disableCameraTransform" arguments:@[@(disableCameraTransform)]];
}

- (void)disableDeviceInputs:(BOOL)disable
{
    [self.bridge callHandler:@"room.disableDeviceInputs" arguments:@[@(disable)]];
}

- (void)disableOperations:(BOOL)readonly
{
    [self.bridge callHandler:@"room.disableOperations" arguments:@[@(readonly)]];
}

- (void)debugInfo:(void (^ _Nullable)(NSDictionary * _Nullable dict))completionHandler
{
    [self.bridge callHandler:@"room.state.debugInfo" completionHandler:^(id  _Nullable value) {
        if (completionHandler) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                completionHandler(value);
            }
        }
    }];
}

#pragma mark - PPT
- (void)pptNextStep
{
    [self.bridge callHandler:@"ppt.nextStep" arguments:nil];
}
- (void)pptPreviousStep
{
    [self.bridge callHandler:@"ppt.previousStep" arguments:nil];
}

#pragma mark - Scene API

- (void)putScenes:(NSString *)dir scenes:(NSArray<WhiteScene *> *)scenes index:(NSUInteger)index
{
    [self.bridge callHandler:@"room.putScenes" arguments:@[dir, scenes, @(index)]];
}

- (void)cleanScene:(BOOL)retainPPT
{
    [self.bridge callHandler:@"room.cleanScene" arguments:@[@(retainPPT)]];
}

- (void)setScenePath:(NSString *)path
{
    [self.bridge callHandler:@"room.setScenePath" arguments:@[path]];
}

- (void)setScenePath:(NSString *)dirOrPath completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler
{
    [self.bridge callHandler:@"room.setScenePath" arguments:@[dirOrPath] completionHandler:^(id  _Nullable value) {
        if (completionHandler) {
            NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSDictionary *error = dict[@"__error"];
            if (error) {
                NSString *desc = error[@"message"] ? : @"";
                NSString *description = error[@"jsStack"] ? : @"";
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: desc, NSDebugDescriptionErrorKey: description};
                completionHandler(NO, [NSError errorWithDomain:WhiteConstsErrorDomain code:-1000 userInfo:userInfo]);
            } else {
                completionHandler(YES, nil);
            }
        }
    }];
}

- (void)setSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler;
{
    [self.bridge callHandler:@"room.setSceneIndex" arguments:@[@(index)] completionHandler:^(id  _Nullable value) {
        if (completionHandler) {
            NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSDictionary *error = dict[@"__error"];
            if (error) {
                NSString *desc = error[@"message"] ? : @"";
                NSString *description = error[@"jsStack"] ? : @"";
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: desc, NSDebugDescriptionErrorKey: description};
                completionHandler(NO, [NSError errorWithDomain:WhiteConstsErrorDomain code:-1000 userInfo:userInfo]);
            } else {
                completionHandler(YES, nil);
            }
        }
    }];
}

- (void)setWritable:(BOOL)writable completionHandler:(void (^ _Nullable)(BOOL isWritable, NSError * _Nullable error))completionHandler;
{
    [self.bridge callHandler:@"room.setWritable" arguments:@[@(writable)] completionHandler:^(id  _Nullable value) {
        if (completionHandler) {
            NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSDictionary *error = dict[@"__error"];
            if (error) {
                NSString *desc = error[@"message"] ? : @"";
                NSString *description = error[@"jsStack"] ? : @"";
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: desc, NSDebugDescriptionErrorKey: description};
                completionHandler(NO, [NSError errorWithDomain:WhiteConstsErrorDomain code:-1000 userInfo:userInfo]);
            } else {
                BOOL isWritable = [dict[@"isWritable"] boolValue];
                self.writable = isWritable;
                self.observerId = @([dict[@"observerId"] longLongValue]);
                completionHandler(isWritable, nil);
            }
        }
    }];
}


- (void)removeScenes:(NSString *)dirOrPath
{
    [self.bridge callHandler:@"room.removeScenes" arguments:@[dirOrPath]];
}

- (void)moveScene:(NSString *)source target:(NSString *)target
{
    [self.bridge callHandler:@"room.moveScene" arguments:@[source, target]];
}

#pragma mark - Image API

- (void)insertImage:(WhiteImageInformation *)imageInfo;
{
    [self.bridge callHandler:@"room.insertImage" arguments:@[imageInfo]];
}

- (void)completeImageUploadWithUuid:(NSString *)uuid src:(NSString *)src;
{
    [self.bridge callHandler:@"room.completeImageUpload" arguments:@[uuid, src]];
}

- (void)insertImage:(WhiteImageInformation *)imageInfo src:(NSString *)src
{
    //虽然是异步，但也是按顺序发送的
    [self.bridge callHandler:@"room.insertImage" arguments:@[imageInfo] completionHandler:nil];
    [self.bridge callHandler:@"room.completeImageUpload" arguments:@[imageInfo.uuid, src]];
}

#pragma mark - 延时
- (void)setTimeDelay:(NSTimeInterval)delay
{
    [self.bridge callHandler:@"room.setTimeDelay" arguments:@[@(delay * WhiteConstsTimeUnitRatio)]];
    self.delay = delay;
}

#pragma mark - Custom Event

- (void)dispatchMagixEvent:(NSString *)eventName payload:(NSDictionary *)payload;
{
    NSDictionary *dict = @{@"eventName": eventName, @"payload": payload};
    [self.bridge callHandler:@"room.dispatchMagixEvent" arguments:@[dict]];
}

#pragma mark - Get State API

- (void)getMemberStateWithResult:(void (^) (WhiteMemberState *state))result
{
    [self.bridge callHandler:@"room.getMemberState" completionHandler:^(id  _Nullable value) {
        if (result) {
            WhiteMemberState *jsState = [WhiteMemberState modelWithJSON:value];
            result(jsState);
        }
    }];
}

- (void)getGlobalStateWithResult:(void (^) (WhiteGlobalState *state))result
{
    [self.bridge callHandler:@"room.getGlobalState" completionHandler:^(id  _Nullable value) {
        if (result) {
            WhiteGlobalState *jsState = [WhiteGlobalState modelWithJSON:value];
            result(jsState);
        }
    }];
}

- (void)getSceneStateWithResult:(void (^) (WhiteSceneState *state))result
{
    [self.bridge callHandler:@"room.getSceneState" completionHandler:^(id  _Nullable value) {
        if (result) {
            WhiteSceneState *jsState = [WhiteSceneState modelWithJSON:value];
            result(jsState);
        }
    }];
}

- (void)getRoomMembersWithResult:(void (^) (NSArray<WhiteRoomMember *> *roomMembers))result;
{
    [self.bridge callHandler:@"room.getRoomMembers" completionHandler:^(id  _Nullable value) {
        if (result && [value isKindOfClass:[NSString class]]) {
            NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *values = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[values count]];
            for (id v in values) {
                [array addObject:[WhiteRoomMember modelWithJSON:v]];
            }
            result(array);
        }
    }];
}

- (void)getRoomPhaseWithResult:(void (^) (WhiteRoomPhase phase))result
{
    [self.bridge callHandler:@"room.getRoomPhase" completionHandler:^(id  _Nullable value) {
        if (result && [value isKindOfClass:[NSString class]]) {
            WhiteRoomPhase phase = [WhiteRoomCallbacks convertRoomPhaseFromString:value];
            result(phase);
        }
    }];
}

- (void)getZoomScaleWithResult:(void (^) (CGFloat scale))result;
{
    [self.bridge callHandler:@"room.getZoomScale" completionHandler:^(id  _Nullable value) {
        if (result && [value isKindOfClass:[NSString class]]) {
            CGFloat scale = [value doubleValue];
            scale = roundf(scale * 100) / 100;
            result(scale);
        }
    }];
}

- (void)getRoomStateWithResult:(void (^) (WhiteRoomState *state))result
{
    [self.bridge callHandler:@"room.state.getRoomState" completionHandler:^(id  _Nullable value) {
        if (result) {
            WhiteRoomState *state = [WhiteRoomState modelWithJSON:value];
            result(state);
        }
    }];
}

- (void)getScenesWithResult:(void (^) (NSArray<WhiteScene *> *scenes))result
{
    [self.bridge callHandler:@"room.getScenes" completionHandler:^(id  _Nullable value) {
        if (result && [value isKindOfClass:[NSString class]]) {
            NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *values = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSMutableArray<WhiteScene *> *array = [NSMutableArray arrayWithCapacity:[values count]];
            for (id v in values) {
                [array addObject:[WhiteScene modelWithJSON:v]];
            }
            result(array);
        }
    }];
}

- (void)getBroadcastStateWithResult:(void (^) (WhiteBroadcastState *state))result
{
    [self.bridge callHandler:@"room.getBroadcastState" completionHandler:^(id  _Nullable value) {
        if (result) {
            WhiteBroadcastState *jsState = [WhiteBroadcastState modelWithJSON:value];
            result(jsState);
        }
    }];
}

@end


@implementation WhiteRoom (Deprecated)

- (void)setViewSizeWithWidth:(CGFloat)width height:(CGFloat)height;
{
    [self.bridge callHandler:@"room.refreshViewSize" arguments:@[]];
}

- (void)zoomChange:(CGFloat)scale
{
    WhiteCameraConfig *cameraConfig = [[WhiteCameraConfig alloc] init];
    cameraConfig.scale = @(scale);
    [self moveCamera:cameraConfig];
}

- (void)getPptImagesWithResult:(void (^) (NSArray <NSString *> *pptPages))result
{
    [self getScenesWithResult:^(NSArray<WhiteScene *> * _Nonnull scenes) {
        if (result) {
            NSMutableArray<NSString *> *pptPages = [NSMutableArray arrayWithCapacity:[scenes count]];
            for (WhiteScene *scene in scenes) {
                if (scene.ppt) {
                    [pptPages addObject:scene.ppt.src];
                } else {
                    [pptPages addObject:@""];
                }
            }
            result(pptPages);
        }
    }];
}

@end
