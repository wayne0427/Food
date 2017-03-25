//
//  PersonalAddMenuViewController.m
//  Food
//
//  Created by 鄭偉強 on 2016/11/21.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "PersonalAddMenuViewController.h"
#import "FoodItemsCell.h"
#import "RecordViewController.h"

@interface PersonalAddMenuViewController ()<FoodItemsCellDelegate>
{
    NSUInteger totalPriceNumber;
    
    //for record
    NSMutableArray * recordArray;
}

@property (weak, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *foodItemTableView;

@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

//@property(nonatomic,strong) NSMutableArray * foodListArray;
@property(nonatomic,strong) NSMutableDictionary * foodDict;
@property(nonatomic,strong) NSMutableDictionary * foodDictPrice;

@end

@implementation PersonalAddMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //NSLog(@"Contant:%@",_fooditemsArray);
    
    //---建立food數量model---
    _foodDict = [NSMutableDictionary new];
    _foodDictPrice = [NSMutableDictionary new];
    
    for (NSDictionary * each in _fooditemsArray) {
        NSString * foodName = each[@"foodName"];
        NSString * countString = @"0";
        NSString * foodPriceString = each[@"foodPrice"];
        
        [_foodDict setObject:countString forKey:foodName];
        [_foodDictPrice setObject:foodPriceString forKey:foodName];
        
    }
    //--------
    
    NSLog(@"foodDict:%@",_foodDict);
    
    totalPriceNumber = 0;
    
    NSString * userName = [NSString stringWithFormat:@"建立者:%@",self.menuCreateInfo[@"Creater"]];
    self.userNameLabel.text = userName;
    
    
    NSString * restauratName = [NSString stringWithFormat:@"店家:%@",self.menuCreateInfo[@"ShopName"]];
    self.restaurantNameLabel.text = restauratName;
    
    
    NSString * shopPhoneString = self.menuCreateInfo[@"ShopPhone"];
    NSString * createTimeString = self.menuCreateInfo[@"CreateTime"];
    
    
    //待使用
    NSLog(@"phone: %@",shopPhoneString);
    NSLog(@"time: %@",createTimeString);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendBtnPressed:(UIButton *)sender {
    

    NSMutableArray * orderArray = [NSMutableArray new];
    int i = 1;
    
    for (NSString *foodName in _foodDict) {
        //先拿出來判斷 要是0個 不加入點餐字串陣列
        
        NSString *foodCount = _foodDict[foodName];
        
        if (![foodCount isEqualToString:@"0"]) {
            //非零的話就計算
            
            //個別價格
            NSString * eachPrice = _foodDictPrice[foodName];
            int totoal = [foodCount intValue] * [eachPrice intValue];
            
            //最後組合字串
            NSString * finalString = [NSString stringWithFormat:@"%d.%@ X %@ = %d元",i,foodName,foodCount,totoal];
            
            [orderArray addObject:finalString];
            
            i = i + 1;
        }
        
    }
    
    
    NSString * totalString = [NSString stringWithFormat:@"%lu",totalPriceNumber];
    
    
    NSDictionary * record = @{@"createrName":self.menuCreateInfo[@"Creater"],
                              @"createTime":self.menuCreateInfo[@"CreateTime"],
                              @"restaurantName":self.menuCreateInfo[@"ShopName"],
                              @"restaurantPhone":self.menuCreateInfo[@"ShopPhone"],
                              @"totalPrice":totalString,
                              @"orderArray":orderArray};
    
    
    
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
- (IBAction)quitBtnPressed:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    return _fooditemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    static NSString * ID = @"cell";
    
    FoodItemsCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    
    if (cell == nil){
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FoodItemsCell" owner:nil options:nil]lastObject];
        
    }
    
    
    
    NSDictionary * eachInfo = self.fooditemsArray[indexPath.row];
    
    cell.foodItemsdelegate = self;
    
    cell.foodNameLabel.text = eachInfo[@"foodName"];
    
    NSString * finalPrice = [NSString stringWithFormat:@"$%@",eachInfo[@"foodPrice"]];
    cell.foodPriceLabel.text = finalPrice;
    
    
    cell.foodImage.image = [UIImage imageWithData:eachInfo[@"foodImage"]];
    
    cell.backgroundView.alpha = 0.33;
    
    //重要!! 一開始的字典model發揮作用,重用cell時再給目前的count數據
    NSString * key = eachInfo[@"foodName"];
    NSString * currentCount = _foodDict[key];
    cell.countTextField.text = currentCount;
    
    
    cell.backgroundColor = [UIColor clearColor];
    
    
    return cell;
    
}



-(void)FoodItemsCellView:(FoodItemsCell *)view WithPlus:(NSDictionary *)fooditem{
    
    //總價自己算自己的
    NSString * foodPriceSting = fooditem[@"foodPrice"];
    totalPriceNumber = totalPriceNumber + [foodPriceSting integerValue];
    self.totalPriceLabel.text = [NSString stringWithFormat:@"總計:%lu元",totalPriceNumber];
    
    // 字典存數量  哪個名字先拿到
    NSString * foodNameSting = fooditem[@"foodName"];
    
    //拿到相對應字串
    NSString * foodCurrentCountString = _foodDict[foodNameSting];
    int total = [foodCurrentCountString intValue] + 1;
    
    //存回去
    NSString * foodFinalCountString = [NSString stringWithFormat:@"%d",total];
    
    _foodDict[foodNameSting] = foodFinalCountString;
    
    NSLog(@"%@有多少個:%@",foodNameSting,_foodDict[foodNameSting]);
    
}


-(void)FoodItemsCellView:(FoodItemsCell *)view WithMinus:(NSDictionary *)fooditem{
    
    //總價自己算自己的
    NSString * foodPriceSting = fooditem[@"foodPrice"];
    totalPriceNumber = totalPriceNumber - [foodPriceSting integerValue];
    self.totalPriceLabel.text = [NSString stringWithFormat:@"總計:%lu元",totalPriceNumber];
    
    // 字典存數量  名字先拿到
    NSString * foodNameSting = fooditem[@"foodName"];
    
    //拿到相對應字串
    NSString * foodCurrentCountString = _foodDict[foodNameSting];
    int total = [foodCurrentCountString intValue] - 1;
    
    //存回去
    NSString * foodFinalCountString = [NSString stringWithFormat:@"%d",total];
    
    _foodDict[foodNameSting] = foodFinalCountString;
    
    NSLog(@"%@有多少個:%@",foodNameSting,_foodDict[foodNameSting]);
    
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
