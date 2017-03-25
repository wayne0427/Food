//
//  OrderPickerView.m
//  GuWeiDatePicker
//
//  Created by 鄭偉強 on 2016/10/22.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "OrderPickerView.h"


@interface OrderPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    CGFloat _W;
    CGFloat _H;
    
    UIPickerView *_pickerView;
    
    NSString *_OrderSelectedString;
}

@end




@implementation OrderPickerView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _MArray = [NSMutableArray new];
        [self addPickerView];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)addPickerView{
    
    _W = self.frame.size.width;
    _H = self.frame.size.height;
    
    //藍色條
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _W, 25)];
//    view.backgroundColor = [UIColor colorWithRed:5/255.f green:160/255.f blue:249/255.f alpha:1];
    
    view.backgroundColor = [UIColor blueColor];
    
    view.userInteractionEnabled = YES;
    [self addSubview:view];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, _W, _H)];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    [self addSubview:_pickerView];
    
    //左按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _H-30, 50, 25)];
    leftButton.tag = 101;
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    
    [leftButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftButton];
    
    //右按钮
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(_W - 50, _H-30, 50, 25)];
    rightButton.tag = 102;
    [rightButton setTitle:@"确定" forState:UIControlStateNormal];
    
    [rightButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightButton];
    
    
    //中間的label
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    label.font = [UIFont systemFontOfSize:15];
    label.text = @"選擇餐點";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.center = view.center;
    [view addSubview:label];
    
    
    
}

-(void)buttonClick:(UIButton *)btn{
    
    if (btn.tag==101) {
        //
        self.pickerBlock(@"cancel");
    }else{
        //
        if (_OrderSelectedString == nil) {
            _OrderSelectedString = _MArray[0];
        }
        
        
        self.pickerBlock(_OrderSelectedString);
    }
    
    [self removeFromSuperview];
    
    
}



#pragma mark - UIPickerVIew的代理方法
//行高
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}

//該行label設定
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel * label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 100 + row;
    
    label.frame = CGRectMake(20, 0, _W, 30);
    label.text =  _MArray[row];
    
    return label;
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _MArray.count;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return _MArray[row];
    
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    _OrderSelectedString = _MArray[row];
    
}


@end
