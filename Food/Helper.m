//
//  Helper.m
//  FindMyFriend
//
//  Created by 鄭偉強 on 2016/9/11.
//  Copyright © 2016年 Wei. All rights reserved.
//


#import "Helper.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SVProgressHUD.h"


static Helper * _helper;

@implementation Helper

+(instancetype)sharedInstance{
    
    
    
    if (_helper == nil) {
        _helper = [Helper new];
    
    }
    
    return _helper;
    
}

#pragma mark - Login to Firebase


-(void)uploadUserData:(NSDictionary*)info{
    
    NSString * userInfo = @"userInfo";
    NSString * currentUserUid = [[[FIRAuth auth]currentUser]uid];
    
    [[[[[FIRDatabase database] reference]child:userInfo]child:currentUserUid]updateChildValues:info withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"%@",error);
            return ;
        }
        
        NSLog(@"down upload userInfo");
    }];
    
}


//直接登入

-(void)signInWithEmail:(NSString *)email
              password:(NSString*)password{
    
    [[FIRAuth auth]signInWithEmail:email password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        
        
        if (error) {
            NSLog(@"Email sign error");
            return ;
        }
        
        NSLog(@"Email sign in success");
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"singInDone" object:nil];
        
    }];
    
}


//創帳號

-(void)signUpWithEmail:(NSString*)email
              password:(NSString*)password{
    
    [[FIRAuth auth]createUserWithEmail:email password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        
        if (error) {
            //可以讓使用者知道為何失敗
            NSLog(@"%@",error);
            
            
            return ;
        }else{
            
            NSDictionary * userInfo = @{@"Email":email,@"Password":password};
            
            [self uploadUserData:userInfo];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"createAcc" object:nil];
            
        }
        
        
        
    }];
    
}

-(void)signUpWithEmail:(NSString*)email
              password:(NSString*)password done:(Handler)done{
    
    [[FIRAuth auth]createUserWithEmail:email password:password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        
        if (error) {
            //可以讓使用者知道為何失敗
            NSLog(@"%@",error);
    
            done(error,0);
            
            
            return ;
        }else{
            
             [SVProgressHUD show];
            
            NSDictionary * userInfo = @{@"Email":email,@"Password":password};
            
            [self uploadUserData:userInfo];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"createAcc" object:nil];
            
        }
        
        
        
    }];
    
    
    
    
}












//FB登入
-(void)loginWithCredential:(NSString *)loginCredential{
    
    FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                     credentialWithAccessToken:loginCredential];
    
    [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser *user, NSError *error) {
        
        if (error) {
            NSLog(@"%@",error.description);
            return ;
            
        }else{
            NSLog(@"Firebase credential  ok");
            
        
        //picture.width(300).height(300)
            
            [[[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:@{@"fields":@"name"} HTTPMethod:@"GET"] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                
                if (error) {
                    
                    NSLog(@"%@", [error localizedDescription]);
                    
                }else{
                     //result 一個字典 , 可拿 id ,name , email
                    NSLog(@"%@",result);
                    NSString * name = [result objectForKey:@"name"];
                    NSString * email = [result objectForKey:@"email"];
                    
                    
                    NSLog(@"myName: %@",name);
                    
                    [[NSUserDefaults standardUserDefaults]setObject:name forKey:@"userName"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    if (!email) {
                        email = @"nil";
                    }
                    
                    
                    NSDictionary * userInfo = @{@"UserName":name,@"Email":email};
                    
                    
                    [self uploadUserData:userInfo];
                    
                    
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"doneLogin" object:nil];;
                    
                    
                }
                
            }];


            
        }
    
    }];
    
}

#pragma mark - Switch View

-(void)switchToMainView:(UIViewController *)view{
    
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UITabBarController * myTabBarVC = [storyboard instantiateViewControllerWithIdentifier:@"TabBarVC"];
    
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.window.rootViewController = myTabBarVC;
    [app.window makeKeyAndVisible];
    
}


#pragma mark - upload to Firebase

-(void)uploadRestaurantData:(NSDictionary*)RestaurantInfo
                  mainImage:(NSData*) mainImageData
                      child:(NSString*)childString{
    
    
    [[[self getDatabaseRefOfRestaurants]child:childString]updateChildValues:RestaurantInfo withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"%@",error);
            return ;
        }
        
        NSLog(@"down Info upload");
    }];
    
    
    [self uploadMainImageToStorage:mainImageData child:childString];
    
    
    
}

