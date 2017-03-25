//
//  restaurantInfoCell.h
//  listRestaurant
//
//  Created by 鄭偉強 on 2016/10/17.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantModel.h"

@class restaurantInfo;

@interface restaurantInfoCell : UITableViewCell

@property (nonatomic, strong) RestaurantModel *tg;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
