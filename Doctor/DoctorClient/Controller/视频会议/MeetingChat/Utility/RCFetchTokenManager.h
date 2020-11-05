//
//  RCFetchTokenManager.h
//  SealRTC
//
//  Created by jfdreamyang on 2019/8/14.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^RCFetchTokenCompletion)(BOOL isSucccess,NSString * _Nullable token);

@interface RCFetchTokenManager : NSObject
+(RCFetchTokenManager *)sharedManager;

-(void)fetchTokenWithUserId:(NSString *)userId username:(NSString *)username portraitUri:(NSString *)portraitUri completion:(RCFetchTokenCompletion)completion;

-(void)pxd_fetchTokenWithUserId:(NSString *)userId username:(NSString *)username portraitUri:(NSString *)portraitUri completion:(RCFetchTokenCompletion)completion;

@end

NS_ASSUME_NONNULL_END
