//
//  STJSONModel.m
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "STJSONModel.h"
#import <objc/runtime.h>

@implementation STJSONModel

- (instancetype)initWithDictionary:(NSDictionary*)jsonDic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:jsonDic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"Undefine Key %@",key);
}

- (NSString*)toJsonString {
    NSData* data = [self toJsonData];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString*)toFullJsonString {
    NSData* data = [self toFullJsonData];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


- (NSDictionary*)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if ([key isEqualToString:@"description"]) {
            continue;
        }
        id value = [self valueForKey:key];
        if (value) {
            [dict setObject:value forKey:key];
        }
    }
    
    if (properties) free(properties);
    return [dict copy];
}

- (NSDictionary*)toFullDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        if ([key isEqualToString:@"description"]) {
            continue;
        }
        id value = [self valueForKey:key];
        if (value) {
            [dict setObject:value forKey:key];
        }
        else{
            [dict setObject:[NSNull null] forKey:key];
        }
        
    }
    
    if (properties) free(properties);
    return [dict copy];
}


- (NSData*)toJsonData {
    NSDictionary* dict = [self toDictionary];
    NSError* error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict  options:0 error:&error];
    return data;
}

- (NSData*)toFullJsonData {
    NSDictionary* dict = [self toFullDictionary];
    NSError* error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict  options:0 error:&error];
    return data;
}

@end
