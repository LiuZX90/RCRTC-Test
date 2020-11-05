//
//  NSString+length.h
//  RongCloud
//
//  Created by Rongcloud on 2018/2/24.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (length)

- (NSInteger)getStringLengthOfBytes;
- (NSString *)subBytesOfstringToIndex:(NSInteger)index;
- (NSString *)subBytesOfstringFromIndex:(NSInteger)index;
-(NSString *)subStringWithString:(NSString *)string withLength:(NSInteger )count;

@end
