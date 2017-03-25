//
//  Helper.h
//  FindMyFriend
//
//  Created by 鄭偉強 on 2016/9/11.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//shop info dict
#define DICT_SHOP_NAME_KEY  @"ShopName"
#define DICT_SHOP_ADDRESS_KEY  @"ShopAddress"
#define DICT_SHOP_PHONE_KEY  @"ShopPhone"



//food dict
#define DICT_FOOD_NAME_KEY  @"FoodName"
#define DICT_FOOD_PRICE_KEY  @"FoodPrice"
#define DICT_FOOD_IMAGE_KEY  @"FoodImage"



@import Firebase;


typedef void (^Handler)(NSError * error, BOOL result);

@interface Helper : NSObject


+(instancetype)sharedInstance;


-(void)loginWithCredential:(NSString *)loginCredential;


-(void)uploadRestaurantData:(NSDictionary*)RestaurantInfo
                  mainImage:(NSData*) mainImageData
                      child:(NSString*)childString;



-(void)uploadFoodItemsImageToStorage:(NSMutableArray *)imageDataArray
                               child:(NSString*)childString;

-(NSString *)getRandomChild;


-(void)signUpWithEmail:(NSString*)email
              password:(NSString*)password;


-(void)signUpWithEmail:(NSString*)email
              password:(NSString*)password done:(Handler)done;



-(void)signInWithEmail:(NSString *)email
              password:(NSString*)password;



-(void)uploadUserData:(NSDictionary*)info;


// detailTableView method for add menu
-(void)createMenuWith:(NSString*)menuUid menuItialize:(NSDictionary *)menu;

//  addMenuViewController method for  test cancel
-(void)changeStatusWithMenuUid:(NSString*)menuUid status:(NSString*)status;


// detailTableView method for add menu
// ordersViewController method for join the order
-(void)createMenuUsersWith:(NSString*)menuUid;
-(void)selectedMenuUsersWith:(NSString*)menuUid;


//  addMenuViewController method for quit and delete
-(void)quitAndDeleteDataFromSelector:(NSString*)menuUid;
-(void)quitAndDeleteDataFromCreater:(NSString*)menuUid;


// AddMenuViewController method for "user choose order and ok"
-(void)uploadUserOrderWithMenuUid:(NSString*)uid andOrder:(NSDictionary*)dict;
-(void)uploadtotalPriceWithUid:(NSString*)uid andPrice:(NSDictionary*)dict;


// AddmenuViewController method for cancel order
-(void)deleteUserOrderWithMenuUid:(NSString*)uid;

// AddmenuViewController method for send order
-(void)createrUploadSendNotice:(NSString *)menuUid;
-(void)createrSendBtnPressed:(NSString*)menuUid;


-(void)incrementStarsForRef:(FIRDatabaseReference *)ref;

//for managerViewController delete restaurant

-(void)deleteRestaurantByUid:(NSString*)uid done:(Handler)done;


-(FIRDatabaseReference *)getDatabaseRefOfRestaurants;

-(FIRDatabaseReference *)getDatabaseRefOfFoodItems;

-(FIRDatabaseReference *)getDatabaseRefOfCurrentUser;

-(FIRDatabaseReference *)getDatabaseRefOfMenus;

-(FIRDatabaseReference *)getDatabaseRefOfMenuUsers;

-(FIRDatabaseReference *)getDatabaseRefOfMenuOrderList;

-(FIRDatabaseReference *)getDatabaseRefOfMenuNotice;

//--------------------------------------------------------------//


-(void)switchToMainView:(UIViewController*)view;



-(FIRDatabaseReference *)getDatabaseRefOfUsersInfo;


-(NSString*)uidOfCurrentUser;




@end
