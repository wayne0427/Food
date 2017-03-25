//
//  RestaurantInfo.h
//  Food
//
//  Created by 鄭偉強 on 2016/10/17.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Helper.h"
@import Firebase;

typedef void (^DoneHandler)(NSMutableArray * result);

typedef void (^DoneHandlerString)(NSString * result);

typedef void (^DoneHandlerDict)(NSDictionary * result);

@interface RestaurantInfo : NSObject

+(instancetype)sharedInstance;


//for main view
-(void)getAllRestaurantArray:(DoneHandler)done;

//for detail view

-(void)getRestaurantFoodItemArrayWithUid:(NSString*)uid handler:(DoneHandler)done;



//for addMenuViewContrller
-(void)getTotalPriceWithMenuUid:(NSString*)uid handler:(DoneHandlerString)done;

-(void)getOrderListArrayWithUid:(NSString*)uid handler:(DoneHandler)done;

-(void)getCreateMenuInfo:(NSString*)uid handler:(DoneHandlerDict)done;

-(void)removeHandlerWithMenuUid:(NSString*)uid;


//for favoriteViewController
-(void)getFavoriteRestaurantArray:(DoneHandler)done;


//for managerViewController
-(void)getMyRestaurantArray:(DoneHandler)done;


-(NSMutableArray *)getAllRestaurantUids;
-(NSMutableArray *)getFavoriteRestaurantUids;
-(NSMutableArray *)getMyRestaurantUids;

@end
