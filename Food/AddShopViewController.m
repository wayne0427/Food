//
//  AddShopViewController.m
//  Food
//
//  Created by 鄭偉強 on 2016/10/15.
//  Copyright © 2016年 Wei. All rights reserved.
//
#import "Helper.h"
#import <Photos/Photos.h>
#import "AddShopViewController.h"
#import "FoodItemTableViewCell.h"
#import "SVProgressHUD.h"
#import <CoreLocation/CoreLocation.h>
#import "ServerCommunicator.h"
@import GoogleMaps;
@import GooglePlaces;
@import GooglePlacePicker;


@interface AddShopViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>
{
    
    Helper * helper;
    
    NSMutableArray * shopInfo;
    
    NSMutableArray * foodItems;
    
    //判斷圖片放哪
    NSUInteger photoSavePlace;   // 1 = shop , 2 = foodItem
    NSUInteger photoSave;
    
    GMSPlacePicker *_placePicker;
    CLLocationManager * _locationManager;
    
}
@property (weak, nonatomic) IBOutlet UITableView *fooditemsTableView;
@property (weak, nonatomic) IBOutlet UIView *AddFoodItemView;

//店家資訊
@property (weak, nonatomic) IBOutlet UITextField *shopNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;
@property (weak, nonatomic) IBOutlet UITextField *shopAddressTextField;

@property (weak, nonatomic) IBOutlet UITextField *shopPhoneTextField;

//單筆菜單
@property (weak, nonatomic) IBOutlet UITextField *shopFoodItemTextField;

@property (weak, nonatomic) IBOutlet UITextField *foodItemPriceTextField;

@property (weak, nonatomic) IBOutlet UIImageView *shopFoodIconView;




@end

@implementation AddShopViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    helper = [Helper sharedInstance];
    
    foodItems = [NSMutableArray new];
    shopInfo =[NSMutableArray new];
    
    self.shopFoodIconView.contentMode = UIViewContentModeScaleToFill;
    self.shopImageView.contentMode = UIViewContentModeScaleToFill;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goMainView) name:@"doneAddShop" object:nil];
    
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        _locationManager = [CLLocationManager new];
        [_locationManager requestWhenInUseAuthorization];
        //[_locationManager startUpdatingLocation];
        
    }
    
    
    //for number pad
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(foodItemPriceTextFieldPressed)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.foodItemPriceTextField.inputAccessoryView = keyboardToolbar;
    
}

-(void)foodItemPriceTextFieldPressed{
    
    [self.foodItemPriceTextField resignFirstResponder];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goSeachBtnPressed:(UIButton *)sender {
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(_locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude);
    
    
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.01, center.longitude + 0.01);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.01, center.longitude - 0.01);

        
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast coordinate:southWest];
    
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    
    
    _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    
    [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        if (place != nil) {
            NSLog(@"Place name %@", place.name);
            NSLog(@"Place address %@", place.formattedAddress);
            NSLog(@"Place phone:%@",place.phoneNumber);
            
            self.shopNameTextField.text = place.name;
            self.shopAddressTextField.text = place.formattedAddress;
            self.shopPhoneTextField.text = place.phoneNumber;
            
            
        } else {
            NSLog(@"No place selected");
        }
    }];

    
    
}

- (IBAction)popAddFoodItemViewBtn:(id)sender {
    
    [self.view endEditing:YES];
    
    self.AddFoodItemView.alpha = 1;
    self.shopFoodIconView.image = [UIImage imageNamed:@"unknow.png"];
    
}

