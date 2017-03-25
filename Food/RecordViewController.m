//
//  RecordViewController.m
//  Food
//
//  Created by 鄭偉強 on 2016/10/25.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "RecordViewController.h"
#import "DialView.h"

@interface RecordViewController ()
@property (weak, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createrNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (weak, nonatomic) IBOutlet UITextView *ordersTextView;
@property (weak, nonatomic) IBOutlet UILabel *shopPhoneLabel;

@property (weak, nonatomic) IBOutlet UIButton *leaveBtnView;
@property (weak, nonatomic) IBOutlet UIButton *dialBtnView;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@",self.fromTableViewString);
    
    if ([self.fromTableViewString isEqualToString:@"1"]) {
        self.leaveBtnView.alpha = 0;
    }
    
    
    
    self.restaurantNameLabel.text = [NSString stringWithFormat:@"商店名稱:%@",self.recordDict[@"restaurantName"]];
    
    
    self.createrNameLabel.text = [NSString stringWithFormat:@"建立者:%@",self.recordDict[@"createrName"]];
    
    self.shopPhoneLabel.text = [NSString stringWithFormat:@"商店電話:%@",self.recordDict[@"restaurantPhone"]];
    
    
    self.createTimeLabel.text = [NSString stringWithFormat:@"訂單建立時間:%@",self.recordDict[@"createTime"]];
    
    
    
    NSArray * orderArray = self.recordDict[@"orderArray"];
    for (int i = 0; i < orderArray.count; i++) {
        NSString * eachOrderString = orderArray[i];
        
        self.ordersTextView.text = [self.ordersTextView.text stringByAppendingFormat:@"%@\n",eachOrderString];
    }
    
    self.ordersTextView.text = [self.ordersTextView.text stringByAppendingFormat:@"\n總計:%@元\n",self.recordDict[@"totalPrice"]];
    
    self.ordersTextView.textColor = [UIColor whiteColor];
    self.ordersTextView.font = [UIFont systemFontOfSize:18];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)leaveBtnPressed:(id)sender {
    
    UIViewController *vc = self.presentingViewController;
    
    while (vc.presentingViewController) {
        
        vc = vc.presentingViewController;
        
    }
    
    [vc dismissViewControllerAnimated:YES completion:NULL];
    
}
- (IBAction)goDialBtnPressed:(UIButton *)sender {
    
    
    
    NSArray* nibView = [[NSBundle mainBundle] loadNibNamed:@"DialView" owner:nil options:nil];
    
    DialView * dialView = [nibView firstObject];
    
    dialView.phoneNumberLabel.text = self.recordDict[@"restaurantPhone"];
    
    
    dialView.transform = CGAffineTransformMakeScale(1.3,1.3);
    dialView.center = self.view.center;
    
    [self.view addSubview:dialView];
    

    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        dialView.transform = CGAffineTransformMakeScale(1.0,1.0);
        
    } completion:nil];
    
    self.dialBtnView.enabled = NO;
    
    dialView.dialBlock = ^(NSString *goString){
        
        if ([goString isEqualToString:@"go"]) {
            
            self.dialBtnView.enabled = YES;
        }
    
    };
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
