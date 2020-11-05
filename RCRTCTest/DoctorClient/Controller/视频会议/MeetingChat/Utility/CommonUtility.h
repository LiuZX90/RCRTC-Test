//
//  CommonUtility.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtility : NSObject


/**
 check file existing at path of url
 */
+ (BOOL)isFileExistsAtPath:(NSString *)url;

/**
 get data from plist file
 */
+ (NSArray *)getPlistArrayByplistName:(NSString *)plistName;

/**
 get random room number
 */
+ (NSInteger)getRandomNumber:(int)fromValue to:(int)toValue;

/**
 set button image
 */
+ (void)setButtonImage:(UIButton *)button imageName:(NSString *)name;
+ (void)setButtonBackgroundImage:(UIButton *)button imageName:(NSString *)name;


+ (NSString *)getRandomString;

+ (BOOL)isDownloadFileExists:(NSString *)fileName atPath:(NSString *)folderPath;

+ (NSString *)formatTimeFromDate:(NSDate *)date withFormat:(NSString *)format;

+ (NSString *)strimCharacter:(NSString *)userName withRegex:(NSString *)regex;

+ (NSInteger)compareVersion:(NSString *)version1 toVersion:(NSString *)version2;

+ (BOOL)validateContactNumber:(NSString *)mobileNum;

+ (NSString *)getdeviceName;

@end
