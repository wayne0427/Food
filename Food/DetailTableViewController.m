//
//  DetailTableViewController.m
//  Food
//
//  Created by 鄭偉強 on 2016/10/18.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "DetailTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FoodView.h"
#import "RestaurantInfo.h"
#import "Helper.h"
#import "SVProgressHUD.h"
#import "AddMenuViewController.h"
#import "AppDelegate.h"
#import "RestaurantsTableViewController.h"
#import "PSNumberPad.h"
#import "PersonalAddMenuViewController.h"


@interface DetailTableViewController ()<UITextFieldDelegate>
{
    Helper * helper;
    RestaurantInfo * restaurantManager;
    
    //傳送給 新增餐廳
    NSDictionary * createInfo;
    
    UIBarButtonItem * favorBtn;
    BOOL favorBtnIsPressed;
    
    //for personal add menu controller
    
    NSMutableArray * foodItemsArray;
}

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *restaurantName;
@property (weak, nonatomic) IBOutlet UILabel *restaurantAddress;
@property (weak, nonatomic) IBOutlet UILabel *restaurantPhone;
@property (weak, nonatomic) IBOutlet UIScrollView *foodItemsScrollView;

@property (weak, nonatomic) IBOutlet UIButton *starBtn;


@property (strong, nonatomic) IBOutlet UITableView *detailTableView;

@end

@implementation DetailTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.detailTableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"riceBG.png"]];
    
    
    helper = [Helper sharedInstance];
    restaurantManager = [RestaurantInfo sharedInstance];
    
    
    //判斷是否有按過星星
    
    [[[helper getDatabaseRefOfRestaurants]child:self.selectedUid]observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary * tappedRestaurantDict = snapshot.value;
        
        NSDictionary * starUsers = tappedRestaurantDict[@"stars"];
        
        NSString * btnText = starUsers[[helper uidOfCurrentUser]] ? @"★" : @"☆";
        
        self.starBtn.titleLabel.text = btnText;
        
    }];
    
    
    //判斷是否有按過收藏
    NSArray * temp = [[NSUserDefaults standardUserDefaults]objectForKey:ARRAY_FAVOR_KEY];
    
    if (temp) {
        if ([temp containsObject:self.selectedUid]) {
            favorBtn = [[UIBarButtonItem alloc]initWithTitle:@"取消收藏" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonPressed)];
            favorBtn.tintColor = [UIColor redColor];
            
            //important
            favorBtnIsPressed  = true;
            
        }else{
            favorBtn = [[UIBarButtonItem alloc]initWithTitle:@"收藏" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonPressed)];
            favorBtn.tintColor = [UIColor blueColor];
        }

        
    }else{
         favorBtn = [[UIBarButtonItem alloc]initWithTitle:@"收藏" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonPressed)];
         favorBtn.tintColor = [UIColor blueColor];
        
    }
    
    
    self.navigationItem.rightBarButtonItem = favorBtn;
    
    
    
    //觀察創造菜單上傳成功時
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goAddMenu) name:@"Created" object:nil];
    
    //拿到foodItem 列表
    [restaurantManager getRestaurantFoodItemArrayWithUid:self.selectedUid handler:^(NSMutableArray *result) {
        
        
        foodItemsArray = [NSMutableArray new];
        
        //------------------------------------------
        CGFloat width = 130;
        CGFloat height = 240;
       
        //取出 每個item 字典
        for (int i = 0; i < result.count; i++) {
            
            NSDictionary * each = result[i];
           
            
            NSString * foodName = each[@"FoodName"];
            
            NSString * foodPrice = each[@"FoodPrice"];
            NSString * foodPriceWithDollar =[NSString stringWithFormat:@"﹩%@",foodPrice];
            
            NSString * foodImageString = each[@"FoodImageString"];
            
            
            NSURL * imageUrl = [NSURL URLWithString:foodImageString];
            
            
            //創出一個imageView
            UIImageView * eachimage = [[UIImageView alloc]init];
            eachimage.frame = CGRectMake(width * i, 0, width, height);
            
            
            [eachimage sd_setImageWithURL:imageUrl placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                //下載完成圖片後 在創出自己類別的組合view 並加入 scroll view
                FoodView * view1 = [[FoodView alloc]initWithFoodView:eachimage.image fdname:foodName fdPrice:foodPriceWithDollar];
                
                view1.frame = CGRectMake(width * i, 0, width, height);
                
                
                [self.foodItemsScrollView addSubview:view1];
                
                
                NSData * eachimageData = UIImageJPEGRepresentation(eachimage.image, 1);
                
                //增加資料給個人點餐
                NSDictionary * personalFoodItem = @{@"foodName":foodName,@"foodPrice":foodPrice,@"foodImage":eachimageData};
                
                [foodItemsArray addObject:personalFoodItem];
                
                
            }];
            
            
        }
        
        //可滑動的長度
        self.foodItemsScrollView.contentSize = CGSizeMake(result.count * width, 0);
        //-----------------------------------------
        
        
    }];
    
    
    //-------------------------傳值可解決的區--------------------------------//
    
    NSString * shopNameString = [NSString stringWithFormat:@"店名:%@",self.detail.ShopName];
    NSString * shopAddressString = [NSString stringWithFormat:@"%@",self.detail.ShopAddress];
    NSString * shopPhoneString = [NSString stringWithFormat:@"%@",self.detail.ShopPhone];
    
    
    _restaurantName.text = shopNameString;
    _restaurantAddress.text = shopAddressString;
    _restaurantPhone.text = shopPhoneString;
    
    NSURL *mainImageURL = [NSURL URLWithString:self.detail.MainImage];
    
    [_mainImageView setShowActivityIndicatorView:YES];
    [_mainImageView setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [_mainImageView sd_setImageWithURL:mainImageURL placeholderImage:[UIImage imageNamed:@"unknow.png"]];
    
    NSLog(@"該細節頁面餐廳的Uid: %@",self.selectedUid);
    //---------------------------------------------------------------------//
    
    
    
    
    
    
}


