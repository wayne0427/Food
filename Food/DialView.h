//
//  DialView.h
//  Food
//
//  Created by 鄭偉強 on 2016/12/2.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DialBlock)(NSString *);

@interface DialView : UIView

@property(nonatomic,copy)DialBlock dialBlock;

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;

@end
