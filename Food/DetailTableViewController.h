//
//  DetailTableViewController.h
//  Food
//
//  Created by 鄭偉強 on 2016/10/18.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantModel.h"

#define ARRAY_FAVOR_KEY  @"favorRestaurants"

@interface DetailTableViewController : UITableViewController

@property (nonatomic,strong) RestaurantModel * detail;
@property (nonatomic,strong) NSString * selectedUid;


//未用
@property (nonatomic,strong) NSArray * detailInfo;

@end