- (IBAction)goGoogleNavigation:(UIButton *)sender {
    
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        
        NSString *shopAddress = self.detail.ShopAddress;
        
        NSString *url = [NSString stringWithFormat:@"comgooglemaps://?daddr=%@&directionsmode=driving",shopAddress];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
        
        
    } else {
        NSLog(@"Can't use comgooglemaps://");
    }
    
    
}




-(void)barButtonPressed{
    
    if (!favorBtnIsPressed) {
        
        //按下收藏之後要做的事情
        //step1 拿到目前資料
        NSArray * temp = [[NSUserDefaults standardUserDefaults]objectForKey:ARRAY_FAVOR_KEY];
        NSMutableArray * allFavorArray = [[NSMutableArray alloc]initWithArray:temp];
        
        if (allFavorArray) {
           
            [allFavorArray addObject:self.selectedUid];
            [[NSUserDefaults standardUserDefaults]setObject:allFavorArray forKey:ARRAY_FAVOR_KEY];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
        }else{
            NSMutableArray * newArray = [NSMutableArray new];
            [newArray addObject:self.selectedUid];
            [[NSUserDefaults standardUserDefaults]setObject:allFavorArray forKey:ARRAY_FAVOR_KEY];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
        favorBtn.title = @"取消收藏";
        favorBtn.tintColor = [UIColor redColor];
        
        favorBtnIsPressed  = true;
       
        
    }else{
        
        //取消收藏之後要做的事情
        //step1 拿到defaults 所有餐廳
        NSArray * temp = [[NSUserDefaults standardUserDefaults]objectForKey:ARRAY_FAVOR_KEY];
        NSMutableArray * allFavorArray = [[NSMutableArray alloc]initWithArray:temp];
        
        //step2 取消的餐廳uid
        NSString * deleteString = self.selectedUid;
        
        [allFavorArray removeObject:deleteString];
        
        //step3 更defaults資料
        [[NSUserDefaults standardUserDefaults]setObject:allFavorArray forKey:ARRAY_FAVOR_KEY];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        favorBtn.title = @"收藏";
        favorBtn.tintColor = [UIColor blueColor];
        
        favorBtnIsPressed  = false;
        
    }
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if (section == 0) {
        return 3;
    }
    
    
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    
        
}


#pragma mark - Alert

-(void)goAskAlert{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"是否設定密碼" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //[self dismissViewControllerAnimated:true completion:nil];
        [self goSetPasswordAlert];
        
    }];
    
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        //[self dismissViewControllerAnimated:true completion:nil];
        [self prepareInfoWithPassword:nil];
        
    }];
    
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:true completion:nil];
    
}



-(void)wrongPasswordAlert{
    
    UIAlertController * wrongPasswordAlert = [UIAlertController alertControllerWithTitle:@"錯誤" message:@"密碼格式錯誤" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * okBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //[self dismissViewControllerAnimated:true completion:nil];
        [self goSetPasswordAlert];
        
    }];
    
    [wrongPasswordAlert addAction:okBtn];
    
    [self presentViewController:wrongPasswordAlert animated:true completion:nil];
}



