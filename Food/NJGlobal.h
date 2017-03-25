//
//  NJGlobal.h
//  listRestaurant
//
//  Created by 鄭偉強 on 2016/10/17.
//  Copyright © 2016年 Wei. All rights reserved.
//

#ifndef _7__________NJGlobal_h
#define _7__________NJGlobal_h

#define NJInitH(name) \
- (instancetype)initWithDict:(NSDictionary *)dict; \
+ (instancetype)name##WithDict:(NSDictionary *)dict;

#define NJInitM(name)\
- (instancetype)initWithDict:(NSDictionary *)dict \
{ \
if (self = [super init]) { \
[self setValuesForKeysWithDictionary:dict]; \
} \
return self; \
} \
+ (instancetype)name##WithDict:(NSDictionary *)dict \
{ \
return [[self alloc] initWithDict:dict]; \
}

#endif

