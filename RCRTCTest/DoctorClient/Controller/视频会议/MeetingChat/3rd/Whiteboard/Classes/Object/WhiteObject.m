//
//  WhiteObject.m
//  WhiteSDK
//
//  Created by leavesster on 2018/8/14.
//

#import "WhiteObject.h"
//#import <YYModel/YYModel.h>
//#import "YYModel.h"

@implementation WhiteObject

//+ (instancetype)modelWithJSON:(id)json
//{
//    return [self yy_modelWithJSON:json];
//}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", [super description], [self jsonDict]];
}

- (NSString *)jsonString
{
//    return [self yy_modelToJSONString];
    return [self modelToJSONString];
}

- (NSDictionary *)jsonDict
{
//    NSDictionary *dict = [self yy_modelToJSONObject];
    NSDictionary *dict = [self modelToJSONObject];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return @{};
    }
//    return [self yy_modelToJSONObject];
    return [self modelToJSONObject];
}

@end
