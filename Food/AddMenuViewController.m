//
//  AddMenuViewController.m
//  Food
//
//  Created by 鄭偉強 on 2016/10/19.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "AddMenuViewController.h"
#import "UserCollectionViewCell.h"
#import "Helper.h"
#import "RestaurantInfo.h" //拿到點餐列表
#import "OrderPickerView.h"
#import "orderListTableViewCell.h"
#import "RecordViewController.h"




@interface AddMenuViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    //顯示當下裡面使用者
    NSMutableArray * usersArray;
    
    //拿到最後整理好的品項array
    NSMutableArray * menuArray;
    
    //判斷是否status 全部都ok
    NSMutableArray * statusOkArray;
    
    //拿到使用者點餐資訊array
    NSMutableArray * usersOrderArray;
    
    
    //createInfo 資訊
    NSDictionary * createInfo;
    
    //顯示label
    NSString * createrName;
    
    //for cancelBtn
    NSUInteger cancelNumber;
    
    //if sendbtn pressed, use this judge delete or not at didDisappear
    NSUInteger sendNumber;
    
    //for record
    NSMutableArray * recordArray;
    
    
    Helper * helper;
    RestaurantInfo * restaurantManager;
    
    
}

@property (nonatomic,assign) ToThisViewType typeVar;

@property (weak, nonatomic) IBOutlet UICollectionView *usersCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *orderLabel;

//top view link
@property (weak, nonatomic) IBOutlet UILabel *orderCreaterLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderRestaurantLabel;


@property (weak, nonatomic) IBOutlet UIButton *sendOrderBtnView;
@property (weak, nonatomic) IBOutlet UIButton *chooseOrderBtnView;
@property (weak, nonatomic) IBOutlet UIButton *okBtnView;

@property (weak, nonatomic) IBOutlet UITableView *orderlistTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *showFinishLabel;

@end

@implementation AddMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
//    self.orderlistTableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"blackBG.png"]];
//    self.orderlistTableView.backgroundView.alpha = 0.3;
    
    
    
    self.usersCollectionView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"userLine2.png"]];
    
    
    cancelNumber = 1;
    
    //for create use
   
    
    self.showFinishLabel.text = @"";
    
    // selecter listen if creater leave
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(quitThisPage) name:@"noUser" object:nil];
    // listen creater leave
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(quitThisPage) name:@"createrLeave" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goRecord) name:@"sendMenu" object:nil];
    
    
    restaurantManager = [RestaurantInfo sharedInstance];
    helper = [Helper sharedInstance];
    
    //判斷從哪邊進來的
    if (self.selectedOrderKeyString) {
        self.typeVar = ToThisViewTypeFromSelected;
    }else{
        self.typeVar = ToThisViewTypeFromCreate;
    }
    
    
    //執行方法拿到所有進來的人 持續監控~!!!!!!!!!!!!!
    [self getUserArray:self.typeVar];
    

    //執行方法拿到當下餐廳餐點用的品項array
    [self getFoodItems:self.typeVar];
    
    //handle sender btn
    
    if (self.typeVar == ToThisViewTypeFromSelected) {
        self.sendOrderBtnView.alpha = 0;
    }else{
        self.sendOrderBtnView.enabled = false;
        self.sendOrderBtnView.alpha = 0.5;
    }
    
    //持續觀察totalPrice
    [self observeTotalPriceLabel:self.typeVar];
    
    //持續觀察orderList
    [self observeOrderListForTableView:self.typeVar];
    
    //觀察是否按送出
    [self observerSendNotice:self.typeVar];
    
    [self getCreateInfo:self.typeVar];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //[self.usersCollectionView reloadData];
    
}


-(void)getFoodItems:(ToThisViewType)type{
    
    if (type == ToThisViewTypeFromSelected){
        
        [restaurantManager getRestaurantFoodItemArrayWithUid:self.SelectedRestaurantUid handler:^(NSMutableArray *result) {
            
            menuArray = [NSMutableArray new];
            
            
            for (int i = 0; i < result.count; i++) {
                NSDictionary * eachItem = result[i];
                
                NSString * foodName = eachItem[@"FoodName"];
                NSString * foodPrice = eachItem[@"FoodPrice"];
                
                NSString * showItem = [NSString stringWithFormat:@"%@ %@元",foodName,foodPrice];
                
                [menuArray addObject:showItem];
                
            }
            
        }];

        
    }else{
        
        NSString * RestaurantUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"SelectedRestaurant"];
        
        [restaurantManager getRestaurantFoodItemArrayWithUid:RestaurantUid handler:^(NSMutableArray *result) {
            
            menuArray = [NSMutableArray new];
            
            for (int i = 0; i < result.count; i++) {
                NSDictionary * eachItem = result[i];
                
                NSString * foodName = eachItem[@"FoodName"];
                NSString * foodPrice = eachItem[@"FoodPrice"];
                
                NSString * showItem = [NSString stringWithFormat:@"%@ %@元",foodName,foodPrice];
                
                [menuArray addObject:showItem];
                
            }
            
        }];
        
    }
    
}

