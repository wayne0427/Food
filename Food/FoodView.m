//
//  FoodView.m
//  trytrytry
//
//  Created by 鄭偉強 on 2016/10/14.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "FoodView.h"

#define GAP   10.0
#define GAP_FOR_IMAGE   10.0
#define TEXT_FONT_SIZE 16.0



@implementation FoodView
{
     CGFloat currentY ;  //此為物件最底部的Y , 還需+GAP
    
    UIImageView * foodImageView;
    UILabel * foodNameLabel;
    UILabel * foodPriceLabel;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



-(instancetype)initWithFoodView:(UIImage *)image fdname:(NSString *)name fdPrice:(NSString *)price{
    
    self = [super init];
    
    currentY = 0.0;
    
    self.frame = CGRectMake(0, 0, 130, 240);
    
    
   
//    self.layer.borderWidth = 1;
//    self.layer.borderColor = [[UIColor redColor]CGColor];
    
//--------------------image--------------------------//
    
    foodImageView = [[UIImageView alloc]init];
    foodImageView.image = image;
    foodImageView.frame = CGRectMake(0, GAP * 2, self.frame.size.width - GAP_FOR_IMAGE, self.frame.size.height/2);
    //foodImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self addSubview:foodImageView];
    
    //圖片的高度 + 本身位置的Y
    currentY = currentY + foodImageView.frame.size.height + GAP * 2;
    
    
//--------------------name--------------------------//
    //name的X 會跟上面圖片一樣
    //name的Y 會在上面圖片的高的下面一點點
    //name的寬度width 會跟圖片一樣
    
    
    
    foodNameLabel = [[UILabel alloc]
                      initWithFrame:CGRectMake(0, currentY + GAP, foodImageView.frame.size.width, TEXT_FONT_SIZE)]; //label高度 = 字體大小
    foodNameLabel.font = [UIFont systemFontOfSize:16.0]; //字體大小
    foodNameLabel.text = name;
    foodNameLabel.backgroundColor = [UIColor whiteColor];
    foodNameLabel.numberOfLines = 0; // A value of 0 means no limit
    [foodNameLabel sizeToFit]; ///自動調整UIlabel的size
    [self addSubview:foodNameLabel];
    
    
    currentY =foodNameLabel.frame.origin.y + foodNameLabel.frame.size.height;
    
//--------------------price--------------------------//
    //price的X 會跟上面label一樣
    //price的Y 會在上面label的Y的下面一點點(+GAP)
    //price的寬度width 會跟圖片一樣
    
    
    
    foodPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, currentY + GAP, foodImageView.frame.size.width, TEXT_FONT_SIZE)];
    foodPriceLabel.font = [UIFont systemFontOfSize:TEXT_FONT_SIZE];
    foodPriceLabel.text = price;
    foodPriceLabel.backgroundColor = [UIColor whiteColor];
    
    foodPriceLabel.numberOfLines = 0; // A value of 0 means no limit
    [foodPriceLabel sizeToFit]; ///自動調整UIlabel的size
    [self addSubview:foodPriceLabel];
    
    
//--------------------end--------------------------//
    return self;
    
}


@end
