//
//  ViewController.m
//
//
//  Copyright © 2016年 cd. All rights reserved.
//

#import "ViewController.h"
#import "RestaurantsTableViewController.h"


#import "Helper.h"
#import "RestaurantInfo.h"
#import "restaurantInfoCell.h"
#import "RestaurantModel.h"
#import "DetailTableViewController.h"
#import "FavoriteViewController.h"
#import "ManagerViewController.h"

#import "ServerCommunicator.h"



@interface ViewController ()<UIScrollViewDelegate>
{
    CGFloat labelX ;
    CGFloat labelY ;
    CGFloat labelW ;
    CGFloat labelH ;
    
}


@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addMenuBtnView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goReflashRestaurantPage) name:@"doneDeleteRestaurant" object:nil];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.rootScrollView.delegate = self;
    
    
    self.addMenuBtnView.image = [[UIImage imageNamed:@"addMuBtn.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.addMenuBtnView.customView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    //back鈕別顯示字
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    
    //上傳token
    
    NSString * userDeviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];
    
    if (userDeviceToken) {
        
        ServerCommunicator *comm = [ServerCommunicator shareInstance];
        
        [comm updateDeviceToken:userDeviceToken
                     completion:^(NSError *error, id result) {
                         
                         if (error) {
                             NSLog(@"updateDeviceToken fail : %@",error);
                             return ;
                         }
                         
                         NSLog(@"updateDeviceToken OK : %@",[result description]);
                         
                     }];
        
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (labelX) {
        
        self.lineLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
    }
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //拿到label現在位置
    
    labelX = self.lineLabel.frame.origin.x;
    labelY = self.lineLabel.frame.origin.y;
    labelW = self.lineLabel.frame.size.width;
    labelH = self.lineLabel.frame.size.height;
    
}


- (IBAction)addShopBtn:(UIBarButtonItem *)sender {
    
    // AddShopViewController
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController * addShopVC = [storyBoard instantiateViewControllerWithIdentifier:@"AddShopViewController"];
    
    [self presentViewController:addShopVC animated:true completion:nil];
    
}





//第一個按钮
- (IBAction)FirstBI:(id)sender {
    self.rootScrollView.contentOffset = CGPointMake(self.view.frame.size.width * 0, 0);
    self.lineLabel.frame = CGRectMake(self.view.frame.size.width * 0
                                      , self.lineLabel.frame.origin.y, self.lineLabel.frame.size.width, self.lineLabel.frame.size.height);
    
   
}
//第二個按钮
- (IBAction)SecondBI:(id)sender {
    self.rootScrollView.contentOffset = CGPointMake(self.view.frame.size.width *1 , 0);
    self.lineLabel.frame = CGRectMake((self.view.frame.size.width/3) * 1
                                      , self.lineLabel.frame.origin.y, self.lineLabel.frame.size.width, self.lineLabel.frame.size.height);
    
    
}
//第三個按钮
- (IBAction)ThirdBI:(id)sender {
    self.rootScrollView.contentOffset = CGPointMake(self.view.frame.size.width *2 , 0);
    self.lineLabel.frame = CGRectMake((self.view.frame.size.width/3) * 2
                                      , self.lineLabel.frame.origin.y, self.lineLabel.frame.size.width, self.lineLabel.frame.size.height);
   
}





//scrollerView代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    //只要有偏移量 就取消收尋
    RestaurantsTableViewController *  vc = self.childViewControllers[0];
    vc.searchController.active = false;
    
    
    
    
    //NSLog(@"%lf",scrollView.contentOffset.x);
    self.lineLabel.frame = CGRectMake( scrollView.contentOffset.x / 3
                                      , self.lineLabel.frame.origin.y, self.lineLabel.frame.size.width, self.lineLabel.frame.size.height);
    

    
    if (scrollView.contentOffset.x == self.view.frame.size.width *2) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBtnPressed)];
        
    }else{
        self.navigationItem.leftBarButtonItem = nil;
        
        ManagerViewController * mVC = self.childViewControllers[2];
        
        if (mVC.managerTableView.editing == true) {
            [mVC.managerTableView setEditing:false animated:true];
        }
        
        
        
    }
    
    
}

-(void)editBtnPressed{
    
    ManagerViewController * mVC = self.childViewControllers[2];
    
    [mVC.managerTableView setEditing:true animated:true];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnPressed)];
    
}


-(void)doneBtnPressed{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editBtnPressed)];
    
    ManagerViewController * mVC = self.childViewControllers[2];
    
    [mVC.managerTableView setEditing:false animated:true];
    
}

-(void)goReflashRestaurantPage{
    
    RestaurantsTableViewController * vc = self.childViewControllers[0];
    
    //更新所有餐廳的頁面
    [[RestaurantInfo sharedInstance] getAllRestaurantArray:^(NSMutableArray *result) {
        
        //回傳一個array而已 所以在順便拿uid
        vc.restaurantUids = [[RestaurantInfo sharedInstance] getAllRestaurantUids];
    
        //字典轉模型 到新的array
        
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:result.count];
        
        for (NSDictionary *dict in result) {
            RestaurantModel *tg = [RestaurantModel tgWithDict:dict];
            [models addObject:tg];
        }
        
        //自己array, 已經都是模型
        vc.restaurants = [models copy];
    
        [vc.myTableView reloadData];
        
    }];
    
    //更新最愛餐廳的頁面
    
    FavoriteViewController *  fvc = self.childViewControllers[1];
    
    [[RestaurantInfo sharedInstance] getFavoriteRestaurantArray:^(NSMutableArray *result) {
        
        fvc.favorRestaurantUids = [[RestaurantInfo sharedInstance] getFavoriteRestaurantUids];
        
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:result.count];
        
        for (NSDictionary *dict in result) {
            RestaurantModel *tg = [RestaurantModel tgWithDict:dict];
            [models addObject:tg];
        }
        
        fvc.favorRestaurants = [models copy];
        
        
        [fvc.favoriteTableView reloadData];
        
    }];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}





@end
