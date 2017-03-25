//
//  RestaurantsTableViewController.m
//  Food
//
//  Created by 鄭偉強 on 2016/10/13.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "RestaurantsTableViewController.h"
#import "Helper.h"
#import "RestaurantInfo.h"  //for 網路 model
#import "restaurantInfoCell.h"
#import "RestaurantModel.h"
#import "DetailTableViewController.h"
#import "SVProgressHUD.h"


@interface RestaurantsTableViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating,UISearchBarDelegate>
{
    //靠此manager 拿到網路資料
    RestaurantInfo * restaurantManager;
    
}



@end

@implementation RestaurantsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createSearchBar];
    _searchList = [NSMutableArray new];
    _searchUidList = [NSMutableArray new];
    
    
    _myTableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"foodBG.png"]];
   
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)createSearchBar{
    
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.searchController.searchBar.delegate = self;
    
    self.searchController.searchBar.keyboardType = UIKeyboardTypeDefault;
    //
    self.myTableView.tableHeaderView = self.searchController.searchBar;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];

    
    
    restaurantManager = [RestaurantInfo sharedInstance];
    //去網路拿資料 並且會回傳一個array 餐廳到我的block
    [restaurantManager getAllRestaurantArray:^(NSMutableArray *result) {
        
        //回傳一個array而已 所以在順便拿uid
        self.restaurantUids = [restaurantManager getAllRestaurantUids];
       
        NSLog(@"--------");
        NSLog(@"所有餐廳頁面出現時所有餐廳的Uid: %@",_restaurantUids);
        
        //字典轉模型 到新的array
        
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:result.count];
        
        for (NSDictionary *dict in result) {
            RestaurantModel *tg = [RestaurantModel tgWithDict:dict];
            [models addObject:tg];
        }
        
        //自己array, 已經都是模型
        self.restaurants = [models copy];
        
        [SVProgressHUD dismiss];
        
        [self.myTableView reloadData];
        
    }];
    
    
    
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.searchController.active) {
        return _searchList.count;
    }else{
        return _restaurants.count;
    }
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    restaurantInfoCell *cell = [restaurantInfoCell cellWithTableView:tableView];
    
    if (self.searchController.active) {
     
        RestaurantModel *tg = self.searchList[indexPath.row];
        
        cell.tg = tg;
        
    }else{
        // 取出對應模型
        RestaurantModel *tg = self.restaurants[indexPath.row];
        // 設置模型數據给cell 重寫set 方法
        cell.tg = tg;
       
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    //選擇cell時判斷 searchList 有沒有物件
    
    if (self.searchList.count > 0) {
        
        
        RestaurantModel *forDetail = self.searchList[indexPath.row];
        
        NSString * selectedUid = self.searchUidList[indexPath.row];
        
        DetailTableViewController * detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTableViewController"];
        
        detailVC.detail = forDetail;
        detailVC.selectedUid = selectedUid;
        
        //轉場前取消搜尋bar important
        self.searchController.active = false;
        
        [self showViewController:detailVC sender:nil];
        
        
        
    }else{
        
        RestaurantModel *forDetail = self.restaurants[indexPath.row];
        
        NSString * selectedUid = self.restaurantUids[indexPath.row];
        
        DetailTableViewController * detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailTableViewController"];
        
        detailVC.detail = forDetail;
        detailVC.selectedUid = selectedUid;
        
        [self showViewController:detailVC sender:nil];
        
    }
    

    
}


#pragma mark - SeachBar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text=@"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.myTableView.allowsSelection=YES;
    self.myTableView.scrollEnabled=YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //
    //    NSArray *results;
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.myTableView.allowsSelection=YES;
    self.myTableView.scrollEnabled=YES;
    
    
    [_searchList removeAllObjects];
    NSString *searchString = [self.searchController.searchBar text];
    
    
    //拿到每個物件去比對條件
    for (int i = 0; i < self.restaurants.count; i++) {
        RestaurantModel * eachModel = self.restaurants[i];
        NSString * searchUid = self.restaurantUids[i];
        
        NSString * restaurantName = eachModel.ShopName;
        NSString * restaurantAddress = eachModel.ShopAddress;
        
        //判斷符合項目邏輯
        if ([restaurantName rangeOfString:searchString].location != NSNotFound ||[restaurantAddress rangeOfString:searchString].location != NSNotFound) {
            [_searchList addObject:eachModel];
            [_searchUidList addObject:searchUid];
        }
        
    }
    
   // [self.myTableView reloadData];
    
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    NSLog(@"搜索begin");
    
    self.searchController.searchBar.showsCancelButton = YES;
    
    
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    
    NSLog(@"搜索end");
    
    //刷新表格
    [self.myTableView reloadData];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    
    return YES;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
   
    [_searchList removeAllObjects];
    NSString *searchString = [self.searchController.searchBar text];
    
    for (int i = 0; i < self.restaurants.count; i++) {
        RestaurantModel * eachModel = self.restaurants[i];
        NSString * searchUid = self.restaurantUids[i];
        
        NSString * restaurantName = eachModel.ShopName;
        NSString * restaurantAddress = eachModel.ShopAddress;
        
        if ([restaurantName rangeOfString:searchString].location != NSNotFound ||[restaurantAddress rangeOfString:searchString].location != NSNotFound)
        {
            [_searchList addObject:eachModel];
            [_searchUidList addObject:searchUid];
        }
        
    }

    [self.myTableView reloadData];
    
    
}

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

@end
