//
//  RCRTCLocalUser.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/1/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

#import "RCRTCUser.h"
#import "RCRTCCodeDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class RCRTCOutputStream;
@class RCRTCInputStream;
@class RCMessageContent;

/*!
 音视频本地用户（当前登陆者）
 */
@interface RCRTCLocalUser : RCRTCUser

/*!
 用户发布的音视频流
 */
@property (nonatomic, copy, readonly) NSArray<RCRTCOutputStream *> *localStreams;

/*!
 设置用户属性
 
 @param attributeValue 属性值
 @param key 属性名称
 @param message 是否在设置属性的时候携带消息内容，传空则不往房间中发送消息（也不会收到有用户属性变换的回调）
 @param completion 设置完成回调
 @discussion
 设置用户属性
 
 @remarks 房间管理
 */
- (void)setAttributeValue:(NSString *)attributeValue
                   forKey:(NSString *)key
                  message:(RCMessageContent *)message
               completion:(RCRTCOperationCallback)completion;

/*!
 删除用户属性
 
 @param attributeKeys 属性名称数组
 @param message 是否在设置属性的时候携带消息内容，传空则不往房间中发送消息
 @param completion 删除完成回调
 @discussion
 删除用户属性
 
 @remarks 房间管理
 */
- (void)deleteAttributes:(NSArray <NSString *> *)attributeKeys
                 message:(RCMessageContent *)message
              completion:(RCRTCOperationCallback)completion;

/*!
 获取用户属性
 
 @param attributeKeys 属性名称
 @param completion 获取结果回调
 @discussion
 获取用户属性
 
 @remarks 房间管理
 */
- (void)getAttributes:(NSArray <NSString *> *)attributeKeys
           completion:(RCRTCAttributeOperationCallback)completion;

/*!
 发布默认音视频流
 
 @param completion 发布完成回调
 @discussion
 发布默认音视频流
 
 @remarks 资源管理
 */
- (void)publishDefaultStreams:(RCRTCOperationCallback)completion;

/*!
 发布音视频流
 
 @param stream 发布的音视频流
 @param completion 发布的音视频流结果
 @discussion
 发布音视频流
 
 @remarks 资源管理
 */
- (void)publishStream:(nonnull RCRTCOutputStream *)stream
           completion:(nonnull RCRTCOperationCallback)completion;

/*!
 发布多路音视频流
 
 @param streams 发布音视频流集合
 @param completion 发布的音视频流结果
 @discussion
 发布多路音视频流
 
 @remarks 资源管理
 */
- (void)publishStreams:(nonnull NSArray <RCRTCOutputStream *> *)streams
            completion:(nonnull RCRTCOperationCallback)completion;


/*!
 发布主播默认音视频流, 此接口仅直播模式的主播可用, 即 RCRTCRoomType 为 RCRTCRoomTypeLive 可用
 
 @param completion 发布完成回调
 @discussion
 发布主播默认音视频流, 此接口仅直播模式的主播可用, 即 RCRTCRoomType 为 RCRTCRoomTypeLive 可用
 
 @remarks 资源管理
 */
- (void)publishDefaultLiveStreams:(RCRTCLiveOperationCallback)completion;

/*!
 发布直播音视频流
 
 @param stream 发布的音视频流
 @param completion 发布的音视频流结果, 包括此主播的推流 url
 @discussion
 发布直播音视频流, 此接口仅直播模式的主播可用, 即 RCRTCRoomType 为 RCRTCRoomTypeLive 可用
 
 @remarks 资源管理
 */
- (void)publishLiveStream:(nonnull RCRTCOutputStream *)stream
                completion:(nonnull RCRTCLiveOperationCallback)completion;


/*!
 取消发布默认音视频流
 
 @param completion 取消发布完成回调
 @discussion
 取消发布默认音视频流
 
 @remarks 资源管理
 */
- (void)unpublishDefaultStreams:(RCRTCOperationCallback)completion;

/*!
 取消发布音视频流
 
 @param stream 取消发布的音视频流
 @param completion 发布的音视频流结果
 @discussion
 取消发布音视频流
 
 @remarks 资源管理
 */
- (void)unpublishStream:(nonnull RCRTCOutputStream *)stream
             completion:(nonnull RCRTCOperationCallback)completion;

/*!
 取消发布多路音视频流
 
 @param streams 取消发布的音视频流集合
 @param completion 发布的音视频流结果
 @discussion
 取消发布多路音视频流
 
 @remarks 资源管理
 */
- (void)unpublishStreams:(nonnull NSArray <RCRTCOutputStream *> *)streams
              completion:(nonnull RCRTCOperationCallback)completion;
/*!
 订阅流, 同一个流只能填写在 avStreams 或 tinyStreams 中的一个数组中
 
 @param avStreams 普通流
 @param tinyStreams 需要携带小流的流数组
 @param completion 完成的回调
 @discussion
 订阅流
 
 @remarks 资源管理
 */
- (void)subscribeStream:(NSArray <RCRTCInputStream *> *)avStreams
            tinyStreams:(NSArray <RCRTCInputStream *> *)tinyStreams
             completion:(nonnull RCRTCOperationCallback)completion;

/*!
 取消订阅音视频流
 
 @param stream 音视频流
 @param completion 音视频流结果
 @discussion
 取消订阅音视频流
 
 @remarks 资源管理
 */
- (void)unsubscribeStream:(nonnull RCRTCInputStream *)stream
               completion:(nonnull RCRTCOperationCallback)completion;

/*!
 取消订阅多路音视频流
 
 @param streams 音视频流集合
 @param completion 音视频流结果
 @discussion
 取消订阅多路音视频流
 
 @remarks 资源管理
 */
- (void)unsubscribeStreams:(nonnull NSArray <RCRTCInputStream *> *)streams 
                completion:(nonnull RCRTCOperationCallback)completion;

@end

NS_ASSUME_NONNULL_END
