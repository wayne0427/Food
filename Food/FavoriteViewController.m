//
//  FavoriteViewController.m
//  Food
//
//  Created by 鄭偉強 on 2016/11/14.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "FavoriteViewController.h"
#import "Helper.h"
#import "RestaurantInfo.h"  
#import "restaurantInfoCell.h"
#import "RestaurantModel.h"
#import "DetailTableViewController.h"


@interface FavoriteViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    //靠此manager 拿到網路資料
    RestaurantInfo * restaurantManager;
    
}

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _favoriteTableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"foodBG.png"]];
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    restaurantManager = [RestaurantInfo sharedInstance];
    //去網路拿資料 並且會回傳一個array 餐廳到我的block
    
    
    [restaurantManager getFavoriteRestaurantArray:^(NSMutableArray *result) {
        
        self.favorRestaurantUids = [restaurantManager getFavoriteRestaurantUids];
    
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:result.count];
        
        for (NSDictionary *dict in result) {
            RestaurantModel *tg = [RestaurantModel tgWithDict:dict];
            [models addObject:tg];
        }
        
        self.favorRestaurants = [models copy];
        
        
        [self.favoriteTableView reloadData];
    
    }];

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.favorRestaurants.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    restaurantInfoCell *cell = [restaurantInfoCell cellWithTableView:tableView];
    
    
        // 取出對應模型
        RestaurantModel *tg = self.favorRestaurants[indexPath.row];
        // 設置模型數據给cell 重寫set 方法
        cell.tg = tg;
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    RestaurantModel *forDetail = self.favorRestaurants[indexPath.row];
    
    NSString * selectedUid = self.favorRestaurantUids[indexPath.row];
    
    DetailTableViewController * detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTableViewController"];
    
    detailVC.detail = forDetail;
    detailVC.selectedUid = selectedUid;
    
    
    
    [self showViewController:detailVC sender:nil];
    
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