//inside method
-(void)uploadMainImageToStorage:(NSData*) mainImageData
                          child:(NSString*)childString{
    
    //ref restaurant
    
    FIRStorageReference *storageRef = [[self getStorageRefOfRestaurant]child:childString];
    
    
    
    //main pic position
    FIRStorageReference *mainPicRef = [storageRef child:@"MainPic.jpg"];
    
    //main pic update
    [mainPicRef putData:mainImageData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        
        
        if (error) {
            NSLog(@"why:%@",error.description);
            return ;
        }
        
        //拿到下載字串
        NSString * MainUrlstring = [metadata.downloadURL absoluteString];
        NSDictionary * mainImageDict = @{@"MainImage":MainUrlstring};
        
        //下載網址放到 database
        
        [[[self getDatabaseRefOfRestaurants]child:childString]updateChildValues:mainImageDict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            
            
            if (error) {
                NSLog(@"%@",error);
                return ;
            }
            
            NSLog(@"down Main imageString upload");
            
            
        }];
        
       
    }];
}



-(void)uploadFoodItemsImageToStorage:(NSMutableArray*)imageDataArray child:(NSString*)childString{
    
    
    
    //ref restaurant
    
    FIRStorageReference *storageRef = [[self getStorageRefOfRestaurant]child:childString];
    
   
    for (int i = 0; i < imageDataArray.count; i ++) {
        
        NSDictionary * eachItem = imageDataArray[i];
        
        NSData * eachImageData = eachItem[DICT_FOOD_IMAGE_KEY];
        NSString * eachItemName = eachItem[DICT_FOOD_NAME_KEY];
        NSString * eachItemPrice = eachItem[DICT_FOOD_PRICE_KEY];
        
        NSString * fileName = [NSString stringWithFormat:@"%d.jpg",i+1];
        
        FIRStorageReference *nameRef =  [storageRef child:fileName];
        
        [nameRef putData:eachImageData metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            
            if (error) {
                NSLog(@"上傳照片失敗:%@",error);
                return ;
            }
            
            
            NSString * foodItemImageString = [metadata.downloadURL absoluteString];
            
            
            NSDictionary * FoodItemDict = @{@"FoodImageString":foodItemImageString,@"FoodName":eachItemName,@"FoodPrice":eachItemPrice};
            
           [[[[self getDatabaseRefOfFoodItems]child:childString]childByAutoId]updateChildValues:FoodItemDict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
               
               if (error) {
                   NSLog(@"%@",error);
                   return ;
               }
               
               NSLog(@"down each imageString upload");
               [[NSNotificationCenter defaultCenter]postNotificationName:@"doneAddShop" object:nil];
               
           }];
            
            
        }];
        
     
    }
    
    
}


//for delete restaurant

-(void)deleteRestaurantByUid:(NSString*)uid done:(Handler)done{
    
    [[[self getDatabaseRefOfRestaurants]child:uid]removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if (error) {
          
            done(error,nil);
        }else{
            
            [self deleteRestaurantFoodsByUid:uid done:done];
        }
        
    }];
    
}


-(void)deleteRestaurantFoodsByUid:(NSString*)uid done:(Handler)done{
    
    [[[self getDatabaseRefOfFoodItems]child:uid]removeValueWithCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
       
                if (error) {
                    NSLog(@"error is: %@",error.description);
                    done(error,nil);
                }else{
                    NSLog(@"2");
                    BOOL result = true;
                    done(nil,result);
                }
        
    }];
    
}

//刪除圖片方法 , 暫時先不刪

//-(void)deleteRestaurantPicByUid:(NSString*)uid done:(Handler)done{
//    
//    //NSString * picDirString = [NSString stringWithFormat:@"%@/",uid];

//    NSString * minusUid = [uid stringByReplacingOccurrencesOfString:@"-" withString:@""];
//    NSLog(@"string: %@",minusUid);
//    
//    [[[self getStorageRefOfRestaurant]child:minusUid]deleteWithCompletion:^(NSError * _Nullable error) {
//        
//        if (error) {
//            NSLog(@"error is: %@",error.description);
//            done(error,nil);
//        }else{
//            NSLog(@"2");
//            BOOL result = true;
//            done(nil,result);
//        }
//        
//    }];
//    
//}




