//
//  RTHttpNetworkWorker.h
//  RTCTester
//
//  Created by birney on 2019/1/23.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTHttpNetworkWorker : NSObject

+ (instancetype)shareInstance;

- (void)fetchSMSValidateCode:(NSString *)phoneNum
                  regionCode:(NSString*)code
                     success:(void (^)(NSString* code))sucess
                       error:(void (^)(NSError* error))errorBlock;

- (void)validateSMSPhoneNum:(NSString *)phoneNum
                 regionCode:(NSString*)regionCode
                       code:(NSString *)code
                   response:(void (^)(NSDictionary *respDict))resp
                      error:(void (^)(NSError* error))errorBlock;

- (void)getMediaServerList:(void (^)(NSDictionary *respDict))resp;

- (void)getDemoVersionInfo:(void (^)(NSDictionary *respDict))resp;
- (void)publish:(NSString *)roomId roomName:(NSString *)roomName liveUrl:(NSString *)liveUrl completion:(void (^)(BOOL success))completion;
- (void)query:(NSString *)roomId completion:(void (^)( BOOL isSuccess, NSArray *_Nullable))completion;
- (void)unpublish:(NSString *)roomId  completion:(void (^)(BOOL success))completion;
@end


NS_ASSUME_NONNULL_END
