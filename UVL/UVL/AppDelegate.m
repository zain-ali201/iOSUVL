//
//  AppDelegate.m
//  UVL
//
//  Created by TxLabz on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "AppDelegate.h"
#import "UVLAppglobals.h"
#import "DataManager.h"
#import "Utils.h"

#import "VehicleOptionViewController.h"
#import "VechicleOptionsCell.h"
#import "AcknowledgementTableViewCell.h"
#import "UVLAppglobals.h"
#import "Constants.h"
#import "ApiManager.h"
#import "DataManager.h"
#import "VehiclePhotosViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "CollectionDeliveryVC.h"
#import "SignatureVC.h"
#import "MoreViewController.h"
#import "Utils.h"
#import "HomeViewController.h"

@interface AppDelegate ()





@end





@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    application.applicationIconBadgeNumber = 0;
    [application cancelAllLocalNotifications];
    
    self.isShowingPOPUPAlready = NO;
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
     {
         if( !error )
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[UIApplication sharedApplication] registerForRemoteNotifications];
             });
            
         }
         else
         {
             NSLog( @"Push registration FAILED" );
             NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
             NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
         }
     }];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"] ){
        [[UVLAppglobals sharedAppGlobals] loadDashboard];
    }
    else{
        [[UVLAppglobals sharedAppGlobals] loadLoginStoryboard];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        
        [application registerForRemoteNotifications];
    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    NSString * deviceTokenString = [[[[deviceToken description]
                             stringByReplacingOccurrencesOfString: @"<" withString: @""]
                            stringByReplacingOccurrencesOfString: @">" withString: @""]
                           stringByReplacingOccurrencesOfString: @" " withString: @""];
    deviceTokenString = [self hexadecimalStringFromData:deviceToken];
    NSLog(@"The generated device token string is : %@",deviceTokenString);
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString forKey:@"deviceToken"];

}

- (NSString *)hexadecimalStringFromData:(NSData *)deviceToken {
  NSUInteger dataLength = deviceToken.length;
  if (dataLength == 0) {
    return nil;
  }

  const unsigned char *dataBuffer = (const unsigned char *)deviceToken.bytes;
  NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
  for (NSInteger index = 0; index < dataLength; ++index) {
    [hexString appendFormat:@"%02x", dataBuffer[index]];
  }
  return [hexString copy];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    /////////////////////////////////////
    if (application.applicationState == UIApplicationStateActive)
    {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did receive a Remote Notification" message:[NSString stringWithFormat:@"Your App name received this notification while it was running:\n%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }
    ////////////////////////////////////////////////
    UIApplicationState state = [application applicationState];
    if(state == UIApplicationStateInactive){
        
    }else if(state == UIApplicationStateActive){
        
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    
    NSLog(@"Handle push from foreground");
    // custom code to handle push while app is in the foreground
//        NSLog(@"%@", notification.request.content.userInfo);
    //NSString *message = [notification.request.content.userInfo objectForKey:@"message"];
        NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"%@", userInfo[@"aps"][@"alert"]);
    // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
    
    NSString *title = userInfo[@"aps"][@"alert"];
    NSString *type = userInfo[@"slug"];
//    if([notification.request.content.body isEqualToString:@"Break Time Is Over."]){
//        [self registerNotitifications];
    
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert!", nil)
                                                                       message:title
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *OKAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK",nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       
                                       UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
                                       if([type isEqualToString:@"update-job"]) {
                                           if(![UVLAppglobals sharedAppGlobals].isClockedIn) {
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshShift" object:nil];
                                               tabb.selectedIndex = 2;
                                           } else {
                                               [[tabb.viewControllers objectAtIndex:0] popToRootViewControllerAnimated:YES];
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshHome" object:nil];
                                               tabb.selectedIndex = 0;
                                           }
                                           
                                       } else if([type isEqualToString:@"add-job"]) {
                                           if(![UVLAppglobals sharedAppGlobals].isClockedIn) {
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshShift" object:nil];
                                               tabb.selectedIndex = 2;
                                           } else {
                                               [UVLAppglobals sharedAppGlobals].shiftRefreshCall = YES;
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshHome" object:nil];
                                               tabb.selectedIndex = 0;
                                           }
                                       } else if([type isEqualToString:@"create-a-shift"]) {
                                           if(![UVLAppglobals sharedAppGlobals].isClockedIn) {
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshShift" object:nil];
                                               tabb.selectedIndex = 2;
                                           }
                                           
                                       } else if([type isEqualToString:@"update-a-shift"]) {
                                           if(![UVLAppglobals sharedAppGlobals].isClockedIn) {
                                               [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshShift" object:nil];
                                               tabb.selectedIndex = 2;
                                           }
                                           
                                       } else if([type isEqualToString:@"add-message"]) {
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNotifications" object:nil];
                                           tabb.selectedIndex = 1;
                                       }
                                   }];
        
        
        [alert addAction:OKAction];
        [self cancelAlarm];
        [ROOT_VIEW_CONTROLLER presentViewController:alert animated:YES completion:nil];
