//
//  UserCollectionViewCell.h
//  Food
//
//  Created by 鄭偉強 on 2016/10/19.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end
