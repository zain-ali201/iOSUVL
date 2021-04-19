//
//  NotificationsViewController.m
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "NotificationsViewController.h"
#import "Constants.h"
#import "ApiManager.h"
#import "NotificationsDO.h"
#import "NotificaitonsCellsTableViewCell.h"
#import "NotiDetailsViewController.h"
#import "DataManager.h"
#import "LocationService.h"
#import "UIColor+Style.h"
#import "UVLAppglobals.h"
#import "MoreViewController.h"
#import "AppDelegate.h"


@interface NotificationsViewController (){
    NSMutableDictionary *serviceParams;
    UIRefreshControl *refreshControl;
}
@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendNotiServerCall:)
                                                 name:@"refreshNotifications"
                                               object:nil];
    _notificationsArray = [[NSMutableArray alloc] init];
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor clearColor];
    refreshControl.tintColor = [UIColor colorWithRed:30/255.0f green:102/255.0f blue:254/255.0f alpha:1.0];
    [refreshControl addTarget:self
                       action:@selector(refreshCall)
             forControlEvents:UIControlEventValueChanged];
    [self.tblview addSubview:refreshControl];
    [self prepareServerCall];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendNotiServerCall:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [self getLocation];
    if (![DataManager sharedManager].isNotificationRejected) {
        [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0 green:122.0/256 blue:255.0/256 alpha:1]];
    }
    else{
        [self.tabBarController.tabBar setTintColor:[UIColor redColor]];
    }
    [self.tblview reloadData];
}

NSTimer *timer3;

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [timer3 invalidate];
    timer3 = nil;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"breakOnKey"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"availableKey"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"otherWorkKey"])
    {
        timer3 = [NSTimer scheduledTimerWithTimeInterval: 600
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
                                   [timer3 invalidate];
                                   timer3 = nil;
                               }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) sendNotiServerCall:(NSNotification *) note {
    UIViewController *currentVC = self.navigationController.visibleViewController;
    if ([NSStringFromClass([currentVC class]) isEqualToString:@"NotificationsViewController"])
    {
        [self prepareServerCall];
    }
}

- (void)refreshNotifications:(NSNotification *) notification {
    [self prepareServerCall];
}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
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
                 [UVLAppglobals sharedAppGlobals].currentDriverLocation = [NSString stringWithFormat:@"%@, %@",Address,Country];
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
        
//        [SVProgressHUD dismiss];
//        driverLocation = [UVLAppglobals sharedAppGlobals].currentDriverLocation;
        
    }
}


#pragma mark Refresh Control
- (void)refreshCall
{
    [self prepareServerCall];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _notificationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"NotificationsCell";
    NotificaitonsCellsTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    NotificationsDO *obj = [_notificationsArray objectAtIndex:indexPath.row];
    cell.title.text = obj.title;
    if(obj.isApprovalNeeded){
        cell.title.textColor = [UIColor customRed];
    }else{
        cell.title.textColor = [UIColor customGrey];
    }
    cell.message.text = obj.message;
    cell.timeStamp.text = obj.dateCreated;
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 103;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NotificationsDO *obj = [_notificationsArray objectAtIndex:indexPath.row];
    if(![obj.read isEqualToString:@"1"]){
        [self readNotificationCall:obj.notificationId];
        obj.read = @"1";
    }
    //[self showAlertView:obj.title message:obj.message];
    [self performSegueWithIdentifier:@"NotificationDetail" sender:obj];
}

#pragma mark ServerCall
-(void)prepareServerCall{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:GET_NOTIFICATIONS forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [self makeServerCall];
}

-(void)readNotificationCall:(NSString *)nId{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:READ_NOTIFICATIONS forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:nId forKey:@"notification_id"];
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }
    [self readNotification];
}

-(void)readNotification{
    [ApiManager getRequest:serviceParams success:^(id result){
        
    }failure:^(NSError *error) {
        
    }];
    
}

-(void)makeServerCall{
    [ApiManager getRequest:serviceParams success:^(id result){
        NSArray *data  = (NSArray *)[result objectForKey:@"notifications_list"];
        [refreshControl endRefreshing];
        if (data) {
            if(![data isKindOfClass:[NSNull class]]){
                
                [UVLAppglobals sharedAppGlobals].notficationsCountTobeAp = 0;
                self.notificationsArray = [[NSMutableArray alloc] init];
                for (int i = 0; i < [data count]; i++){
                    NSDictionary *notiDict = [data objectAtIndex:i];
                    NotificationsDO *nModel = [[NotificationsDO alloc] initWithDictionary:notiDict];
                    if(nModel.isApprovalNeeded){
                        [UVLAppglobals sharedAppGlobals].notficationsCountTobeAp++;
                    }
                    NSString *notificationstoBeArpp = [NSString stringWithFormat:@"%d",[UVLAppglobals sharedAppGlobals].notficationsCountTobeAp];
                    if([UVLAppglobals sharedAppGlobals].notficationsCountTobeAp == 0){
                        [[[[[self tabBarController] tabBar] items]
                          objectAtIndex:1] setBadgeValue:nil];
                    }else{
                        [[[[[self tabBarController] tabBar] items]
                          objectAtIndex:1] setBadgeValue:notificationstoBeArpp];
                    }
                    [_notificationsArray addObject:nModel];
                }
                [_tblview reloadData];
            }
        }
        
    }failure:^(NSError *error) {
        
    }];
}

#pragma mark Show AlertView
-(void)showAlertView:(NSString *)tittle message:(NSString *)message{
    UIAlertController * alert= [UIAlertController
                                alertControllerWithTitle:tittle
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Okay"
                                style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction * action)
                                {
                                    //Handel your yes please button action here
                                    
                                }];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"NotificationDetail"]) {
        NotiDetailsViewController *nt = [segue destinationViewController];
        nt.notiObject = (NotificationsDO *)sender;
    }
}
@end
