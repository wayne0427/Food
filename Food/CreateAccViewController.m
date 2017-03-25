//
//  CreateAccViewController.m
//  Food
//
//  Created by 鄭偉強 on 2016/10/25.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "CreateAccViewController.h"
#import "Helper.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@interface CreateAccViewController ()<UITextFieldDelegate>

{
    Helper * helper;
}

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation CreateAccViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    helper = [Helper sharedInstance];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goNext) name:@"createAcc" object:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)createBtnPressed:(id)sender {
    
    
    NSString * nameString = self.nameTextField.text;
    NSString * emailString = self.emailTextField.text;
    NSString * passwordString = self.passwordTextField.text;
    
    if ([nameString isEqualToString:@""] || [emailString isEqualToString:@""] || [passwordString isEqualToString:@""]) {
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"帳戶資料未設置完全" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
        
        
        
        
    }else{
        
        if (self.passwordTextField.text.length < 6) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"密碼長度不足六位數" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:nil];
            
            [alert addAction:ok];
            [self presentViewController:alert animated:true completion:nil];
            
        }else{
            
           
            
//            [helper signUpWithEmail:emailString password:passwordString];
              [helper signUpWithEmail:emailString password:passwordString done:^(NSError *error, BOOL result) {
                  
                  
                  //NSString * errorSrting = error.description;
                  
                  UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"email格式錯誤" preferredStyle:UIAlertControllerStyleAlert];
                  
                  UIAlertAction * ok = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:nil];
                  
                  [alert addAction:ok];
                  [self presentViewController:alert animated:true completion:nil];

              }];
            
        }
        
        
       
    }
    
    
    
    
    
    
    
    
//    [[NSUserDefaults standardUserDefaults]setObject:userName forKey:@"userName"];
//    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
//    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    
//    UITabBarController * myTabBarVC = [storyboard instantiateViewControllerWithIdentifier:@"TabBarVC"];
//    
//    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    app.window.rootViewController = myTabBarVC;
//    [app.window makeKeyAndVisible];
    
    
    
}
- (IBAction)cancelBtnPressed:(id)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
}



-(void)goNext{
    
    NSString * userName = self.nameTextField.text;
        [[NSUserDefaults standardUserDefaults]setObject:userName forKey:@"userName"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    NSDictionary * userDict = @{@"UserName":userName};
    
    [helper uploadUserData:userDict];
    
    
    //轉到主頁
    [SVProgressHUD dismiss];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UITabBarController * myTabBarVC = [storyboard instantiateViewControllerWithIdentifier:@"TabBarVC"];
    
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.window.rootViewController = myTabBarVC;
    [app.window makeKeyAndVisible];
    
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return true;
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
