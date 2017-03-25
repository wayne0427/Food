//
//  LoginViewController.m
//  Food
//
//  Created by 鄭偉強 on 2016/10/12.
//  Copyright © 2016年 Wei. All rights reserved.
//
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "LoginViewController.h"
#import "Helper.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "ServerCommunicator.h"

@interface LoginViewController ()< FBSDKLoginButtonDelegate,UITextFieldDelegate>
{
    Helper * helper;
}

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *FbLoginView;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //登出用  還要改
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    if (!error) {
    // Sign-out succeeded
       [FBSDKAccessToken setCurrentAccessToken:nil]; 
    }
    
    
    helper = [Helper sharedInstance];
    
    
    self.FbLoginView.readPermissions =
    @[@"public_profile", @"email", @"user_friends"];
    
    
    //fb登入後做的事情
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goMainView) name:@"doneLogin" object:nil];
    
    
    //直接登入成功的通知
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goMainView) name:@"singInDone" object:nil];
    
    
    
    
}


-(void)goMainView{
    

    
    [SVProgressHUD dismiss];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UITabBarController * myTabBarVC = [storyboard instantiateViewControllerWithIdentifier:@"TabBarVC"];
    
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.window.rootViewController = myTabBarVC;
    [app.window makeKeyAndVisible];
    
}



-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        YourViewController *v = [[YourViewController alloc] init];
//        [self presentViewController:v animated:YES completion:^{}];
//    });
    
    if ([helper uidOfCurrentUser]) {

        
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        UITabBarController * myTabBarVC = [storyboard instantiateViewControllerWithIdentifier:@"TabBarVC"];
        
        AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        app.window.rootViewController = myTabBarVC;
        [app.window makeKeyAndVisible];
        
        
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)emailLoginBtn:(id)sender {
    
        
    NSString * emailString = self.emailTextField.text;
    NSString * passwordString = self.passwordTextField.text;
    
    [helper signInWithEmail:emailString password:passwordString];
    
    
}


- (IBAction)createAccBtn:(id)sender {
    
//    NSString * emailString = self.emailTextField.text;
//    NSString * passwordString = self.passwordTextField.text;
//    
//    [helper signUpWithEmail:emailString password:passwordString];
//    
//    [self setNameAlert];
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - FaceBook login Delegate



- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error{
    
    
    if (error) {
        NSLog(@"error: %@",error.description);
    }else if (result.isCancelled){
        NSLog(@"user cancel");
    }else{
        
        //-------------for firebase-------------//
        NSLog(@"%@",[FBSDKAccessToken currentAccessToken].tokenString);
        
        
        [helper loginWithCredential:[FBSDKAccessToken currentAccessToken].tokenString];
        
                //------------ for facebook------------//
        //可在這邊貼一個veiw?
        self.FbLoginView.hidden = true;
        [SVProgressHUD show];
        
    }
    
    
}


- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
    NSLog(@"did tapped fb log out");
    
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return true;
}




@end