-(void)getCreateInfo:(ToThisViewType)type{
    
    if (type == ToThisViewTypeFromSelected){
        
        [restaurantManager getCreateMenuInfo:self.selectedOrderKeyString handler:^(NSDictionary *result) {
            
            createInfo = result;
            NSLog(@"XDXD%@",createInfo);
            NSLog(@"....");
            
            NSString * createrString = [NSString stringWithFormat:@"建立者:%@",createInfo[@"Creater"]];
            NSString * restautantString = [NSString stringWithFormat:@"店家:%@",createInfo[@"ShopName"]];
            
            self.orderCreaterLabel.text = createrString;
            self.orderRestaurantLabel.text = restautantString;
            
        }];
        
    }else{
        
        NSLog(@"CCCCCCC:%@",self.menuCreateInfo);
        
        NSString * createrString = [NSString stringWithFormat:@"建立者:%@",self.menuCreateInfo[@"Creater"]];
        NSString * restautantString = [NSString stringWithFormat:@"店家:%@",self.menuCreateInfo[@"ShopName"]];
        
        self.orderCreaterLabel.text = createrString;
        self.orderRestaurantLabel.text = restautantString;
        
        
    }
    
}



-(void)observeOrderListForTableView:(ToThisViewType)type{
    
    if (type == ToThisViewTypeFromSelected) {
        
        //拿到使用者點餐資訊array
        //NSMutableArray * usersOrderArray;
        [restaurantManager getOrderListArrayWithUid:self.selectedOrderKeyString handler:^(NSMutableArray *result) {
            
            usersOrderArray = result;
            
            [self.orderlistTableView reloadData];
            
        }];
       
    }else{
        NSString * createdMenuUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuUid"];
        
        [restaurantManager getOrderListArrayWithUid:createdMenuUid handler:^(NSMutableArray *result) {
            
            usersOrderArray = result;
            
            [self.orderlistTableView reloadData];
            
            
        }];
        
    }
    
}

-(void)observeTotalPriceLabel:(ToThisViewType)type{
    
    if (type == ToThisViewTypeFromSelected) {
        
        [restaurantManager getTotalPriceWithMenuUid:self.selectedOrderKeyString handler:^(NSString *result) {
            
            NSString * totalPriceFinal = [NSString stringWithFormat:@"%@",result];
            
            self.totalPriceLabel.text = totalPriceFinal;
            
        }];
        
    }else{
         NSString * createdMenuUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuUid"];
        
        [restaurantManager getTotalPriceWithMenuUid:createdMenuUid handler:^(NSString *result) {
            
            NSString * totalPriceFinal = [NSString stringWithFormat:@"%@",result];
            
            self.totalPriceLabel.text = totalPriceFinal;
            
        }];

    }
    
}



