//
//  AppDelegate.h
//  UVL
//
//  Created by TxLabz on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "Constants.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property BOOL isShowingPOPUPAlready;

@end

