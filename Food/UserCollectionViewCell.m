//
//  UserCollectionViewCell.m
//  Food
//
//  Created by 鄭偉強 on 2016/10/19.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "UserCollectionViewCell.h"

@implementation UserCollectionViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    [self layoutIfNeeded];
   
    _userImage.layer.borderWidth = 1.5;
    
    _userImage.layer.cornerRadius = _userImage.frame.size.width / 2 ;
    
    _userImage.image = [UIImage imageNamed:@"user1.jpeg"];
    
}



@end