- (void)incrementStarsForRef:(FIRDatabaseReference *)ref {
    
    
    //給一個路徑
    
    [ref runTransactionBlock:^FIRTransactionResult * _Nonnull(FIRMutableData * _Nonnull currentData) {
        
        //此路徑的currentData.value 是字典
        NSMutableDictionary *post = currentData.value;
        
        //要是字典空的就直接回傳?
        if (!post || [post isEqual:[NSNull null]]) {
            return [FIRTransactionResult successWithValue:currentData];
        }
        
        //----------------------以下保證 post 字典有東西----------------------//
        
        //拿到字典裡面的星星用戶
        NSMutableDictionary *stars = [post objectForKey:@"stars"];
        
        
        //要是沒有人按過星星
        //就初始化一個可變字典
        if (!stars) {
            stars = [[NSMutableDictionary alloc] initWithCapacity:1];
        }
        //拿到用戶uid 判斷有沒有按過
        NSString *uid = [FIRAuth auth].currentUser.uid;
        
        //拿出 post裡面的 星星數 並轉成int
        int starCount = [post[@"starCount"] intValue];
        
        
        //要是星星用戶有自己的資料,代表之前按過 , 就 減去 int的數字,並除掉星星用戶字典裡面的資料
        if ([stars objectForKey:uid]) {
            // Unstar the post and remove self from stars
            starCount--;
            
            //字典 value 是 布林值 , 不過不用管  , 直接用key  刪除
            [stars removeObjectForKey:uid];
            
        } else {
            
            //要是星星用戶沒有資料 , 代表沒按過 , 就加入 int 數字 , 並加入星星用戶資料
            starCount++;
            stars[uid] = @YES;
        }
        
        
        
        
        //準備字典 星星用戶  在放入post裡面
        post[@"stars"] = stars;
        
        //準備星星數量 (改成NSString) 在放入post裡面
        NSString * starTotal = [NSString stringWithFormat:@"%d",starCount];
        //post[@"starCount"] = [NSNumber numberWithInt:starCount];
        post[@"starCount"] = starTotal;
        
        // Set value and report transaction success
        
        [currentData setValue:post];
        
        
        return [FIRTransactionResult successWithValue:currentData];
        
        
    } andCompletionBlock:^(NSError * _Nullable error,
                           BOOL committed,
                           FIRDataSnapshot * _Nullable snapshot) {
        // Transaction completed
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    // [END post_stars_transaction]
}



#pragma mark - Create Menu Method


-(void)createMenuWith:(NSString*)menuUid menuItialize:(NSDictionary *)menu{
    
    [[[self getDatabaseRefOfMenus]child:menuUid]updateChildValues:menu withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        
        if (error) {
            NSLog(@"create menu error:%@",error);
            return ;
        }
        
        [self createMenuUsersWith:menuUid];
        
        
    }];
    
    
}


-(void)changeStatusWithMenuUid:(NSString*)menuUid status:(NSString*)status{
    
    
    NSString * currentUserUid = [self uidOfCurrentUser];
    
    NSDictionary * userInfo = @{@"SelfStatus":status};
    
    
    
    [[[[self getDatabaseRefOfMenuUsers]child:menuUid]child:currentUserUid]updateChildValues:userInfo withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if (error) {
            NSLog(@"create menu error:%@",error);
            return ;
        }
        
    }];
    
    
}

-(void)createMenuUsersWith:(NSString*)menuUid{
    
    NSString * currentUserUid = [self uidOfCurrentUser];
    
    NSString * userName = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    NSDictionary * userInfo = @{@"UserName":userName,@"SelfStatus":@"0"};
    
    
    
    [[[[self getDatabaseRefOfMenuUsers]child:menuUid]child:currentUserUid]updateChildValues:userInfo withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if (error) {
            NSLog(@"create menu error:%@",error);
            return ;
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"Created" object:nil];
  
    }];
    
    
}

//for OrderViewController
-(void)selectedMenuUsersWith:(NSString*)menuUid{
    
    NSString * currentUserUid = [self uidOfCurrentUser];
    
    NSString * userName = [[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    NSDictionary * userInfo = @{@"UserName":userName,@"SelfStatus":@"0"};
    
    
    
    [[[[self getDatabaseRefOfMenuUsers]child:menuUid]child:currentUserUid]updateChildValues:userInfo withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if (error) {
            NSLog(@"create menu error:%@",error);
            return ;
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"Selected" object:nil];
        
    }];
    
    
}



-(void)uploadUserOrderWithMenuUid:(NSString*)uid andOrder:(NSDictionary*)dict{
    
    NSString * userUid = [self uidOfCurrentUser];
    
    
    [[[[self getDatabaseRefOfMenuOrderList]child:uid]child:userUid]updateChildValues:dict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if (error) {
            NSLog(@"error: %@",error);
            return ;
        }else{
            NSLog(@"success upload");
        }

    }];
    
  
}

