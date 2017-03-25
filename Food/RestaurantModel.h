//
//  RestaurantModel.h
//  listRestaurant
//
//  Created by 鄭偉強 on 2016/10/17.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NJGlobal.h"

@interface RestaurantModel : NSObject

// 餐廳圖標
@property (nonatomic, copy) NSString *MainImage;

// 餐廳名稱
@property (nonatomic, copy) NSString *ShopName;

// 餐廳地址
@property (nonatomic, copy) NSString *ShopAddress;

// 餐廳電話 
@property (nonatomic, copy) NSString *ShopPhone;

//餐廳上傳者 
@property (nonatomic, copy) NSString *UploadUser;

//按讚數量
@property (nonatomic, copy) NSString *starCount;

//useless
@property (nonatomic, copy) NSDictionary *stars;

//#define NJInitH(name) \
//- (instancetype)initWithDict:(NSDictionary *)dict; \
//+ (instancetype)name##WithDict:(NSDictionary *)dict;
//
//#define NJInitM(name)\
//- (instancetype)initWithDict:(NSDictionary *)dict \
//{ \
//if (self = [super init]) { \
//[self setValuesForKeysWithDictionary:dict]; \
//} \
//return self; \
//} \
//+ (instancetype)name##WithDict:(NSDictionary *)dict \
//{ \
//return [[self alloc] initWithDict:dict]; \
//}

NJInitH(tg)

@end
