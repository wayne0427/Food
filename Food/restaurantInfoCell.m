//
//  restaurantInfoCell.m
//  listRestaurant
//
//  Created by 鄭偉強 on 2016/10/17.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "restaurantInfoCell.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface restaurantInfoCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UILabel *uploaderLabel;

@property (weak, nonatomic) IBOutlet UIImageView *cellBackgroundView;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;


@end

@implementation restaurantInfoCell

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"tg";

    restaurantInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        // 如果找不到就從xib中創建cell
        cell =  [[[NSBundle mainBundle] loadNibNamed:@"restaurantInfoCell" owner:nil options:nil] firstObject];
     
    }else{
        //如果是重用cell，则把cell中自己添加的subview清除掉，避免出现重叠問题
        
    }
    return cell;
}


- (void)setTg:(RestaurantModel *)tg
{
    _tg = tg;
    
    
    NSURL * imageURL = [NSURL URLWithString:tg.MainImage];
    
    
    
    [self.iconView sd_setImageWithURL:imageURL placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (error) {
            NSLog(@"image download fail");
            NSLog(@"%@",error);
        }
        

        
    }];
    
    
    
    
    
    // 設置餐廳標題
    self.titleLabel.text = tg.ShopName;
    // 設置餐廳地址
    self.addressLabel.text = [NSString stringWithFormat:@"地址:%@", tg.ShopAddress];
    // 設置餐廳電話
    self.uploaderLabel.text = [NSString stringWithFormat:@"上傳者:%@", tg.UploadUser];
    
    //設置數量
    if (tg.starCount) {
        NSString * count = [NSString stringWithFormat:@"★:%@",tg.starCount];
        self.countLabel.text = count;
    }else{
        self.countLabel.text = @"★:0";
    }

    
    
    //[self sendSubviewToBack:self.cellBackgroundView];
}




@end
