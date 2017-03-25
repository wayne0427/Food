//
//  PasswordView.m
//  writePassword
//
//  Created by 鄭偉強 on 2016/11/20.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "PasswordView.h"

@implementation PasswordView


- (id)initWithFrame:(CGRect)frame WithTitle :(NSString *)title
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // 標題
        _lable_title = [[UILabel alloc]init];
        _lable_title.frame = CGRectMake(0, 20, SCREEN_WIDTH, 20);
        _lable_title.text = title;
        _lable_title.textAlignment=1;
        _lable_title.textColor = [UIColor blackColor];
        [self addSubview:_lable_title];
        
        
        ///  TF
        _TF = [[UITextField alloc]init];
        _TF.frame = CGRectMake(0, 0, 0, 0);
        _TF.delegate = self;
        _TF.keyboardType=UIKeyboardTypeNumberPad;
        [_TF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:_TF];
        
        
        
        
        ///  假的輸入框
        _view_box = [[UIView alloc]initWithFrame:CGRectMake(10, 60, boxWidth, boxWidth)];
        [_view_box.layer setBorderWidth:1.0];
        _view_box.layer.borderColor = [[UIColor grayColor]CGColor];
        [self addSubview:_view_box];
        
        _view_box2 = [[UIView alloc]initWithFrame:CGRectMake(20+boxWidth*1, _view_box.frame.origin.y, boxWidth, boxWidth)];
        [_view_box2.layer setBorderWidth:1.0];
        _view_box2.layer.borderColor = [[UIColor grayColor]CGColor];
        [self addSubview:_view_box2];
        
        _view_box3 = [[UIView alloc]initWithFrame:CGRectMake(30+boxWidth*2, _view_box.frame.origin.y, boxWidth, boxWidth)];
        [_view_box3.layer setBorderWidth:1.0];
        _view_box3.layer.borderColor = [[UIColor grayColor]CGColor];
        [self addSubview:_view_box3];
        
        _view_box4 = [[UIView alloc]initWithFrame:CGRectMake(40+boxWidth*3, _view_box.frame.origin.y, boxWidth, boxWidth)];
        [_view_box4.layer setBorderWidth:1.0];
        _view_box4.layer.borderColor = [[UIColor grayColor]CGColor];
        [self addSubview:_view_box4];
       
        
        
        ///   密碼點
        _lable_point = [[UILabel alloc]init];
        _lable_point.frame = CGRectMake(10, 60, boxWidth, boxWidth);
        [_lable_point setFont:[UIFont systemFontOfSize:30]];
        _lable_point.textAlignment = NSTextAlignmentCenter;
        
        _lable_point.backgroundColor = [UIColor whiteColor];
        [_lable_point.layer setBorderWidth:1.0];
        _lable_point.layer.borderColor = [[UIColor grayColor]CGColor];
        
        [self addSubview:_lable_point];
        
        _lable_point2 = [[UILabel alloc]init];
        _lable_point2.frame = CGRectMake(20+boxWidth*1, _view_box.frame.origin.y, boxWidth, boxWidth);
        
        [_lable_point2.layer setBorderWidth:1.0];
        _lable_point2.layer.borderColor = [[UIColor grayColor]CGColor];
        [_lable_point2 setFont:[UIFont systemFontOfSize:30]];
        _lable_point2.textAlignment = NSTextAlignmentCenter;
        _lable_point2.backgroundColor = [UIColor whiteColor];
        [self addSubview:_lable_point2];
        
        
        _lable_point3 = [[UILabel alloc]init];
        _lable_point3.frame = CGRectMake(30+boxWidth*2, _view_box.frame.origin.y, boxWidth, boxWidth);
        
        [_lable_point3.layer setBorderWidth:1.0];
        [_lable_point3 setFont:[UIFont systemFontOfSize:30]];
        _lable_point3.textAlignment = NSTextAlignmentCenter;
        _lable_point3.layer.borderColor = [[UIColor grayColor]CGColor];
        _lable_point3.backgroundColor = [UIColor whiteColor];
        [self addSubview:_lable_point3];
        
        _lable_point4 = [[UILabel alloc]init];
        _lable_point4.frame = CGRectMake(40+boxWidth*3, _view_box.frame.origin.y, boxWidth, boxWidth);
        [_lable_point4 setFont:[UIFont systemFontOfSize:30]];
        _lable_point4.textAlignment = NSTextAlignmentCenter;
        [_lable_point4.layer setBorderWidth:1.0];
        _lable_point4.layer.borderColor = [[UIColor grayColor]CGColor];
        _lable_point4.backgroundColor = [UIColor whiteColor];
        [self addSubview:_lable_point4];
        
        
        _lable_point.hidden=YES;
        _lable_point2.hidden=YES;
        _lable_point3.hidden=YES;
        _lable_point4.hidden=YES;
        
    }
    return self;
}