- (IBAction)addFoodItemBtn:(id)sender {
    
    if ([_shopFoodItemTextField.text isEqualToString:@""] ||[_foodItemPriceTextField.text isEqualToString:@""]) {
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"餐點資訊尚未設置" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
        
        
    }else{
        
        NSData *foodImageData = UIImageJPEGRepresentation(self.shopFoodIconView.image, 0.5);
        
        
        
        NSDictionary * TmpFoodItem = @{DICT_FOOD_NAME_KEY:_shopFoodItemTextField.text,
                                       DICT_FOOD_PRICE_KEY:_foodItemPriceTextField.text,
                                       DICT_FOOD_IMAGE_KEY:foodImageData};
        
        [foodItems addObject:TmpFoodItem];
        
        
        //清空使用者輸入資料
        _shopFoodItemTextField.text = @"";
        _foodItemPriceTextField.text= @"";
        
        //self.shopFoodIconView.image = [UIImage imageNamed:@"unknow.png"];
        
        //跳開新增view
        self.AddFoodItemView.alpha = 0;
        
        [self.fooditemsTableView reloadData];
        
        //
        [self.view endEditing:YES];
        
    }
    
}


- (IBAction)cancelAddFoodBtn:(id)sender {
    
    self.AddFoodItemView.alpha = 0;
    
    [self.view endEditing:YES];
    
}


- (IBAction)okBtn:(id)sender {
    
    //--------------------------店家資訊--含上傳者------------------------------
 
    NSString * shopName = self.shopNameTextField.text;
    NSString * shopAddress = self.shopAddressTextField.text;
    NSString * shopPhone = self.shopPhoneTextField.text;
    
    NSString * userName = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    

    
    
    if ([shopName isEqualToString:@""] || [shopAddress isEqualToString:@""] || [shopPhone isEqualToString:@""]) {
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"店家資料未設置完全" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
        
    }else if (foodItems.count < 1){
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"餐點至少新增一項" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:true completion:nil];
        
        
    }else{
        
        //prepare restaurant unique id
        
        NSString * uniqueId = [helper getRandomChild];
        
        //prepare shop info and main pic to upload
        NSDictionary * eachShopInfo = @{DICT_SHOP_NAME_KEY:shopName,
                                        DICT_SHOP_ADDRESS_KEY:shopAddress,
                                        DICT_SHOP_PHONE_KEY:shopPhone,
                                        DICT_SHOP_UPLOAD_USER_KEY:userName};
        
        NSData * mainImageData = UIImageJPEGRepresentation(self.shopImageView.image, 0.8);
        
        //秀出等待
        [SVProgressHUD show];
        
        [helper uploadRestaurantData:eachShopInfo mainImage:mainImageData child:uniqueId];
        
        //--------------------------餐點品項------------------------------------
        
        
        [helper uploadFoodItemsImageToStorage:foodItems child:uniqueId];
        
        
        //發推撥
        
        NSString * pushString = [NSString stringWithFormat:@"%@新增了%@這家店!快去查看吧!",userName,shopName];
        
        [[ServerCommunicator shareInstance]sendBulletinMessage:pushString completion:^(NSError *error, id result) {
            
            if (error) {
                NSLog(@"error: %@",error.description);
            }else{
                NSLog(@"result:%@",result);
            }
            
            
        }];
        
    }
    
}

-(void)goMainView{
    
     [SVProgressHUD dismiss];
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)cancelBtn:(id)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
}



#pragma mark - tableView delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return foodItems.count;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FoodItemTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary * each = foodItems[indexPath.row];
    
    cell.queue.text = [NSString stringWithFormat:@"%2lu.",indexPath.row + 1];
    
    cell.foodName.text = [NSString stringWithFormat:@"品名:%@",each[DICT_FOOD_NAME_KEY]];
    cell.foodPrice.text = [NSString stringWithFormat:@"價格:%@",each[DICT_FOOD_PRICE_KEY]];
    
    
    NSData * imageData = each[DICT_FOOD_IMAGE_KEY];
    
    cell.foodImage.image = [UIImage imageWithData:imageData];
    
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [foodItems removeObjectAtIndex:indexPath.row];
    
    [tableView reloadData];
    
//    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}


//使用者按下店家照片
- (IBAction)shopImageDidTapped:(id)sender {
    
    
    photoSavePlace = 1;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"上傳照片" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        
    }];
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"從相簿中選擇" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];

    
    
}


//使用者按下食物照片

- (IBAction)foodItemImageDidTapped:(id)sender {
    
    
    photoSavePlace = 2;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"上傳照片" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        
    }];
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"從相簿中選擇" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self launchImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
    
    
    
}




