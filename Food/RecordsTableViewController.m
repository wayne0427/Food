//
//  RecordsTableViewController.m
//  Food
//
//  Created by 鄭偉強 on 2016/10/13.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import "RecordsTableViewController.h"
#import "RecordViewController.h"


@interface RecordsTableViewController ()


@property(nonatomic,strong) NSMutableArray * records;

@end

@implementation RecordsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    
    NSArray * tmpArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"recordArray"];
    
    self.records = [[NSMutableArray alloc]initWithArray:tmpArray];
    
    
    NSLog(@"%lu",_records.count);
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _records.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary * each = _records[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",each[@"restaurantName"]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"時間:%@",each[@"createTime"]];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    
    NSDictionary * each = _records[indexPath.row];
    
    RecordViewController * vc = [self.storyboard   instantiateViewControllerWithIdentifier:@"RecordViewController"];
    
    vc.recordDict = each;
    vc.fromTableViewString = @"1";
    
    if (vc.recordDict) {
        NSLog(@"aa");
    }
    
    [self showViewController:vc sender:nil];
    
    
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //1.先砍資料
    //2.在砍畫面
    
    [self.records removeObjectAtIndex:indexPath.row];
    
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.records forKey:@"recordArray"];
    
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
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
