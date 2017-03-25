//
//  OrdersTableViewCell.h
//  Food
//
//  Created by 鄭偉強 on 2016/10/21.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrdersTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *orderImageView;
@property (weak, nonatomic) IBOutlet UILabel *orderRestaurantName;
@property (weak, nonatomic) IBOutlet UILabel *createrName;
@property (weak, nonatomic) IBOutlet UILabel *createTime;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;

@end