- (void) launchImagePickerWithSourceType:
(UIImagePickerControllerSourceType) soureceType{
    
    //沒拍照就1
    if (soureceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        photoSave = 1;
    }else{
        photoSave = 2;
    }
    
    
    if ([UIImagePickerController isSourceTypeAvailable:soureceType] == false) {
        
        //check sourceType is existence?
        NSLog(@"Invalid Source Type.");
        return;
    }
    
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = soureceType;
    picker.mediaTypes = @[@"public.image",@"public.movie"];
    
    picker.delegate = self;
    [self presentViewController:picker animated:true completion:nil];
    
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    if (image == nil) {
        //當拍照時拿不到上面的(UIImagePickerControllerEditedImage)時，就改拿下面的(UIImagePickerControllerOriginalImage)
        image = info[UIImagePickerControllerOriginalImage]; //照像時圖片為原圖
    }
    
 
    //拿到最後版本的image
    UIImage *resizeImage = [self resizeFromImage:image];
    
    
    // show預覽圖
    if (photoSavePlace == 1) {
         _shopImageView.image = resizeImage;
    }else{
        _shopFoodIconView.image = resizeImage;
    }
    
    
    if (photoSave == 1) {
        NSLog(@"no Save to user's phone");
    }else{
        [self savaWithImage:resizeImage];
    }
    
    [picker dismissViewControllerAnimated:true completion:nil]; //記得加否則選下一張照片時會沒有反應(imagepicker會沒反應)
    
}

- (UIImage*) resizeFromImage:(UIImage*) sourceImage {
    
    CGFloat maxLength = 1024.0;
    
    CGSize targetSize;
    UIImage *finalImage = nil;
    
    // Check if it is necessary to resize of will use original Image
    if (sourceImage.size.width <= maxLength && sourceImage.size.height < 1024) {
        finalImage = sourceImage;
        
        // 解決圖片檔案很小無法上傳的問題
        targetSize = sourceImage.size;
        
    } else {
        // Will do resize here,and decide final size first.
        if (sourceImage.size.width >= sourceImage.size.height) {
            
            // Width >= Height
            CGFloat ratio = sourceImage.size.width / maxLength;
            targetSize = CGSizeMake(maxLength, sourceImage.size.height /ratio);
            
        }else {
            
            // Height >= Width
            CGFloat ratio = sourceImage.size.height / maxLength;
            targetSize = CGSizeMake(sourceImage.size.width /ratio,maxLength);
        }
        
        // Do resize job here.
        UIGraphicsBeginImageContext(targetSize); //創造一塊虛擬畫布
        [sourceImage drawInRect:CGRectMake(0, 0, targetSize.width,targetSize.height)]; //drawInRect：畫在targetSize中
        finalImage = UIGraphicsGetImageFromCurrentImageContext(); //取出
        UIGraphicsEndImageContext(); // (Important)：記得釋放：因為此為C中的方法
    }
    
    // Add frame to image
    UIGraphicsBeginImageContext(targetSize);
    [finalImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    
    
    //    [text drawAtPoint:CGPointZero withAttributes:attributes];
    finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext(); // Important
    
    return finalImage;
}


// 照片存入相簿中
- (void) savaWithImage:(UIImage*)image {
    
    // Sava as a file
    // 取得PNG檔：找到路徑
    NSData *imageData = UIImagePNGRepresentation(image);
    NSURL *doucumentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    // 決定檔名
    NSString *filename = [NSString stringWithFormat:@"%@.png",[NSDate date]];
    // 路徑檔名結合
    NSURL *fullFilePathURL = [doucumentsURL URLByAppendingPathComponent:filename];
    // 存入
    // atomically：存檔時系統會先寫入暫存檔，當所有資料寫完時，系統才會rename成真正的檔名
    [imageData writeToURL:fullFilePathURL atomically:true];
    NSLog(@"Documents: %@",doucumentsURL); //驗證是否有存入用
    
    // Sava to photos library
    
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        // 異動的地方，包在此block中
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (success) {
            NSLog(@"Success");
        } else {
            NSLog(@"Write error: %@",error);
        }
        
    }];
    
    
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
