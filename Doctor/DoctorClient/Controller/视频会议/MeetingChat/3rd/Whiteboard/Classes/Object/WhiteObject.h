//
//  WhiteObject.h
//  WhiteSDK
//
//  Created by leavesster on 2018/8/14.
//

#import <Foundation/Foundation.h>

@interface WhiteObject : NSObject

//与pxd的pod的YYKit有冲突，所以注释了
//+ (instancetype)modelWithJSON:(id)json;
- (NSString *)jsonString;
- (NSDictionary *)jsonDict;

@end