-(void)goSetPasswordAlert{
    //user want to set password
    
    
    //PSNumberPad * numberPad = [[PSNumberPad alloc] init];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"請輸入四位數密碼" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        
        
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.tag = 1;
        textField.placeholder = @"四位數密碼";
        textField.delegate = self;
        
        
        
    }];
    
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // get pass word
        NSString *input = alert.textFields[0].text;
        
        NSLog(@"input: %@",input);
        
        if (input.length == 4) {
            
            
            [self prepareInfoWithPassword:input];
            NSLog(@"正確");
            
        }else{
            
            NSLog(@"不正確,需跳提示");
            
            //[self dismissViewControllerAnimated:true completion:nil];
            [self wrongPasswordAlert];
        }
        
       

        
        
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
    
    
}


#pragma mark - BUTTON PRESSED

- (IBAction)addMenuBtnPressed:(id)sender {
    
    [self goAskAlert];
    
}

-(void)prepareInfoWithPassword:(NSString*)password{
    
    //add password or not
    
    NSString * passwordString;
    if (password == nil) {
        passwordString = @"";
    }else{
        passwordString = password;
    }
    
    
    //------------------------------------------------------
       NSString *user = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    
        NSString * menuUid = [helper getRandomChild];
    
        //存該新的 menuUid 到 userDefaults
        [[NSUserDefaults standardUserDefaults]setObject:menuUid forKey:@"menuUid"];
        //存該Restaurant key 到 userDefaults
    
        [[NSUserDefaults standardUserDefaults]setObject:self.selectedUid forKey:@"SelectedRestaurant"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    
    
        //拿到現在時間
        NSDate * lastTime = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *strDate = [dateFormatter stringFromDate:lastTime];
    
    
    
    
        NSDictionary * menu = @{@"Creater":user,
                                @"SelectedRestaurant":self.selectedUid,
                                @"ShopName":self.detail.ShopName,
                                @"ShopPhone":self.detail.ShopPhone,
                                @"TotalPrice":@"0",
                                @"MyPrice":@"0",
                                @"CreateTime":strDate,
                                @"Password":passwordString
                                };
    
        //for create info
    
        createInfo = menu;
    
    
    
        [helper createMenuWith:menuUid menuItialize:menu];
    
        //if ok , execute goAddMenu method
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:@"創建訂單中"];
    
}


- (IBAction)addPersonalMenuBtnPressed:(UIButton *)sender {
    
    NSString *user = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    
    
    NSDate * lastTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:lastTime];
    
    NSDictionary * menu = @{@"Creater":user,
                            @"ShopName":self.detail.ShopName,
                            @"ShopPhone":self.detail.ShopPhone,
                            @"CreateTime":strDate
                            };
    
    //for create info
    
    createInfo = menu;
    
    
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PersonalAddMenuViewController * addMenuVC = [storyBoard instantiateViewControllerWithIdentifier:@"PersonalAddMenuViewController"];
    addMenuVC.menuCreateInfo = createInfo;
    addMenuVC.fooditemsArray = foodItemsArray;
    
    [self presentViewController:addMenuVC animated:true completion:nil];

    
    
}



//-(void)viewDidDisappear:(BOOL)animated{
//    [super viewDidDisappear:animated];
//    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    AddMenuViewController * addMenuVC = [storyBoard instantiateViewControllerWithIdentifier:@"AddMenuViewController"];
//    addMenuVC.menuCreateInfo = createInfo;
//    
//    [self presentViewController:addMenuVC animated:true completion:nil];
//}

-(void)goAddMenu{
    
    [SVProgressHUD dismiss];
    
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddMenuViewController * addMenuVC = [storyBoard instantiateViewControllerWithIdentifier:@"AddMenuViewController"];
    addMenuVC.menuCreateInfo = createInfo;
    
    [self presentViewController:addMenuVC animated:true completion:nil];
    

}


- (IBAction)addStarBtnPressed:(id)sender {
    

    [helper incrementStarsForRef:[[helper getDatabaseRefOfRestaurants]child:self.selectedUid]];
    
    
    if ([self.starBtn.titleLabel.text isEqualToString:@"★"]) {
        
        [self.starBtn setTitle:@"☆" forState:UIControlStateNormal];
        
    }else{
        [self.starBtn setTitle:@"★" forState:UIControlStateNormal];
       
    }
    
    
}



/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//-(void)passwordTextFieldPressed{
//    
//    
//    [self.view endEditing:true];
//    
//}

//-(void)textFieldDidEndEditing:(UITextField *)textField{
//    
//    if (textField.tag == 1) {
//        
//        //get password
//        NSString * userPassword = textField.text;
//        
//        [self prepareInfoWithPassword:userPassword];
//        
//        
//        [self dismissViewControllerAnimated:true completion:nil];
//        
//        
//    }
//    
//}
@end