//    }
    
    
//    else{
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"An important notification awaits your approval." preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Show" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
//                             {
//                                 self.isShowingPOPUPAlready = NO;
//                                 UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
//                                 tabb.selectedIndex = 1;
//                             }];
//        UIAlertAction *cancel = [UIAlertAction
//                                 actionWithTitle:@"Dismiss"
//                                 style:UIAlertActionStyleCancel
//                                 handler:^(UIAlertAction *action)
//                                 {
//                                     self.isShowingPOPUPAlready = NO;
//                                 }];
//
//
//
//        [alertController addAction:cancel];
//        [alertController addAction:ok];
//        [self showAlert:alertController];
//    }
}

-(void)cancelAlarm{
    for (UILocalNotification *notification in [[[UIApplication sharedApplication] scheduledLocalNotifications] copy]){
        NSDictionary *userInfo = notification.userInfo;
        if ([@"identifier" isEqualToString:[userInfo objectForKey:DriverBreakTimeSlot]]){
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler
{
    
    NSLog( @"Handle push from background or closed" );
    // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
    //    NSDictionary *userInfo = response.notification.request.content.userInfo;
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"An important notification awaits your approval." preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Show" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
//                         {
//
//                             self.isShowingPOPUPAlready = NO;
//                             UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
//                             tabb.selectedIndex = 1;
//                         }];
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
//        NSLog(@"asdhfgjk");
//        self.isShowingPOPUPAlready = NO;
//    }];
//
//    [alertController addAction:cancel];
//    [alertController addAction:ok];
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
    
    NSString *title = userInfo[@"alert_title"];
    NSString *type = userInfo[@"slug"];
    //    if([notification.request.content.body isEqualToString:@"Break Time Is Over."]){
    //        [self registerNotitifications];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert!", nil)
                                                                   message:title
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK",nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   
                                   UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
                                   if([type isEqualToString:@"update-job"]) {
                                       if(![UVLAppglobals sharedAppGlobals].isClockedIn) {
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshShift" object:nil];
                                           tabb.selectedIndex = 2;
                                       } else {
                                           [[tabb.viewControllers objectAtIndex:0] popToRootViewControllerAnimated:YES];
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshHome" object:nil];
                                           tabb.selectedIndex = 0;
                                       }
                                       
                                   } else if([type isEqualToString:@"add-job"]) {
                                       if(![UVLAppglobals sharedAppGlobals].isClockedIn) {
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshShift" object:nil];
                                           tabb.selectedIndex = 2;
                                       } else {
                                           [UVLAppglobals sharedAppGlobals].shiftRefreshCall = YES;
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshHome" object:nil];
                                           tabb.selectedIndex = 0;
                                       }
                                   } else if([type isEqualToString:@"create-a-shift"]) {
                                       if(![UVLAppglobals sharedAppGlobals].isClockedIn) {
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshShift" object:nil];
                                           tabb.selectedIndex = 2;
                                       }
                                       
                                   } else if([type isEqualToString:@"update-a-shift"]) {
                                       if(![UVLAppglobals sharedAppGlobals].isClockedIn) {
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshShift" object:nil];
                                           tabb.selectedIndex = 2;
                                       }
                                       
                                   } else if([type isEqualToString:@"add-message"]) {
                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNotifications" object:nil];
                                       tabb.selectedIndex = 1;
                                   }
                               }];
    
    
    [alert addAction:OKAction];
    [self cancelAlarm];
    [ROOT_VIEW_CONTROLLER presentViewController:alert animated:YES completion:nil];
//
//    [self showAlert:alertController];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)registerNotitifications{
    
    NSDate *alertTime1 = [[NSDate date]
                          dateByAddingTimeInterval:5]; // replace .5 with 2
    
    UILocalNotification* lnBreakTimeRelaxationOver = [[UILocalNotification alloc] init];
    lnBreakTimeRelaxationOver.fireDate = alertTime1;
    lnBreakTimeRelaxationOver.soundName = UILocalNotificationDefaultSoundName;
    lnBreakTimeRelaxationOver.alertBody = NSLocalizedString(@"Break Time Is Over.", nil);
    lnBreakTimeRelaxationOver.timeZone = [NSTimeZone defaultTimeZone];
    lnBreakTimeRelaxationOver.applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] scheduleLocalNotification:lnBreakTimeRelaxationOver];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BreakTimeRelaxationOver" object:self];
    
    
    [NSTimer scheduledTimerWithTimeInterval:10
                                     target:self
                                   selector:@selector(BreakEnd)
                                   userInfo:nil
                                    repeats:NO];
    
    
}

-(void)BreakEnd{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BreakEnd" object:self];
    
}

-(void)showAlert:(UIAlertController *)alertController{
    if(!self.isShowingPOPUPAlready){
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        [topController presentViewController:alertController animated:YES completion:nil];
        self.isShowingPOPUPAlready = YES;
        // UIAlertController is presenting.Here
    }
}

- (BOOL)isAlertViewShowing{
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0){
            for (id view in subviews) {
                if ([view isKindOfClass:[UIAlertController class]]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

@end

