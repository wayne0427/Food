//
//  ManagerViewController.m
//  Food
//
//  Created by 鄭偉強 on 2016/11/16.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "ManagerViewController.h"
#import "Helper.h"
#import "RestaurantInfo.h"
#import "restaurantInfoCell.h"
#import "RestaurantModel.h"
#import "DetailTableViewController.h"

@interface ManagerViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    //靠此manager 拿到網路資料
    RestaurantInfo * restaurantManager;
    Helper * helper;
    
}


@property (nonatomic, strong) NSMutableArray *myRestaurants;
@property (nonatomic, strong) NSMutableArray *myRestaurantUids;


@end

@implementation ManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    helper = [Helper sharedInstance];
    
    
     _managerTableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"foodBG.png"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    restaurantManager = [RestaurantInfo sharedInstance];
    
    [restaurantManager getMyRestaurantArray:^(NSMutableArray *result) {
        
        self.myRestaurantUids = [restaurantManager getMyRestaurantUids];
        
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:result.count];
        
        for (NSDictionary *dict in result) {
            RestaurantModel *tg = [RestaurantModel tgWithDict:dict];
            [models addObject:tg];
        }
        
        //不能用copy 要刪除
        self.myRestaurants = models;
        
        [self.managerTableView reloadData];
        
    }];

    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.myRestaurants.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    restaurantInfoCell *cell = [restaurantInfoCell cellWithTableView:tableView];
    
    
    // 取出對應模型
    RestaurantModel *tg = self.myRestaurants[indexPath.row];
    // 設置模型數據给cell 重寫set 方法
    cell.tg = tg;
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    
}




-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"即將刪除你所創建的餐廳" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * ok =[UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            
            //do delete job..
            
            NSString * uid = self.myRestaurantUids[indexPath.row];
            
            [helper deleteRestaurantByUid:uid done:^(NSError *error, BOOL result) {
                
                if (error) {
                    NSLog(@"刪除出問題了");
                }else{
                    NSLog(@"刪除成功");
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"doneDeleteRestaurant" object:nil];
                    
                }
                
            }];
            
            
            [self.myRestaurants removeObjectAtIndex:indexPath.row];
            
            [self.managerTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        [self presentViewController:alert animated:true completion:nil];
        
        
    
    }
    
    
}


//防止編輯模式 cell縮排
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return false;
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