-(void)getUserArray:(ToThisViewType)type{
    
    if (type == ToThisViewTypeFromSelected) {
        
        //顯示當下使用者用 (包含自己)
        [[[helper getDatabaseRefOfMenuUsers]child:self.selectedOrderKeyString]observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            usersArray = [NSMutableArray new];
            
            
            NSDictionary * resultDict = snapshot.value;
            
            if ([resultDict isEqual:[NSNull null]]) {
                NSLog(@"沒用戶了");
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"noUser" object:nil];
                
            }else{
                
                for (NSString * userUid in resultDict) {
                    
                    NSDictionary * eachUser = resultDict[userUid];
                   [usersArray addObject:eachUser];
                   
                }
                
                [self.usersCollectionView reloadData];
                
                
            }
            
        }];
        
        
    }else{
        //從 create menu
        
        NSString * createdMenuUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuUid"];
        
        //顯示當下使用者用 (包含自己)
        [[[helper getDatabaseRefOfMenuUsers]child:createdMenuUid]observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            usersArray = [NSMutableArray new];
            
            statusOkArray = [NSMutableArray new];
            
            NSDictionary * resultDict = snapshot.value;
            
            if ([resultDict isEqual:[NSNull null]]) {
                NSLog(@"沒用戶了");
                NSLog(@"沒用戶了");
            }else{
                
                for (NSString * userUid in resultDict) {
                    
                    NSDictionary * eachUser = resultDict[userUid];
                    [usersArray addObject:eachUser];
                    
                    //算綠燈數量
                    NSString * eachStatus = eachUser[@"SelfStatus"];
                    if ([eachStatus isEqualToString:@"1"]) {
                        [statusOkArray addObject:eachStatus];
                    }
                    
                    
                }
                //判斷是否全部按ok的時候
                if (usersArray.count == statusOkArray.count) {
                    self.sendOrderBtnView.alpha = 1;
                    self.sendOrderBtnView.enabled = true;
                }else{
                    self.sendOrderBtnView.alpha = 0.5;
                    self.sendOrderBtnView.enabled = false;
                    
                }
                
                
                [self.usersCollectionView reloadData];
               
                
            }
            
            
        }];
        
    }
    
}


-(void)observerSendNotice:(ToThisViewType)type{
    if (type == ToThisViewTypeFromSelected){
        
        [[[helper getDatabaseRefOfMenuNotice]child:self.selectedOrderKeyString]observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary * notice = snapshot.value;
            
            if ([notice isEqual:[NSNull null]]) {
                NSLog(@"沒東西");
            }else{
                NSLog(@"有通知了");
                [[NSNotificationCenter defaultCenter]postNotificationName:@"sendMenu" object:nil];
            }
            
            
        }];
        
    }else{
        
        NSString * createdMenuUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuUid"];
        [[[helper getDatabaseRefOfMenuNotice]child:createdMenuUid]observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary * notice = snapshot.value;
            if ([notice isEqual:[NSNull null]]) {
                NSLog(@"沒東西");
            }else{
                NSLog(@"有通知了");
                [[NSNotificationCenter defaultCenter]postNotificationName:@"sendMenu" object:nil];
            }
            
        }];
        
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc{
    NSLog(@"AddmenuController dealloc");
    NSLog(@"AddmenuController dealloc");
}

#pragma mark - CollectionView Delegate Medthod

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return usersArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    
    NSDictionary * each = usersArray[indexPath.row];
    
    cell.userNameLabel.text = each[@"UserName"];
    
    
    NSString * status = each[@"SelfStatus"];
    
    if ([status isEqualToString:@"0"]) {
         cell.userImage.layer.borderColor = [UIColor redColor].CGColor;
        
        
    }else if ([status isEqualToString:@"1"]){
        cell.userImage.layer.borderColor = [UIColor greenColor].CGColor;
        
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    
    return cell;
    
}

#pragma mark - TableView Delegate Medthod

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return usersOrderArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    orderListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary * eachOrder = usersOrderArray[indexPath.row];
    
    NSString * orderString = eachOrder[@"Order"];
    NSString * userName = eachOrder[@"UserName"];
    
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.singleOrderLabel.text = [NSString stringWithFormat:@"%@ 點了 %@",userName,orderString];
    
    //cell.singleOrderLabel.tintColor = [UIColor whiteColor];
    
    
    
    return cell;
}


