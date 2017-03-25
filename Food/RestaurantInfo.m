//
//  RestaurantInfo.m
//  Food
//
//  Created by 鄭偉強 on 2016/10/17.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "RestaurantInfo.h"


static RestaurantInfo* _restaurantManager;

@implementation RestaurantInfo
{
    // 拿到資料裝在這邊
    NSMutableArray * restaurantArray;
    NSMutableArray * restaurantUidArray;
    
    //for detail
    NSMutableArray * foodItems;
    
    //for addMenu
    NSMutableArray * orderList;
    NSDictionary * createMenuInfo;
    
    //for favorite array
    NSMutableArray * favoriteRestaurantArray;
    NSMutableArray * favoriteRestaurantUidArray;
    
    //for manager array
    NSMutableArray * myRestaurantArray;
    NSMutableArray * myRestaurantUidArray;
    
    FIRDatabaseHandle  _handleWithTotalPrice;
    FIRDatabaseHandle  _handleWithOrderList;
    
}

+(instancetype)sharedInstance{
    
    if (_restaurantManager == nil) {
        
        _restaurantManager = [RestaurantInfo new];
        
    }
    
    return _restaurantManager;
    
}


-(void)getAllRestaurantArray:(DoneHandler)done{
    
    Helper * helper = [Helper sharedInstance];
    
    
    //拿到餐聽的ref 並觀察他底下的東西
    [[helper getDatabaseRefOfRestaurants]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        //this array for each restaurant value
        restaurantArray = [NSMutableArray new];
        
        //this array for each restaurant key (aka uid)
        restaurantUidArray = [NSMutableArray new];
        
        NSDictionary * restaurantInfo = snapshot.value;
        
        if (![restaurantInfo isEqual:[NSNull null]]) {
            for(NSString * uid in restaurantInfo){
                
                NSMutableDictionary * eachRestaurant = restaurantInfo[uid];
                
                [restaurantArray addObject:eachRestaurant];
                
                [restaurantUidArray addObject:uid];
            }
            //when finish for loop , go block
            
            
        }
        
        done(restaurantArray);
       
    }];

}

-(void)getFavoriteRestaurantArray:(DoneHandler)done{
    
    
    NSArray * favoriteUidArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"favorRestaurants"];
    
    NSLog(@"favorite count :%lu",favoriteUidArray.count);
    
   
   
    if (favoriteUidArray) {
        
        favoriteRestaurantArray = [NSMutableArray new];
        favoriteRestaurantUidArray = [NSMutableArray new];
        
        Helper * helper = [Helper sharedInstance];
        //拿到餐聽的ref 並觀察他底下的東西
        [[helper getDatabaseRefOfRestaurants]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            //所有info
            NSDictionary * restaurantInfo = snapshot.value;
            
            for(NSString * uid in restaurantInfo){
                
                if ([favoriteUidArray containsObject:uid]) {
                    
                    NSMutableDictionary * eachRestaurant = restaurantInfo[uid];
                    
                    [favoriteRestaurantArray addObject:eachRestaurant];
                    
                    [favoriteRestaurantUidArray addObject:uid];
                }
                
            }
            //when finish for loop , go block
            done(favoriteRestaurantArray);
            
        }];
        
        
    }else{
        NSLog(@"沒任何最愛餐廳");
    }
    
    
}


-(void)getMyRestaurantArray:(DoneHandler)done{
    
    
    NSString * myName = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    
    myRestaurantArray = [NSMutableArray new];
    myRestaurantUidArray = [NSMutableArray new];
    
    Helper * helper = [Helper sharedInstance];
    
    [[helper getDatabaseRefOfRestaurants]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary * restaurantInfo = snapshot.value;
        
        if (![restaurantInfo isEqual:[NSNull null]]) {
            for(NSString * uid in restaurantInfo){
                
                NSDictionary * eachRestaurant = restaurantInfo[uid];
                
                if ([myName isEqualToString:eachRestaurant[@"UploadUser"]]) {
                    [myRestaurantArray addObject:eachRestaurant];
                    [myRestaurantUidArray addObject:uid];
                }
                
            }
            
            
        }
        
        done(myRestaurantArray);
        
    }];
    
}



-(void)getRestaurantFoodItemArrayWithUid:(NSString*)uid handler:(DoneHandler)done{
    
    Helper * helper = [Helper sharedInstance];
    
    foodItems = [NSMutableArray new];
    
    [[[helper getDatabaseRefOfFoodItems]child:uid]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        // restaurant of uid -> food item dict
        
        
        NSDictionary * foodItemsDict = snapshot.value;
        
        for (NSString * foodItemUid in foodItemsDict) {
            
            NSDictionary * fooditem = foodItemsDict[foodItemUid];
            
            [foodItems addObject:fooditem];
            
        }
        

        done(foodItems);
        
    }];
    
    
}


-(void)getCreateMenuInfo:(NSString*)uid handler:(DoneHandlerDict)done{
    
     Helper * helper = [Helper sharedInstance];
    createMenuInfo = [NSDictionary new];
    
    [[[helper getDatabaseRefOfMenus]child:uid]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        createMenuInfo = snapshot.value;
        
        done(createMenuInfo);
    }];
    
}



-(void)getOrderListArrayWithUid:(NSString*)uid handler:(DoneHandler)done{
    
    Helper * helper = [Helper sharedInstance];
    
    _handleWithOrderList = [[[helper getDatabaseRefOfMenuOrderList]child:uid]observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        orderList = [NSMutableArray new];
        
        NSDictionary * orderListDict = snapshot.value;
        
        if ([orderListDict isEqual: [NSNull null]]) {
            NSLog(@"沒值");
        }else{
            
            for (NSString * userUid in orderListDict) {
                
                NSDictionary *eachOrderList = orderListDict[userUid];
                
                [orderList addObject:eachOrderList];
                
            }
            
        }
        
        done(orderList);
        
    }];
    
    
}




-(void)getTotalPriceWithMenuUid:(NSString*)uid handler:(DoneHandlerString)done{
    
    Helper * helper = [Helper sharedInstance];
    
   _handleWithTotalPrice = [[[helper getDatabaseRefOfMenus]child:uid]observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
       
        
        NSDictionary * menuInfo = snapshot.value;
        
        if ([menuInfo isEqual:[NSNull null]]) {
            NSLog(@"total null");
        }else{
            
            NSString * totalPrice = menuInfo[@"TotalPrice"];
            
            done(totalPrice);
            
        }
       
    }];

    
    
}


-(NSMutableArray *)getAllRestaurantUids{
    
    NSLog(@"all restaurant uid : %@",restaurantUidArray);
    return restaurantUidArray;
}


-(NSMutableArray *)getFavoriteRestaurantUids{
    
    NSLog(@"favorite restaurant uid : %@",favoriteRestaurantUidArray);
    return favoriteRestaurantUidArray;
}

-(NSMutableArray *)getMyRestaurantUids{
    
    NSLog(@"my restaurant uid : %@",myRestaurantUidArray);
    return myRestaurantUidArray;
}


-(void)removeHandlerWithMenuUid:(NSString*)uid{
    
    Helper * helper = [Helper sharedInstance];
    
    [[[helper getDatabaseRefOfMenuOrderList]child:uid]removeObserverWithHandle:_handleWithOrderList];
    
    [[[helper getDatabaseRefOfMenus]child:uid]removeObserverWithHandle:_handleWithTotalPrice];
    
    
}


@end
