//
//  OrderPickerView.h
//  GuWeiDatePicker
//
//  Created by 鄭偉強 on 2016/10/22.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PickerBlock)(NSString *);

@interface OrderPickerView : UIView

@property(nonatomic,copy)PickerBlock pickerBlock;

@property(nonatomic,strong) NSMutableArray * MArray;


@end
