//
//  NotiDetailsViewController.m
//  UVL
//
//  Created by Osama on 17/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "NotiDetailsViewController.h"
#import "DataManager.h"
#import "Constants.h"
#import "ApiManager.h"
#import "LocationService.h"
#import "UVLAppglobals.h"
#import "MoreViewController.h"
#import "AppDelegate.h"

@import UserNotifications;
@interface NotiDetailsViewController (){
    NSMutableDictionary *serviceParams;
    NSString *driverLocation;
}
@end

@implementation NotiDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _detaillbl.text = _notiObject.message;
    self.navigationItem.title = _notiObject.title;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self setAcceptButton];
    [self getLocation];
    // Do any additional setup after loading the view.
    
    driverLocation = [UVLAppglobals sharedAppGlobals].currentDriverLocation;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![DataManager sharedManager].isNotificationRejected) {
        [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0 green:122.0/256 blue:255.0/256 alpha:1]];
    }
    else{
        [self.tabBarController.tabBar setTintColor:[UIColor redColor]];
    }
    
}

NSTimer *timer4;

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [timer4 invalidate];
    timer4 = nil;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"breakOnKey"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"availableKey"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"otherWorkKey"])
    {
        timer4 = [NSTimer scheduledTimerWithTimeInterval: 600
                                                  target: self
                                                selector: @selector(showAlertView)
                                                userInfo: nil
                                                 repeats: YES];
    }
}

-(void)showAlertView{
    NSString *showMessage = @"";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"breakOnKey"])
    {
        showMessage = @"Are you still on a break?";
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"availableKey"])
    {
        showMessage = @"Are you still on POA?";
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"otherWorkKey"])
    {
        showMessage = @"Are you still on Other Work?";
    }
    UIAlertController * alert= [UIAlertController
                                alertControllerWithTitle:@""
                                message:showMessage
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction * action)
                                {
                                    
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [[NSUserDefaults standardUserDefaults]  setValue:@"0" forKey:@"is_poa"];
                                   [[NSUserDefaults standardUserDefaults]  setValue:@"0" forKey:@"on_other_work"];
                                   [[NSUserDefaults standardUserDefaults]  setValue:@"0" forKey:@"is_on_break"];
                                   [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"timerCheckFlag"];
                                   
                                   [UVLAppglobals sharedAppGlobals].justGoneForBreak = 3;
                                   UINavigationController *moreVc = [[self.tabBarController viewControllers] objectAtIndex:4];
                                   NSArray *viewControllers = moreVc.viewControllers;
                                   MoreViewController *rootViewController = [viewControllers objectAtIndex:0];
                                   [rootViewController timerCallturnTheSwitchesoff];
                                   [timer4 invalidate];
                                   timer4 = nil;
                               }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark SET ACCEPT BUTTON
-(void)setAcceptButton{
    if(self.notiObject.isApprovalNeeded){
        self.acceptBtn.hidden = NO;
    }else{
        self.acceptBtn.hidden = YES;
    }
}
- (IBAction)btnReject:(id)sender {
    [self.tabBarController.tabBar setTintColor:[UIColor redColor]];
    [DataManager sharedManager].isNotificationRejected = YES;
}

-(void)prepareServerCall{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:ACCEPT_NOTICATION forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:self.notiObject.notificationId forKey:@"notification_id"];
    if(driverLocation.length > 0){
        [serviceParams setValue:driverLocation forKey:@"notification_approved_location"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"notification_approved_location"];
    }
    [self makeServerCall];
}

#pragma mark GetLocation
-(void)getLocation{
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    [[LocationService sharedInstance] startUpdatingLocation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"currentLocation"]) {
        // do some stuff
        CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
        [[LocationService sharedInstance] stopUpdatingLocation];
        [geocoder reverseGeocodeLocation:[LocationService sharedInstance].currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (!(error))
             {
                 CLPlacemark *placemark = [placemarks objectAtIndex:0];
                 NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                 NSString *Address = [[NSString alloc]initWithString:locatedAt];
                 NSString *Country = [[NSString alloc]initWithString:placemark.country];
                 driverLocation = [NSString stringWithFormat:@"%@, %@",Address,Country];
                 [UVLAppglobals sharedAppGlobals].currentDriverLocation = driverLocation;
             }
             else
             {
                 NSLog(@"Geocode failed with error %@", error);
                 NSLog(@"\nCurrent Location Not Detected\n");
                 //return;
             }
             /*---- For more results
              placemark.region);
              placemark.country);
              placemark.locality);
              placemark.name);
              placemark.ocean);
              placemark.postalCode);
              placemark.subLocality);
              placemark.location);
              ------*/
         }];
        
//        driverLocation = [UVLAppglobals sharedAppGlobals].currentDriverLocation;
    }
}
#pragma mark Cancel Notifications
- (void)cancelLocalNotification:(NSString*)notificationID {
    //loop through all scheduled notifications and cancel the one we're looking for
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] > 10.0f){
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // remove all local notification:
        [center removePendingNotificationRequestsWithIdentifiers:@[@"UYLLocalNotification"]];
    }
    else {
        
        NSLog(@"Delete notification below ios 10");
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *eventArray = [app scheduledLocalNotifications];
        for (int i=0; i<[eventArray count]; i++)
        {
            UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
            NSDictionary *userInfoCurrent = oneEvent.userInfo;
            NSString *ename=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"notificationID"]];
            
            if ([ename isEqualToString:@"UYLLocalNotification"])
            {
                //Cancelling local notification
                [app cancelLocalNotification:oneEvent];
                
                break;
            }
        }
    }
}
-(void)makeServerCall{
    [ApiManager getRequest:serviceParams success:^(id result){
        NSLog(@"%@",result);
        int flag = [[result objectForKey:@"flag"] intValue];
        if(flag == 1){
            [UVLAppglobals sharedAppGlobals].notficationsCountTobeAp--;
            if([UVLAppglobals sharedAppGlobals].notficationsCountTobeAp > 0){
            NSString *bageNo = [NSString stringWithFormat:@"%d", [UVLAppglobals sharedAppGlobals].notficationsCountTobeAp];
            [[[[[self tabBarController] tabBar] items]
              objectAtIndex:1] setBadgeValue:bageNo];
                
            }else{
                [self cancelLocalNotification:@"UYLLocalNotification"];
                [[[[[self tabBarController] tabBar] items]
                  objectAtIndex:1] setBadgeValue:nil];
            }
            self.acceptBtn.hidden = YES;
            self.notiObject.isApprovalNeeded = NO;
        }
    }failure:^(NSError *error) {
        
    }];
}

- (IBAction)btnAccept:(id)sender {
    [self prepareServerCall];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [[LocationService sharedInstance] removeObserver:self forKeyPath:@"currentLocation"];
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
