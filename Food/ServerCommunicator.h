//
//  ServerCommunicator.h
//  HRM
//
//  Created by 鄭偉強 on 2016/11/26.
//  Copyright © 2016年 Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define GROUP_NAME @"Restaurant"
//#define USER_NAME  @"HsiangYu"

#define USER_NAME_KEY      @"UserName"
#define BULLETIN_TITLE_KEY @"Title"
#define DEVICETOKEN_KEY    @"DeviceToken"
#define GROUP_NAME_KEY     @"GroupName"
#define DATA_KEY           @"data"

#define RELOAD_DATA        @"reloadData"

@import Firebase;
@import FirebaseDatabase;


typedef void(^DoneComm)(NSError *error,id result);

@interface ServerCommunicator : NSObject
@property (nonatomic, strong) NSMutableDictionary *bulletinsDict;


+ (instancetype) shareInstance;

- (void) updateDeviceToken: (NSString *)deviceToken
                completion:(DoneComm)done;

- (void) sendBulletinMessage:(NSString*)title
                  completion:(DoneComm) done;



@end
