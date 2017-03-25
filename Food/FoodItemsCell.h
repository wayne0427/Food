//
//  FoodItemsCell.h
//  myOrderCellClass
//
//  Created by 鄭偉強 on 2016/11/21.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FoodItemsCell;

@protocol FoodItemsCellDelegate <NSObject>

@optional

-(void)FoodItemsCellView:(FoodItemsCell *)view WithString:(NSString *)price;

-(void)FoodItemsCellView:(FoodItemsCell *)view WithMinus:(NSDictionary *)fooditem;
-(void)FoodItemsCellView:(FoodItemsCell *)view WithPlus:(NSDictionary *)fooditem;

@end



@interface FoodItemsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *foodImage;

@property (weak, nonatomic) IBOutlet UILabel *foodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodPriceLabel;
@property (weak, nonatomic) IBOutlet UITextField *countTextField;

@property (weak, nonatomic) IBOutlet UIButton *plusBtn;

@property (weak, nonatomic) IBOutlet UIButton *minusBtn;



@property (nonatomic,assign)id <FoodItemsCellDelegate> foodItemsdelegate;

@end
