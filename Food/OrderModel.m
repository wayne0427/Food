//
//  OrderModel.m
//  Food
//
//  Created by 鄭偉強 on 2016/10/21.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "OrderModel.h"

static OrderModel * _orderManager;

@implementation OrderModel
{
    
    //for tableView
    NSMutableArray * ordersArray;
    
    //for did selected cell use
    NSMutableArray * ordersKeyArray;
    
    
    FIRDatabaseHandle _handler;
    
    
}


+(instancetype)sharedInstance{
    
    if (_orderManager == nil) {
        
        _orderManager = [OrderModel new];
        
    }
    
    return _orderManager;
    
}



-(void)getOrdersArray:(DoneHandler)done{
    
    Helper * helper = [Helper sharedInstance];
    
    
   //observeEventType
    //observeSingleEventOfType
    
    _handler = [[helper getDatabaseRefOfMenus]observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        
        
        ordersArray = [NSMutableArray new];
        ordersKeyArray = [NSMutableArray new];
        
            
        NSDictionary * ordersDict = snapshot.value;
        
        
        
        if ([ordersDict isEqual: [NSNull null]]) {
            NSLog(@"沒值");
        }else{
            
            for (NSString * orderUid in ordersDict) {
                
                NSDictionary * eachOrder = ordersDict[orderUid];
                
                [ordersArray addObject:eachOrder];
                [ordersKeyArray addObject:orderUid];
            }
        
            
        }
        
        done(ordersArray);
        
        
    }];
    
}


-(void)deleteFirebaseObserve{
    
    Helper * helper = [Helper sharedInstance];
    
    [[helper getDatabaseRefOfMenus]removeObserverWithHandle:_handler];
    
}

// use it in outside block
-(NSMutableArray*)getOrdersKeyArray{
    return ordersKeyArray;
}


@end
