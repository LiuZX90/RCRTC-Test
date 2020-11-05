//
//  RCFetchTokenManager.m
//  SealRTC
//
//  Created by jfdreamyang on 2019/8/14.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCFetchTokenManager.h"
#import "LoginManager.h"
#include <CommonCrypto/CommonCrypto.h>


@interface NSString (CC)
@property (nonatomic,copy,readonly)NSString *sha1;
@end

@implementation NSString (CC)

- (NSString*) sha1
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    //使用对应的CC_SHA1,CC_SHA256,CC_SHA384,CC_SHA512的长度分别是20,32,48,64
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    //使用对应的CC_SHA256,CC_SHA384,CC_SHA512
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}


@end


@interface RCFetchTokenManager ()<NSURLSessionDelegate>
@property (nonatomic,strong)NSURLSession *defaultSession;
@property (nonatomic,strong)NSOperationQueue *queue;
@end

@implementation RCFetchTokenManager
+(RCFetchTokenManager *)sharedManager{
    static RCFetchTokenManager * _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc]init];
        [_manager configure];
    });
    return _manager;
}

-(void)configure{
    self.queue = [[NSOperationQueue alloc]init];
    self.defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

-(void)fetchTokenWithUserId:(NSString *)userId username:(NSString *)username portraitUri:(NSString *)portraitUri completion:(RCFetchTokenCompletion)completion{
    NSString *suffix = @"user/getToken.json";
    if (!username) username = @"unknown";
    if (!portraitUri) portraitUri = @"http";
    
    NSString *api = [NSString stringWithFormat:@"%@/%@",RCIM_API_SERVER,suffix];
    if (kLoginManager.isPrivateEnvironment) {
        NSString *serverAPI = kLoginManager.privateIMServer;
        if (![serverAPI hasPrefix:@"http"]) {
            serverAPI = [@"https://" stringByAppendingFormat:@""];
        }
        api = [NSString stringWithFormat:@"%@/%@",serverAPI,suffix];
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:api]];
    request.HTTPMethod = @"POST";
    
    [request setValue:RCIMAPPKey forHTTPHeaderField:@"App-Key"];
    if (kLoginManager.isPrivateEnvironment) {
        [request setValue:kLoginManager.privateAppKey forHTTPHeaderField:@"App-Key"];
    }
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    NSString *Nonce = [NSString stringWithFormat:@"%u",100000+arc4random()%100000];
    [request setValue:Nonce forHTTPHeaderField:@"Nonce"];

    NSString *Timestamp = [NSString stringWithFormat:@"%lu",(unsigned long)([NSDate date].timeIntervalSince1970 * 1000)];
    [request setValue:Timestamp forHTTPHeaderField:@"Timestamp"];

    NSString *Signature = [NSString stringWithFormat:@"%@%@%@",RCIM_API_SECRET,Nonce,Timestamp];
    if (kLoginManager.isPrivateEnvironment) {
        Signature = [NSString stringWithFormat:@"%@%@%@",kLoginManager.privateAppSecret,Nonce,Timestamp];
    }
    [request setValue:Signature.sha1 forHTTPHeaderField:@"Signature"];
    NSString *bodyStr = [NSString stringWithFormat:@"userId=%@&portraitUri=%@&name=%@",userId,portraitUri,username];
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionTask *task = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSError *error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (result[@"token"]) {
                completion(YES,result[@"token"]);
            }
            else{
                completion(NO,nil);
            }
        }
        else{
            completion(NO,nil);
        }
    }];
    
    [task resume];

}

-(void)pxd_fetchTokenWithUserId:(NSString *)userId username:(NSString *)username portraitUri:(NSString *)portraitUri completion:(RCFetchTokenCompletion)completion{
    NSString *suffix = @"user/getToken.json";
    if (!username) username = @"unknown";
    if (!portraitUri) portraitUri = @"http";
    
    NSString *api = [NSString stringWithFormat:@"%@/%@",RCIM_API_SERVER,suffix];
    if (kLoginManager.isPrivateEnvironment) {
        NSString *serverAPI = kLoginManager.privateIMServer;
        if (![serverAPI hasPrefix:@"http"]) {
            serverAPI = [@"https://" stringByAppendingFormat:@""];
        }
        api = [NSString stringWithFormat:@"%@/%@",serverAPI,suffix];
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:api]];
    request.HTTPMethod = @"POST";
    
    [request setValue:RCIMAPPKey forHTTPHeaderField:@"App-Key"];
    if (kLoginManager.isPrivateEnvironment) {
        [request setValue:kLoginManager.privateAppKey forHTTPHeaderField:@"App-Key"];
    }
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    NSString *Nonce = [NSString stringWithFormat:@"%u",100000+arc4random()%100000];
    [request setValue:Nonce forHTTPHeaderField:@"Nonce"];

    NSString *Timestamp = [NSString stringWithFormat:@"%lu",(unsigned long)([NSDate date].timeIntervalSince1970 * 1000)];
    [request setValue:Timestamp forHTTPHeaderField:@"Timestamp"];

    NSString *Signature = [NSString stringWithFormat:@"%@%@%@",RCIM_API_SECRET,Nonce,Timestamp];
    if (kLoginManager.isPrivateEnvironment) {
        Signature = [NSString stringWithFormat:@"%@%@%@",kLoginManager.privateAppSecret,Nonce,Timestamp];
    }
    [request setValue:Signature.sha1 forHTTPHeaderField:@"Signature"];
    NSString *bodyStr = [NSString stringWithFormat:@"userId=%@&portraitUri=%@&name=%@",userId,portraitUri,username];
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionTask *task = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSError *error = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (result[@"token"]) {
                completion(YES,result[@"token"]);
            }
            else{
                completion(NO,nil);
            }
        }
        else{
            completion(NO,nil);
        }
    }];
    
    [task resume];

}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}


#pragma mark -session delegate
//-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
//
//    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//    __block NSURLCredential *credential = nil;
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] && [challenge.protectionSpace.host containsString:@"101.89.92.179"]) {
//        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//        if (credential) {
//            disposition = NSURLSessionAuthChallengeUseCredential;
//        } else {
//            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//        }
//    } else {
//        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//    }
//
//    if (completionHandler) {
//        completionHandler(disposition, credential);
//    }
//}
@end