- (void) textFieldDidChange:(id) sender
{
    
    UITextField *_field = (UITextField *)sender;
    
    switch (_field.text.length) {
        case 0:
        {
            _lable_point.hidden=YES;
            _lable_point2.hidden=YES;
            _lable_point3.hidden=YES;
            _lable_point4.hidden=YES;
           
        }
            break;
        case 1:
        {
            
            NSString * String1 = [_field.text substringWithRange:NSMakeRange(0, 1)];
            
            _lable_point.hidden=NO;
            _lable_point.text = String1;
            
            _lable_point2.hidden=YES;
            _lable_point3.hidden=YES;
            _lable_point4.hidden=YES;
          
        }
            break;
        case 2:
        {
             NSString * String1 = [_field.text substringWithRange:NSMakeRange(0, 1)];
             NSString * String2 = [_field.text substringWithRange:NSMakeRange(1, 1)];
            
            _lable_point.hidden=NO;
            _lable_point.text = String1;
            
            
            _lable_point2.hidden=NO;
            _lable_point2.text = String2;
            
            _lable_point3.hidden=YES;
            _lable_point4.hidden=YES;
       
        }
            break;
        case 3:
        {
            NSString * String1 = [_field.text substringWithRange:NSMakeRange(0, 1)];
            NSString * String2 = [_field.text substringWithRange:NSMakeRange(1, 1)];
            NSString * String3 = [_field.text substringWithRange:NSMakeRange(2, 1)];
            
            
            _lable_point.hidden=NO;
            _lable_point.text = String1;
            
            
            _lable_point2.hidden=NO;
            _lable_point2.text = String2;
            
            _lable_point3.hidden=NO;
            _lable_point3.text = String3;
            
            _lable_point4.hidden=YES;
           
        }
            break;
        case 4:
        {
            NSString * String1 = [_field.text substringWithRange:NSMakeRange(0, 1)];
            NSString * String2 = [_field.text substringWithRange:NSMakeRange(1, 1)];
            NSString * String3 = [_field.text substringWithRange:NSMakeRange(2, 1)];
            NSString * String4 = [_field.text substringWithRange:NSMakeRange(3, 1)];
            
            
            _lable_point.hidden=NO;
            _lable_point.text = String1;
            
            
            _lable_point2.hidden=NO;
            _lable_point2.text = String2;
            
            _lable_point3.hidden=NO;
            _lable_point3.text = String3;
            
            _lable_point4.hidden=NO;
            _lable_point4.text = String4;
            
           
        }
            break;
            
        default:
            break;
    }
    
    
    if (_field.text.length == 4)
    {
        [self.PasswordViewDelegate TXTradePasswordView:self WithPasswordString:_field.text];
        
    }
    
    
}

//超過4個數字不能按
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    
//    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    
//    if (toBeString.length > 4 ){
//        //        textField.text = [toBeString substringToIndex:1];
//        return NO;
//    }
//    return YES;
//}


@end
