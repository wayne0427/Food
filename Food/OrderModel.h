//
//  OrderModel.h
//  Food
//
//  Created by 鄭偉強 on 2016/10/21.
//  Copyright © 2016年 Shiang-Yu Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Helper.h"
@import Firebase;

typedef void (^DoneHandler)(NSMutableArray * result);



@interface OrderModel : NSObject

+(instancetype)sharedInstance;

-(void)getOrdersArray:(DoneHandler)done;

-(NSMutableArray*)getOrdersKeyArray;

-(void)deleteFirebaseObserve;


@end