-(void)uploadtotalPriceWithUid:(NSString*)uid andPrice:(NSDictionary*)dict{
    
    [[[self getDatabaseRefOfMenus]child:uid]updateChildValues:dict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if (error) {
            NSLog(@"error: %@",error);
            return ;
        }else{
            NSLog(@"success upload");
        }
        
    }];
    
}




-(void)deleteUserOrderWithMenuUid:(NSString*)uid{
    
    NSString * userUid = [self uidOfCurrentUser];
    
    
    [[[[self getDatabaseRefOfMenuOrderList]child:uid]child:userUid]removeValue];
    
    
}




-(void)quitAndDeleteDataFromSelector:(NSString*)menuUid{
    
    NSString * currentUserUid = [self uidOfCurrentUser];
    
    [[[[self getDatabaseRefOfMenuUsers]child:menuUid]child:currentUserUid]removeValue];
   [[[[self getDatabaseRefOfMenuOrderList]child:menuUid]child:currentUserUid]removeValue];
}


-(void)quitAndDeleteDataFromCreater:(NSString*)menuUid{
    
    
    
    [[[self getDatabaseRefOfMenuOrderList]child:menuUid]removeValue];
    [[[self getDatabaseRefOfMenuUsers]child:menuUid]removeValue];
    [[[self getDatabaseRefOfMenus]child:menuUid]removeValue];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"createrLeave" object:nil];
}



-(void)createrUploadSendNotice:(NSString *)menuUid{
    
    NSDictionary * notice = @{@"Notice":@"1"};
    [[[self getDatabaseRefOfMenuNotice]child:menuUid]updateChildValues:notice];
    
}

-(void)createrSendBtnPressed:(NSString*)menuUid{
    
    [[[self getDatabaseRefOfMenuUsers]child:menuUid]removeValue];
    
    [[[self getDatabaseRefOfMenuOrderList]child:menuUid]removeValue];
    
    [[[self getDatabaseRefOfMenus]child:menuUid]removeValue];
    

    
    
}



#pragma mark - Get Firebase Ref

-(FIRDatabaseReference *)getDatabaseRefOfCurrentUser{
    
    
    return [[[[FIRDatabase database]reference]child:@"userInfo"]child:[FIRAuth auth].currentUser.uid];

}



-(FIRDatabaseReference *)getDatabaseRefOfUsersInfo{
    
    return [[[FIRDatabase database]reference]child:@"userInfo"];
}




-(FIRDatabaseReference *)getDatabaseRefOfRestaurants{
    
    
    return [[[FIRDatabase database]reference]child:@"Restaurants"];
    
}

         
-(FIRDatabaseReference *)getDatabaseRefOfFoodItems{

    return [[[FIRDatabase database]reference]child:@"FoodItems"];
    
}


-(FIRDatabaseReference *)getDatabaseRefOfMenus{
    
    
    return [[[FIRDatabase database]reference]child:@"Menus"];
    
}
-(FIRDatabaseReference *)getDatabaseRefOfMenuUsers{
    
    
    return [[[FIRDatabase database]reference]child:@"MenuUsers"];
    
}

-(FIRDatabaseReference *)getDatabaseRefOfMenuOrderList{
    
    
    return [[[FIRDatabase database]reference]child:@"OrderList"];
    
}

-(FIRDatabaseReference *)getDatabaseRefOfMenuNotice{
    
    
    return [[[FIRDatabase database]reference]child:@"MenuNotice"];
    
}

//storge

-(FIRStorageReference *)getStorageRefOfRestaurant{
    
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage reference];
    
    FIRStorageReference *ref = [storageRef child:@"Restaurant"];
    
    
    return ref;
    
}


#pragma mark - Other Method

-(NSString *)uidOfCurrentUser{
    
    return [[[FIRAuth auth]currentUser]uid];
}

-(NSString *)getRandomChild{
    
    NSString *child = [[[FIRDatabase database]reference]childByAutoId].key;
    
    return child;
}

@end