#pragma mark - Picker View Button Pressed Method
- (IBAction)orderBtnPressed:(id)sender {
    
    _orderLabel.text = @"尚未點餐";
    
    //--------------------------------------------------------------//
    
    UIView * view1 = [[UIView alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height)];
    
    view1.backgroundColor = [UIColor blackColor];
    view1.alpha = 0.9;
    
    [self.view addSubview:view1];
    
     //--------------------------------------------------------------//
    
    OrderPickerView *pickerView =  [[OrderPickerView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
    pickerView.center = view1.center;
    
    
    pickerView.pickerBlock = ^(NSString *selectedOrder){
        
        
        if ([selectedOrder isEqualToString:@"cancel"]) {
            [view1 removeFromSuperview];
            
        }else{
            _orderLabel.text = selectedOrder;
            NSLog(@"******%@*******",selectedOrder);
            
            cancelNumber = 2;
            _showFinishLabel.text = @"請確認你的餐點";
            
            [view1 removeFromSuperview];
            
        }
        
        
        
        
    };
    
    //將餐點資料灌入下載到的array;
    pickerView.MArray = menuArray;
    
    [view1 addSubview:pickerView];
    
}

#pragma mark - ViewController Button Pressed Method

- (IBAction)okBtn:(id)sender {
    
    cancelNumber = 3;
    
    if ([_orderLabel.text isEqualToString:@"尚未點餐"]) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"尚未選擇餐點" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            cancelNumber = 1;
        }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
        
        
    }else{
         //點ok後  上傳清單到 table view
        [self uploadSelfOrder:self.typeVar];
        
         //計算完後 上傳final Price到該地點
        [self uploadFinalPriceFromAdd:self.typeVar];
        
        
        //自己頁面調整
        if (self.typeVar == ToThisViewTypeFromSelected) {
            self.showFinishLabel.text = @"點餐完成，請等待其他人，頁面將自動跳轉";
        }else{
            self.showFinishLabel.text = @"點餐完成，請等待其他人，再按送出";
        }
        
        
       
        
        //小綠人
        NSString * okStatusString = @"1";
        [self changeStauts:okStatusString];
        
        //按確定後不給點了
        self.chooseOrderBtnView.alpha = 0.5;
        self.chooseOrderBtnView.userInteractionEnabled = false;
        self.chooseOrderBtnView.enabled = false;
        
        self.okBtnView.alpha = 0.5;
        self.okBtnView.userInteractionEnabled = false;
        self.okBtnView.enabled = false;
        
    }
    
}



-(void)uploadFinalPriceFromAdd:(ToThisViewType)type{
    
    NSString * finalTotalString = [self countTotalPriceFromAdd:self.totalPriceLabel.text add:self.orderLabel.text];
    
    NSDictionary * totalPrice =@{@"TotalPrice":finalTotalString};
    
    
    if (type == ToThisViewTypeFromSelected) {
       
        
        [helper uploadtotalPriceWithUid:self.selectedOrderKeyString andPrice:totalPrice];
        
    }else{
        
         NSString * menuUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuUid"];
        
        [helper uploadtotalPriceWithUid:menuUid andPrice:totalPrice];

        
    }
}


-(void)uploadFinalPriceFromDeleteOrder:(ToThisViewType)type{
    
    NSString * finalTotalString = [self countTotalPriceFromDelete:self.totalPriceLabel.text DeleteString:self.orderLabel.text];
    
    NSDictionary * totalPrice =@{@"TotalPrice":finalTotalString};
    
    
    if (type == ToThisViewTypeFromSelected) {
        
        
        [helper uploadtotalPriceWithUid:self.selectedOrderKeyString andPrice:totalPrice];
        
    }else{
        
        NSString * menuUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuUid"];
        
        [helper uploadtotalPriceWithUid:menuUid andPrice:totalPrice];
       
    }
    
}


-(void)uploadSelfOrder:(ToThisViewType)type{
    
    
    NSString * userName = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    NSString * orderString = self.orderLabel.text;
    
    NSDictionary * orderDict = @{@"UserName":userName,@"Order":orderString};
    
    
    
    if (type == ToThisViewTypeFromSelected) {
        
        [helper uploadUserOrderWithMenuUid:self.selectedOrderKeyString andOrder:orderDict];
        
    
    }else{
        
        NSString * menuUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuUid"];
        
        [helper uploadUserOrderWithMenuUid:menuUid andOrder:orderDict];
        
        
    }
    
}


-(void)deleteSelfOrder:(ToThisViewType)type{
    
    if (type == ToThisViewTypeFromSelected) {
        
        [helper deleteUserOrderWithMenuUid:self.selectedOrderKeyString];
        
        
    }else{
        
        NSString * menuUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuUid"];
        
        [helper deleteUserOrderWithMenuUid:menuUid];
        
    }
    
}




-(NSString*)countTotalPriceFromAdd:(NSString *)CurrentTotal add:(NSString*)add{
    
    NSArray *array = [add componentsSeparatedByString:@" "];
    
    NSString * priceString = array[1];
    
    NSString * currentTotalString = CurrentTotal;
    
    NSInteger priceInt = [priceString integerValue];
    NSInteger currentTotalInt = [currentTotalString integerValue];
    
    currentTotalInt = currentTotalInt + priceInt;
    
    NSString *finalTotalString = [NSString stringWithFormat:@"%ld", (long)currentTotalInt];
    
    return finalTotalString;
    
    
}

