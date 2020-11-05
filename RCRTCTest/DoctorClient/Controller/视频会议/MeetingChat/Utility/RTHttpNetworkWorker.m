//
//  RTHttpNetworkWorker.m
//  RTCTester
//
//  Created by birney on 2019/1/23.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RTHttpNetworkWorker.h"
//#include <CommonCrypto/CommonHMAC.h>

#import <RongRTCLib/RongRTCLib.h>


static RTHttpNetworkWorker* defaultWorker = nil;

@interface RTHttpNetworkWorker () <NSURLSessionDelegate>

@end

@implementation RTHttpNetworkWorker

+ (instancetype)shareInstance {
    if (!defaultWorker) {
        defaultWorker = [[RTHttpNetworkWorker alloc] init];
    }
    return defaultWorker;
}

+ (instancetype) allocWithZone:(struct _NSZone *)zone {
    if (!defaultWorker) {
        defaultWorker = [super allocWithZone:zone];
    }
    return defaultWorker;
}

- (instancetype) copy{
    return defaultWorker;
}


- (void)fetchSMSValidateCode:(NSString *)phoneNum
                  regionCode:(NSString*)code
                     success:(void (^)(NSString* code))sucess
                       error:(void (^)(NSError* error))errorBlock {
    
    NSString *host = RCDEMOServerURL;
    if (![host hasPrefix:@"http"]) {
        host = [@"https://" stringByAppendingString:RCDEMOServerURL];
    }
    NSURL* urlPost = [NSURL URLWithString:[NSString stringWithFormat:@"%@/user/send_code",host]];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dic = @{@"phone":phoneNum, @"region":code,@"key":[NSString stringWithFormat:@"%@%@", phoneNum, kDeviceUUID]};
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    request.HTTPBody = data;
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            errorBlock(error);
        }
        else{
            NSDictionary* responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *code = responseObject[@"code"];
            sucess(code);
        }
        [session finishTasksAndInvalidate];
    }];
    [task  resume];
}


- (void)validateSMSPhoneNum:(NSString *)phoneNum
                 regionCode:(NSString*)regionCode
                       code:(NSString *)code
                   response:(void (^)(NSDictionary *respDict))resp
                      error:(void (^)(NSError* error))errorBlock
{
    NSString *host = RCDEMOServerURL;
    if (![host hasPrefix:@"http"]) {
        host = [@"https://" stringByAppendingString:RCDEMOServerURL];
    }
    NSURL* urlPost = [NSURL URLWithString:[NSString stringWithFormat:@"%@/user/verify_code",host]];
    //小度测试, 获取连接 RCIM 的 token
//    NSURL* urlPost = [NSURL URLWithString:[NSString stringWithFormat:@"%@/user/getToken.json",host]];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //此处生成公有云UserID
    NSDictionary *dic = @{@"phone":phoneNum, @"region":regionCode, @"code":code, @"key":[NSString stringWithFormat:@"%@_%@_ios", phoneNum, kDeviceUUID],@"appkey":RCIMAPPKey};
    
    
    /**
     name = "\U6797\U4eae";
     portraitUri = "https://api.yizhitong100.com/IMG/manager/doctor/4cdfa9c4bb9b48c7bcf933af779610dc.jpg";
     userId = "a44d7a30-147b-49aa-9369-fa474937c2fe";
     */
    //小度测试
//    NSDictionary *dic = @{@"name":@"小度-0", @"portraitUri":@"https://api.yizhitong100.com/IMG/manager/doctor/4cdfa9c4bb9b48c7bcf933af779610dc.jpg", @"userId":@"a44d7a30-147b-49aa-9369-fa474937c2fe"};

    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    request.HTTPBody = data;

////    NSDictionary<NSString *, NSString *> *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
//    NSString *appKey = RCIMAPPKey;
//    NSString *appSecret = RCIM_API_SECRET;
//
//    NSLog(@"RongCloudAppKey = %@",appKey);
//
//    NSString *random = [[NSNumber numberWithInt:(arc4random() % 100000) + 1] stringValue];
//    NSString *timestamp = [NSString stringWithFormat:@"%.0f", floor([[NSDate date] timeIntervalSince1970] * 1000) ];
//    NSString *signature = [[[NSString stringWithFormat:@"%@%@%@", appSecret, random, timestamp] dataUsingEncoding:NSUTF8StringEncoding] sha1String];
//    NSDictionary<NSString *, NSString *> *headerFieldValueDictionary = @{@"App-Key" : appKey,
//                                                                         @"Nonce" : random,
//                                                                         @"Timestamp" : timestamp,
//                                                                         @"Signature" : signature
//                                                                         };
//    if (headerFieldValueDictionary != nil) {
//        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
//            NSString *value = headerFieldValueDictionary[httpHeaderField];
//            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
//        }
//    }
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            errorBlock(error);
        }
        else{
            NSDictionary* responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            resp(responseObject);
        }
        [session finishTasksAndInvalidate];
    }];
    [task  resume];
}

- (void)publish:(NSString *)roomId roomName:(NSString *)roomName liveUrl:(NSString *)liveUrl completion:(void (^)(BOOL success))completion{
    NSString *host = RCLiveURL;
    if (![host hasPrefix:@"http"]) {
        host = [@"https://" stringByAppendingString:RCDEMOServerURL];
    }
    NSURL* urlPost = [NSURL URLWithString:[NSString stringWithFormat:@"%@/publish",host]];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:30.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *dic = @{@"roomId":roomId, @"roomName":roomId,@"mcuUrl":liveUrl?liveUrl:@"",@"pubUserId":[RCIMClient sharedRCIMClient].currentUserInfo.userId};
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    request.HTTPBody = data;
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (completion) {
                completion(YES);
            }
        } else {
            if (completion) {
                completion(NO);
            }
        }
    }];
    [task  resume];
}
- (void)query:(NSString *)roomId completion:(void (^)( BOOL isSuccess,NSArray  *_Nullable))completion{
    NSString *host = RCLiveURL;
    if (![host hasPrefix:@"http"]) {
        host = [@"https://" stringByAppendingString:RCDEMOServerURL];
    }
    NSURL* urlPost = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query",host]];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:30.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *dic = @{};
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    request.HTTPBody = data;
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data == nil) {
            if (completion) {
                completion(NO,nil);
            }
            return ;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        DLog(@"LLH...... query media server List: %@", dict);
        BOOL success = [dict[@"code"] boolValue];
        if (error || success) {
            if (completion) {
                completion(NO,nil);
            }
        } else {
            NSArray *arr= dict[@"roomList"];
            if ([arr containsObject:[NSNull null]]) {
                if (completion) {
                    completion(YES,nil);
                }
            } else {
                if (completion) {
                    completion(YES,arr);
                }
            }
            
        }
    }];
    [task  resume];
}
- (void)unpublish:(NSString *)roomId  completion:(void (^)(BOOL success))completion{
    NSString *host = RCLiveURL;
    if (![host hasPrefix:@"http"]) {
        host = [@"https://" stringByAppendingString:RCDEMOServerURL];
    }
    NSURL* urlPost = [NSURL URLWithString:[NSString stringWithFormat:@"%@/unpublish",host]];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                        timeoutInterval:30.0];
     request.HTTPMethod = @"POST";
       [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *dic = @{@"roomId":roomId?roomId:@""};
       NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
       request.HTTPBody = data;
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (completion) {
                completion(YES);
            }
        } else {
            if (completion) {
                completion(NO);
            }
        }
    }];
    [task  resume];
}


#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}





@end
