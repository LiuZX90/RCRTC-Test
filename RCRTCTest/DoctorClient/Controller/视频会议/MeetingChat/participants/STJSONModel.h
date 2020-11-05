//
//  STJSONModel.h
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STJSONModel : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)jsonDic;

- (NSString*)toJsonString;

- (NSData*)toJsonData;

- (NSDictionary*)toDictionary;

- (NSString*)toFullJsonString;

- (NSData*)toFullJsonData;

- (NSDictionary*) toFullDictionary;

@end

NS_ASSUME_NONNULL_END
