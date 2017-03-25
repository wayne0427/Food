//
//  PasswordView.h
//  writePassword
//
//  Created by 鄭偉強 on 2016/11/20.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define  boxWidth (SCREEN_WIDTH -70)/4 //密码框的宽度

@class PasswordView;

@protocol PasswordViewDelegate <NSObject>

@optional

-(void)TXTradePasswordView:(PasswordView *)view WithPasswordString:(NSString *)Password;


@end



@interface PasswordView : UIView <UITextFieldDelegate>

@property (nonatomic,assign)id <PasswordViewDelegate>PasswordViewDelegate;

- (id)initWithFrame:(CGRect)frame WithTitle :(NSString *)title;


@property (nonatomic,)UILabel *lable_title;

///  TF
@property (nonatomic,)UITextField *TF;

///  假的输入框
@property (nonatomic,)UIView *view_box;
@property (nonatomic,)UIView *view_box2;
@property (nonatomic,)UIView *view_box3;
@property (nonatomic,)UIView *view_box4;


///   密碼點
@property (nonatomic,)UILabel *lable_point;
@property (nonatomic,)UILabel *lable_point2;
@property (nonatomic,)UILabel *lable_point3;
@property (nonatomic,)UILabel *lable_point4;

@end