-(NSString*)countTotalPriceFromDelete:(NSString *)CurrentTotal DeleteString:(NSString*)deleteString
{
    
    NSArray *array = [deleteString componentsSeparatedByString:@" "];
    
    NSString * priceString = array[1];
    
    NSString * currentTotalString = CurrentTotal;
    NSLog(@"NUmber %@",currentTotalString);
    
    NSInteger priceInt = [priceString integerValue];
    NSInteger currentTotalInt = [currentTotalString integerValue];
    
    currentTotalInt = currentTotalInt - priceInt;
    NSLog(@"NUmber %ld",currentTotalInt);
    
    NSString *finalTotalString = [NSString stringWithFormat:@"%ld", (long)currentTotalInt];
    
    return finalTotalString;
    
    
}

- (IBAction)cancelBtn:(id)sender {
    
    NSString * cancelStatusString = @"0";
    
    [self changeStauts:cancelStatusString];
        
    self.okBtnView.alpha = 1;
    self.okBtnView.userInteractionEnabled = true;
    self.okBtnView.enabled = true;
    
    //取消馬上刪除資料 更新total price
    //利用image判斷重複點擊cancel
    
    
    
    
    if (cancelNumber == 1) {
        NSLog(@"不用執行取消");
    
    }else if(cancelNumber == 2){
        
        
        self.orderLabel.text = @"尚未點餐";
        cancelNumber = 1;
        NSLog(@"第二階段");
        
    }else{
          NSLog(@"第三階段");
        [self uploadFinalPriceFromDeleteOrder:self.typeVar];
        [self deleteSelfOrder:self.typeVar];
         cancelNumber = 1;
        
    }
    
    
    //按下取消開啟可選擇餐點
    self.chooseOrderBtnView.alpha = 1;
    self.chooseOrderBtnView.userInteractionEnabled = true;
    self.chooseOrderBtnView.enabled= true;
    
    self.orderLabel.text = @"尚未點餐";
    self.showFinishLabel.text = @"";
    
}


- (IBAction)sendOrderBtnPressed:(id)sender {
    
     NSString * createdMenuUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuUid"];
    
    //發通知到線上 做方法觀察
    [helper createrUploadSendNotice:createdMenuUid];
    
    sendNumber = 1;
    
}


-(void)changeStauts:(NSString *)statusString{
    
    //一樣判斷從哪邊進來, 才能改 狀態
    
    if (self.typeVar == ToThisViewTypeFromSelected) {
        //from selected order
        
        
        [helper changeStatusWithMenuUid:self.selectedOrderKeyString status:statusString];
        
    }else{
        //from create
        
        NSString * menuUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuUid"];
        
        [helper changeStatusWithMenuUid:menuUid status:statusString];
        
    }
    
}


- (IBAction)quitThisPageBtnPressed:(id)sender {
    
    //刪除記錄 , 分創建者 與 加入者
    if (_typeVar == ToThisViewTypeFromSelected) {
        // selecter leave
        
        if (cancelNumber != 1) {
            
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"離開將會刪除你的點餐" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [helper quitAndDeleteDataFromSelector:self.selectedOrderKeyString];
                [self uploadFinalPriceFromDeleteOrder:self.typeVar];
                
                [self dismissViewControllerAnimated:true completion:nil];
                
            }];
            
            [alert addAction:ok];
            [alert addAction:cancel];
            [self presentViewController:alert animated:true completion:nil];
            
        }else{
            
            [helper quitAndDeleteDataFromSelector:self.selectedOrderKeyString];
            
            //[self uploadFinalPriceFromDeleteOrder:self.typeVar];
            
            [self dismissViewControllerAnimated:true completion:nil];

        };
        

        
    }else{
        // creater leave
         NSString * menuUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuUid"];
        
        [helper quitAndDeleteDataFromCreater:menuUid];
        
    }
    
    
}

-(void)quitThisPage{
    
    if (self.typeVar == ToThisViewTypeFromSelected) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"創立訂單者取消此訂單" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:true completion:nil];
        }];
        
                [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
        
    }else{
        
        //need remove observe
        
        
        [self dismissViewControllerAnimated:true completion:nil];
    }
    
   
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    
    if (self.typeVar == ToThisViewTypeFromSelected) {
        [restaurantManager removeHandlerWithMenuUid:self.selectedOrderKeyString];
        
        [[[helper getDatabaseRefOfMenuUsers]child:self.selectedOrderKeyString]removeAllObservers];
        [[[helper getDatabaseRefOfMenuNotice]child:self.selectedOrderKeyString]removeAllObservers];
        
    }else{
        //remove obersvers
        NSString * menuUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuUid"];
        [restaurantManager removeHandlerWithMenuUid:menuUid];
        
        [[[helper getDatabaseRefOfMenuUsers]child:menuUid]removeAllObservers];
        
        [[[helper getDatabaseRefOfMenuNotice]child:menuUid]removeAllObservers];
        
    }
    
    if (sendNumber == 1) {
        //creater need to delete firebase data
        NSString * createdMenuUid = [[NSUserDefaults standardUserDefaults]objectForKey:@"menuUid"];
        [helper createrSendBtnPressed:createdMenuUid];
    }
    
    
}



-(void)goRecord{
    
    if (self.typeVar == ToThisViewTypeFromSelected){
        //from selected
        //拿到所有基本資料
        NSMutableArray * orderArray = [NSMutableArray new];
        
        NSString * createrNameString = createInfo[@"Creater"];
        NSString * createTimeString = createInfo[@"CreateTime"];
        NSString * restaurantName = createInfo[@"ShopName"];
        NSString * restaurantPhone = createInfo[@"ShopPhone"];
        NSString * totalPriceString = self.totalPriceLabel.text;
        
        for (int i = 0; i < usersOrderArray.count; i++) {
            NSDictionary * eachOrder = usersOrderArray[i];
            
            NSString * orderString = eachOrder[@"Order"];
            NSString * userName = eachOrder[@"UserName"];
            NSString * comboOrderString = [NSString stringWithFormat:@"%@ 點了 %@",userName,orderString];
            [orderArray addObject:comboOrderString];
        }
        
        //組合
        NSDictionary * record = @{@"createrName":createrNameString,
                                  @"createTime":createTimeString,
                                  @"restaurantName":restaurantName,
                                  @"restaurantPhone":restaurantPhone,
                                  @"totalPrice":totalPriceString,
                                  @"orderArray":orderArray};
        
        //for userDefault
        
        NSArray * tmpRecordArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"recordArray"];
        
        if (!tmpRecordArray) {
            recordArray = [NSMutableArray new];
        }else{
            recordArray = [[NSMutableArray alloc]initWithArray:tmpRecordArray];
        }
        
        [recordArray addObject:record];
        
        [[NSUserDefaults standardUserDefaults]setObject:recordArray forKey:@"recordArray"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        //selected go next page
        
        RecordViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
        
        vc.recordDict = record;
        
        [self presentViewController:vc animated:true completion:nil];
        
        
    }else{
        //from creater  self.menuCreateInfo
        NSMutableArray * orderArray = [NSMutableArray new];
        
        NSString * createrNameString = self.menuCreateInfo[@"Creater"];
    
        NSString * createTimeString = self.menuCreateInfo[@"CreateTime"];
        
        NSString * restaurantName = self.menuCreateInfo[@"ShopName"];
        NSString * restaurantPhone = self.menuCreateInfo[@"ShopPhone"];
        NSString * totalPriceString = self.totalPriceLabel.text;
        
        for (int i = 0; i < usersOrderArray.count; i++) {
            NSDictionary * eachOrder = usersOrderArray[i];
            
            NSString * orderString = eachOrder[@"Order"];
            NSString * userName = eachOrder[@"UserName"];
            NSString * comboOrderString = [NSString stringWithFormat:@"%@ 點了 %@",userName,orderString];
            [orderArray addObject:comboOrderString];
        }
        
        //組合
        NSDictionary * record = @{@"createrName":createrNameString,
                                  @"createTime":createTimeString,
                                  @"restaurantName":restaurantName,
                                  @"restaurantPhone":restaurantPhone,
                                  @"totalPrice":totalPriceString,
                                  @"orderArray":orderArray};
        
        NSLog(@"XXXXOOOO%@",record);
        
        //for userDefault
        
        NSArray * tmpRecordArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"recordArray"];
        
        if (!tmpRecordArray) {
            recordArray = [NSMutableArray new];
        }else{
            recordArray = [[NSMutableArray alloc]initWithArray:tmpRecordArray];
        }
        
        [recordArray addObject:record];
        
        [[NSUserDefaults standardUserDefaults]setObject:recordArray forKey:@"recordArray"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
       
        
        // go next page
        
        RecordViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RecordViewController"];
        vc.recordDict = record;
        
        [self presentViewController:vc animated:true completion:nil];
        
        
    }
    
}





@end
