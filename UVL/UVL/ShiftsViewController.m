
//  ShiftsViewController.m
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "ShiftsViewController.h"
#import "CTCheckbox.h"
#import "Constants.h"
#import "ApiManager.h"
#import "TruckInfoTableViewCell.h"
#import "DeclaraionsTableViewCell.h"
#import "SingleButtonCell.h"
#import "UVLAppglobals.h"
#import "Utils.h"
#import "VechicleOptionsCell.h"
#import "LocationService.h"
#import <QuartzCore/QuartzCore.h>
#import "LabelTableViewCell.h"
#import "JobDo.h"
#import "VehicleDo.h"
#import "VehicleCollectionCell.h"
#import <GONMarkupNamedColor.h>
#import <GONMarkupParserManager.h>
#import "SVProgressHUD.h"
#import "MoreViewController.h"
#import "AppDelegate.h"
#import "DefectViewController.h"

@import UserNotifications;
@interface ShiftsViewController ()
{
    NSMutableDictionary *serviceParams;
    BOOL isClockinRq;
    NSMutableArray *sectionsArray;
    NSArray *truckProperties;
    NSArray *declerations;
    NSMutableArray *checkForBoxes;
    NSMutableArray  *vehicleValues;
    NSString *odometerReading;
//    NSString *defectTicketNumber;
    NSString *endOdometer;
    NSString *cashIncome;
    NSString *driverLocation;
    BOOL clockedOut;
    UIRefreshControl *refreshControl;
    UIRefreshControl *scrollViewRefreshControl;
    NSInteger sectionsCount;
    
    BOOL progressBarFlag;
}

@end

@implementation ShiftsViewController
@synthesize datasource;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    progressBarFlag = TRUE;

    // Do any additional setup after loading the view.
    
    //    _scrollView.hidden = YES;
    //    _tblView.hidden = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshShift:) name:@"refreshShift" object:nil];
    _SecondTblView.hidden = YES;
    [self setupRefreshControl];
    [self setupSecondTableviewRefreshControl];
    [self prepareServerCall];
    [self initContent];
}

- (void) sendShiftServerCall:(NSNotification *) note {
    UIViewController *currentVC = self.navigationController.visibleViewController;
    if ([NSStringFromClass([currentVC class]) isEqualToString:@"ShiftsViewController"])
    {
        [self prepareServerCall];
    }
}

-(void)refreshShift:(NSNotification *)notification
{
     [self prepareServerCall];
}

-(void)targetMethod:(NSTimer *)timer
{
    [self initContent];
    [self prepareServerCall];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendShiftServerCall:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0 green:122.0/256 blue:255.0/256 alpha:1]];
    
    [self getLocation];
    if([UVLAppglobals sharedAppGlobals].shiftRefreshCall) {
        [UVLAppglobals sharedAppGlobals].shiftRefreshCall = NO;
        [self prepareServerCall];
    }
}
NSTimer *timer2;

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [timer2 invalidate];
    timer2 = nil;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"breakOnKey"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"availableKey"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"otherWorkKey"])
    {
        timer2 = [NSTimer scheduledTimerWithTimeInterval: 600
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
                                   [timer2 invalidate];
                                   timer2 = nil;
                               }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)setupRefreshControl
{
    progressBarFlag = FALSE;
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor clearColor];
    refreshControl.tintColor = [UIColor colorWithRed:30/255.0f green:102/255.0f blue:254/255.0f alpha:1.0];
    [refreshControl addTarget:self
                       action:@selector(refreshCall)
             forControlEvents:UIControlEventValueChanged];
    
    
    [self.tblView addSubview:refreshControl];
    
}

-(void)setupSecondTableviewRefreshControl{
    
    scrollViewRefreshControl = [[UIRefreshControl alloc] init];
    scrollViewRefreshControl.backgroundColor = [UIColor clearColor];
    scrollViewRefreshControl.tintColor = [UIColor colorWithRed:30/255.0f green:102/255.0f blue:254/255.0f alpha:1.0];
    [scrollViewRefreshControl addTarget:self
                                 action:@selector(refreshSecondTableviewCall)
                       forControlEvents:UIControlEventValueChanged];
    
    
    
    [self.SecondTblView addSubview:scrollViewRefreshControl];
    
}

#pragma mark Refresh Control
- (void)refreshCall
{
    [self prepareServerCall];
}

- (void)refreshSecondTableviewCall
{
    [self initContent];
    [self prepareServerCall];
}

-(void)initContent{
    sectionsArray = [[NSMutableArray alloc] initWithObjects:@"Your assigned vehicle",@"Declarations",@"",nil];
    truckProperties = @[@"Make",@"Model",@"Reg or Chassis No.",@"Fuel Amount"/*,@"Defect Ticket No."*/,@"Start Odometer"];
    declerations = @[@"You are fit for work and not under drug / alcohol influence",@"You are carrying your valid license for the vehicle type you are driving",@"You are carrying your valid DCPC card with you",@"You are carrying you valid Digi Card (if applicable)",@"You are wearing the correct PPE",@"You agree to our terms and conditions"];
    checkForBoxes = [[NSMutableArray alloc] initWithObjects:@1,@1,@1,@1,@1,@1, nil];
    vehicleValues = [[NSMutableArray alloc] init];
    [[self.txtView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [[self.txtView layer] setBorderWidth:1.0];
    [[self.txtView layer] setCornerRadius:0];
    self.txtView.textContainerInset = UIEdgeInsetsMake(0,0,0,0);
    
    driverLocation = [UVLAppglobals sharedAppGlobals].currentDriverLocation;
}

#pragma mark GetLocation
-(void)getLocation
{
//    if ([CLLocationManager locationServicesEnabled])
//    {
        [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:(NSKeyValueObservingOptionNew
                                                                                                  | NSKeyValueObservingOptionOld) context:nil];
        [[LocationService sharedInstance] startUpdatingLocation];
//    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"currentLocation"]) {
        // do some stuff
        CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
        [[LocationService sharedInstance] stopUpdatingLocation];
        [geocoder reverseGeocodeLocation:[LocationService sharedInstance].currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
         {
             [SVProgressHUD dismiss];
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

#pragma mark ServerCall
-(void)prepareServerCall
{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:CHECK_SHIF_STATUS forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    
    [self makeServerCall];
}

-(int)getTimeInSeconds:(NSString *)timeString{
    if([timeString containsString:@":"]){
        NSArray *components = [timeString componentsSeparatedByString:@":"];
        
        NSInteger hours   = [[components objectAtIndex:0] integerValue];
        NSInteger minutes = [[components objectAtIndex:1] integerValue];
        
        
        NSNumber *num =  [NSNumber numberWithInteger:(hours * 60 * 60) + (minutes * 60)];
        int timInterval = [num intValue];
        return timInterval;
    }else{
        return  0;
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

-(void)makeServerCall
{
    if (progressBarFlag)
    {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD show];
    }
    
    [ApiManager getRequestWihtoutProgress:serviceParams success:^(id result)
    {
        [refreshControl endRefreshing];
        progressBarFlag = TRUE;
        int flag = [[result objectForKey:@"flag" ]intValue];
        NSString *message = [result objectForKey:@"message"];
        
        if(flag)
        {
            _noShiftLbl.hidden = YES;
            NSString *notificationstoBeArpp = [result objectForKey:@"total_approval_notifications"] ;
            [UVLAppglobals sharedAppGlobals].notficationsCountTobeAp = [notificationstoBeArpp intValue];
            
            if([UVLAppglobals sharedAppGlobals].notficationsCountTobeAp == 0)
            {
                [[[[[self tabBarController] tabBar] items]
                  objectAtIndex:1] setBadgeValue:nil];
                [self cancelLocalNotification:@"UYLLocalNotification"];
            }
            else
            {
                [[[[[self tabBarController] tabBar] items]
                  objectAtIndex:1] setBadgeValue:notificationstoBeArpp];
                UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                UNMutableNotificationContent *content = [UNMutableNotificationContent new];
                content.title = @"Important";
                content.body = @"An important notification awaits your approval.";
                content.sound = [UNNotificationSound defaultSound];
                // Objective-C
                UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
                [center requestAuthorizationWithOptions:options
                                      completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                          if (!granted) {
                                              NSLog(@"Something went wrong");
                                          }
                                      }];
                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60
                                                                                                                repeats:YES];
                // Objective-C
                NSString *identifier = @"UYLLocalNotification";
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                                      content:content trigger:trigger];
                NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"UYLLocalNotification" forKey:@"notificationID"];
                content.userInfo = infoDict;
                
                [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    if (error != nil) {
                        NSLog(@"Something went wrong: %@",error);
                    }
                }];
                
            }
            
            [UVLAppglobals sharedAppGlobals].isON = YES;
            self.tblView.hidden = NO;
            self.noJobs.hidden = YES;
            self.noJobsTxtView.hidden = YES;
            NSDictionary *driverData  = (NSDictionary *)[result objectForKey:@"data"];
            NSLog(@"driverdata %@",driverData);
            
            if(driverData != nil)
            {
                isClockinRq = [[driverData objectForKey:@"clock_in_required"] boolValue];
                clockedOut = [[driverData objectForKey:@"clock_out"] boolValue];
                NSString *datenTime = [driverData objectForKey:@"shift_start_datetime"];
                NSString *shiftNotes = [driverData objectForKey:@"shift_notes"];
                _txtView.text = shiftNotes;
                BOOL isCurrentTimeBehind = [Utils isBehindtheCurrDate:datenTime];
                
                if([result objectForKey:@"job_detail"]){
                    _jobDetails = [result objectForKey:@"job_detail"];
                }
                
                if(isCurrentTimeBehind)
                {
                    // Shift Time in seconds
                    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                    NSDate *yourDate = [dateFormatter dateFromString:datenTime];
                    
                    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
                    hourFormatter.dateFormat = @"HH";
                    NSString *shiftHour = [hourFormatter stringFromDate:yourDate];
                    
                    NSDateFormatter *minuteFormatter = [[NSDateFormatter alloc] init];
                    minuteFormatter.dateFormat = @"mm";
                    NSString *shiftMinute = [minuteFormatter stringFromDate:yourDate];
                    
                    int hourInSeconds = [shiftHour intValue];
                    hourInSeconds = hourInSeconds * 60 * 60;
                    
                    int minuteInSeconds = [shiftMinute intValue];
                    minuteInSeconds = minuteInSeconds * 60;
                    
                    int shiftInSeconds = hourInSeconds + minuteInSeconds;
                    
                    //Current time in seconds
                    NSDate *now = [NSDate date];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/London"]];
                    formatter.dateFormat = @"HH";
                    NSString *currentHour = [formatter stringFromDate: now];
                    int currentHourInSeconds = [currentHour intValue];
                    currentHourInSeconds = currentHourInSeconds * 60 * 60;
                    
                    NSDateFormatter *currentMinuteFormatter = [[NSDateFormatter alloc] init];
                    [currentMinuteFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/London"]];
                    currentMinuteFormatter.dateFormat = @"mm";
                    NSString *currentMinute = [currentMinuteFormatter stringFromDate: now];
                    int currentMinuteInSeconds = [currentMinute intValue];
                    currentMinuteInSeconds = currentMinuteInSeconds * 60;
//                    
//                    NSDateFormatter *currentSecondFormatter = [[NSDateFormatter alloc] init];
//                    [currentSecondFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/London"]];
//                    currentSecondFormatter.dateFormat = @"ss";
//                    NSString *currentSecondString = [currentSecondFormatter stringFromDate: now];
//                    int currentSeconds = [currentSecondString intValue];
                    
                    int currentInSeconds = currentHourInSeconds + currentMinuteInSeconds;
                    // Setting timer
                    int timeToReload = shiftInSeconds - currentInSeconds;
                    
//                    [NSTimer scheduledTimerWithTimeInterval:timeToReload
//                                                     target:self
//                                                   selector:@selector(targetMethod:)
//                                                   userInfo:nil
//                                                    repeats:NO];
                    
                    
                    _tblView.hidden = YES;
                    _SecondTblView.hidden = NO;
                    _SecondTblView.allowsSelection = NO;
                    NSString *textToShow = @"";
                    if(_jobDetails.count > 0){
                        _noJobsLbl.hidden = YES;
                        int count = 0;
                        self.sizesArray = [NSMutableArray new];
                        for(int i =0; i < _jobDetails.count ; i++){
                            count += 1;
                            // NSString *number = [NSString stringWithFormat:@"%d",count];
                            _tempDict = (NSDictionary *)[_jobDetails objectAtIndex:i];
                            NSString *jobNotes = (NSString *)[_tempDict objectForKey:@"special_instructions"];
                            NSString *sizeOfText = [self calculateSize:jobNotes];
                            [_sizesArray addObject:sizeOfText];
                            
                        }
                    }
                    else{
                        _noJobsLbl.frame = CGRectMake(_noJobsLbl.frame.origin.x, _tblView.frame.origin.y + 280,  _noJobsLbl.frame.size.width, _noJobsLbl.frame.size.height);
                        _noJobsLbl.hidden = NO;
                    }
                    //self.tblView.hidden = YES;
                    sectionsCount = 0;
                    self.noJobs.hidden = NO;
                    self.noJobsTxtView.hidden = NO;
                    NSString *shiftStartDate;
                    if([driverData valueForKey:@"shift_start_date_text"]){
                        shiftStartDate = [driverData objectForKey:@"shift_start_date_text"];
                    }
                    NSString *vehicleMake = [driverData objectForKey:@"vehicle_make"];
                    NSString *vehicleModel = [driverData objectForKey:@"vehicle_model"];
                    NSString *vehicleReg = [driverData objectForKey:@"vehicle_reg"];
                    NSString *fuelAmount = [driverData objectForKey:@"fuel_amount"];
//                    NSString *timeText = [NSString stringWithFormat:@"%@ - Your shift will start at %@\n %@ %@ (%@) - £%@ fuel amount",shiftStartDate,[Utils jobStartHour:datenTime],vehicleMake, vehicleModel, vehicleReg, fuelAmount];
//
                     NSString *timeText = [NSString stringWithFormat:@"<grey>%@ - Your shift will start at %@</>\n\n<orange> %@ %@ (%@) - </><blue>£%@ fuel amount</>",shiftStartDate,[Utils jobStartHour:datenTime],vehicleMake, vehicleModel, vehicleReg, fuelAmount];
                        [[GONMarkupParserManager sharedParser] addMarkup:[GONMarkupNamedColor namedColorMarkup:[UIColor orangeColor]
                                                                                                        forTag:@"orange"]];
                    [[GONMarkupParserManager sharedParser] addMarkup:[GONMarkupNamedColor namedColorMarkup:[UIColor grayColor]
                                                                                                    forTag:@"grey"]];
                        [[GONMarkupParserManager sharedParser] addMarkup:[GONMarkupNamedColor namedColorMarkup:[UIColor colorWithRed:0.0/255.0 green:107.0/255.0 blue:255.0/255.0 alpha:1]
                                                                                                        forTag:@"blue"]];
                    
                    
                    _textToDisplay = timeText;
                    _shiftTime.attributedText = [[GONMarkupParserManager sharedParser] attributedStringFromString:timeText];
                    [_SecondTblView reloadData];
                    [scrollViewRefreshControl endRefreshing];
                    
                }
                else{
                    sectionsCount = sectionsArray.count;
                    [self.tblView reloadData];
                    self.tblView.hidden = NO;
                    self.noJobsLbl.hidden = YES;
                    self.SecondTblView.hidden = YES;
                    self.noJobs.hidden = YES;
                    self.noJobsTxtView.hidden = YES;
                }
                [UVLAppglobals sharedAppGlobals].isClockedIn = !isClockinRq;
                
                if(!clockedOut && !isClockinRq)
                {
                    endOdometer = @"";
                    cashIncome = @"";
                    
                    [sectionsArray replaceObjectAtIndex:1 withObject:@"End of Shift"];
                }
                
                if(clockedOut)
                {
                    [sectionsArray replaceObjectAtIndex:1 withObject:@"Declarations"];
                    [UVLAppglobals sharedAppGlobals].isClockedIn = NO;
                }
                
                NSString *odometerStr = [driverData objectForKey:@"start_odometer"];
                
                if (![odometerStr isEqualToString:@""] && ![odometerStr isEqualToString:@"0"])
                {
                    odometerReading = odometerStr;
                }
                
                NSString *shiftId = [driverData objectForKey:@"shift_id"];
                if (shiftId != nil && ![shiftId isEqualToString:@""])
                {
                    [[NSUserDefaults standardUserDefaults] setValue:shiftId forKey:@"shiftId"];
                }
                
                [UVLAppglobals sharedAppGlobals].shiftId = shiftId;
                NSString *make = [driverData objectForKey:@"vehicle_make"];
                [vehicleValues addObject:make];
                make = [driverData objectForKey:@"vehicle_model"];
                [vehicleValues addObject:make];
                make = [driverData objectForKey:@"vehicle_reg"];
                [vehicleValues addObject:make];
                make = [driverData objectForKey:@"fuel_amount"];
                [vehicleValues addObject:make];
                
//                make = [driverData objectForKey:@"defect_ticket_number"];
//                [vehicleValues addObject:make];
                
//                if (![make isEqualToString:@""])
//                {
//                    defectTicketNumber = [make mutableCopy];
//                }
                [_tblView reloadData];
            }
        }
        else
        {
            if (clockedOut)
            {
                [sectionsArray replaceObjectAtIndex:1 withObject:@"Declarations"];
//                defectTicketNumber = @"";
                odometerReading = @"";
                cashIncome = @"";
                endOdometer = @"";
            }
            
            //self.tblView.hidden = YES;
            [self cancelLocalNotification:@"UYLLocalNotification"];
            sectionsCount = 0;
            self.noJobs.hidden = NO;
            self.noJobsTxtView.hidden = NO;
            
            [_tblView reloadData];
            [UVLAppglobals sharedAppGlobals].isON = NO;
            if([message isEqualToString:@"no-record"]) {
                self.noJobsLbl.hidden = YES;
                _noShiftLbl.hidden = NO;
            }
            else
            {
                _noJobsLbl.hidden = NO;
                _noShiftLbl.hidden = YES;
                _noJobsLbl.text = @"No Jobs Available";
            }
        }
    }failure:^(NSError *error) {
        progressBarFlag = TRUE;
        [refreshControl endRefreshing];
    }];
}

-(NSString *) calculateSize:(NSString *)text{
    
    CGSize maximumLabelSize = CGSizeMake(300, FLT_MAX);
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, 0, 0);
    
    CGSize expectedLabelSize = [text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    NSString *size = [NSString stringWithFormat:@"%f", label.frame.size.height];
    return size;
}
#pragma mark Timer Delegates
- (void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime{
    
    NSString *msg = [NSString stringWithFormat:@"Countdown of Example 6 finished!\nTime counted: %i seconds",(int)countTime];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:msg delegate:nil cancelButtonTitle:@"Awesome!" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark DismissKeyboard
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    UITextField *odoMeter = (UITextField*)[_tblView viewWithTag:200];
    UITextField *endOdometertxt = (UITextField*)[_tblView viewWithTag:201];
    UITextField *cashIncometxt = (UITextField*)[_tblView viewWithTag:202];
    odometerReading = odoMeter.text;
    endOdometer = endOdometertxt.text;
    cashIncome = cashIncometxt.text;
    if(odoMeter.tag == 200){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tblView reloadRowsAtIndexPaths:indexPaths
                            withRowAnimation:UITableViewRowAnimationNone];
    }
    [self.view endEditing:YES];
}

#pragma mark COLLECTION VIEW DELEGATES
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return  1;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    CGSize some;
    //    if(IS_IPHONE_5){
    //        some = CGSizeMake(293, 26);
    //        return some;
    //    }
    //    if(IS_IPHONE_6){
    //        some = CGSizeMake(255, 26);
    //        return some;
    //    }
    //    else{
    //        some = CGSizeMake(387, 26);
    //        return some;
    //    }
    CGSize some;
    if(IS_IPHONE_5){
        some = CGSizeMake(130, 26);
        return some;
    }
    else{
        some = CGSizeMake(155, 26);
        return some;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _vehicleList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *carsCollection = @"CarsCollection";
    VehicleCollectionCell *cell = [collectionView
                                   dequeueReusableCellWithReuseIdentifier:carsCollection
                                   forIndexPath:indexPath
                                   ];
    //remove starting blank space from string
    NSString *trimmed = [[_vehicleList objectAtIndex:indexPath.row] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    cell.makeModel.text = trimmed;
    return cell;
}

#pragma mark TableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(tableView.tag == 1)
    {
        return 1;
    }
    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == 1)
    {
        return _jobDetails.count;
    }
    else
    {
        if(section == 0)
        {
            return truckProperties.count;
        }
        else if(section == 1 && [[sectionsArray objectAtIndex:section] isEqualToString:@"Declarations"])
        {
            return 7;
        }
        else if (section == 1 && [[sectionsArray objectAtIndex:section] isEqualToString:@"End of Shift"])
        {
            return 3;
        }
        else
        {
            return 1;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor colorWithRed:232.0/255.0f green:232.0/255.0f blue:232.0/255.0f alpha:1.0f]];
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(17, headerView.frame.origin.y/2 + 10, 320, 24);
    myLabel.font = [UIFont boldSystemFontOfSize:20];
    myLabel.text =  [sectionsArray objectAtIndex:section];
    myLabel.backgroundColor=[UIColor colorWithRed:232.0/255.0f green:232.0/255.0f blue:232.0/255.0f alpha:1.0f];
    myLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:107.0/255.0f blue:255.0/255.0f alpha:1.0f];
    [headerView addSubview:myLabel];
    return headerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView.tag == 1){
        return _textToDisplay;
    }
    return [sectionsArray objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView.tag == 1){
        
        return 0;
    }
    else{
        if(section != 2)
            return 45;
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *prop = @"TruckInfo";
    static NSString *Declarations = @"Declarations";
    static NSString *Agree = @"Agree";
    static NSString *confrim  = @"confrim";
    static NSString *clockOut = @"Cout";
    
    if(tableView.tag == 1)
    {
        LabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Label"];
        _tempDict = (NSDictionary *)[_jobDetails objectAtIndex:indexPath.row];
        NSString *vehicleCount = (NSString *)[_tempDict objectForKey:@"vehicle_count"];
        NSString *collectionPostCode = (NSString *)[_tempDict objectForKey:@"collection_postcode"];
        NSString *deliveryPostCode = (NSString *)[_tempDict objectForKey:@"delivery_postcode"];
        NSString *jobNotes = (NSString *)[_tempDict objectForKey:@"special_instructions"];
        NSString *vehicleList = [_tempDict objectForKey:@"vehicle_details"];
        [cell.carsCollection reloadData];
        _vehicleList = [vehicleList componentsSeparatedByString:@","];
        cell.vehicleName.text = vehicleList;
        cell.vehicleNo.text = vehicleCount;
        cell.deliveryAddress.text = deliveryPostCode;
        cell.collectionAddress.text = collectionPostCode;
        
        cell.jobStatus.text = jobNotes;
        
        CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
        
        CGSize expectedLabelSize = [jobNotes sizeWithFont:cell.jobStatus.font constrainedToSize:maximumLabelSize lineBreakMode:cell.jobStatus.lineBreakMode];
        CGRect newFrame = cell.jobStatus.frame;
        newFrame.size.height = [[self.sizesArray objectAtIndex:indexPath.row] floatValue];
        cell.jobStatus.frame = newFrame;
        cell.bottomLine.frame = CGRectMake(cell.bottomLine.frame.origin.x
                                           , cell.frame.size.height - 15, cell.bottomLine.frame.size.width, 1);
        
        return cell;
    }
    else if(indexPath.section == 0)
    {
        TruckInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:prop];
        cell.propertyLbl.text = [truckProperties objectAtIndex:indexPath.row];
        if(vehicleValues.count > 0 && indexPath.row != 4){
            cell.details.text = [vehicleValues objectAtIndex:indexPath.row];
            cell.Odometer.hidden = YES;
        }
//        if(indexPath.row == 4 && isClockinRq){
//            //for defect Ticket
//            cell.Odometer.tag = 199;
//            cell.Odometer.hidden = NO;
//            cell.details.hidden = YES;
//            cell.Odometer.text = defectTicketNumber;
//            cell.Odometer.enabled = YES;
//            if(!_isHideKeyboard) {
//                [cell.Odometer performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
//            }
//            _isHideKeyboard = NO;
//        }
        if(indexPath.row == 4 && isClockinRq){
            cell.Odometer.tag = 200;
            cell.Odometer.hidden = NO;
            cell.details.hidden = YES;
            cell.Odometer.text = odometerReading;
            cell.Odometer.enabled = YES;
            //                        [cell.Odometer becomeFirstResponder]   ;
        }
        else if(!isClockinRq && indexPath.row == 4){
            cell.Odometer.hidden = YES;
            cell.details.hidden = NO;
            cell.details.text = odometerReading;
            cell.Odometer.enabled = NO;
            
        }
//        else if(!isClockinRq && indexPath.row == 4){
//            cell.Odometer.hidden = NO;
//            cell.Odometer.text = defectTicketNumber;
//            cell.Odometer.enabled = NO;
//
//        }
        UIToolbar *ViewForDoneButtonOnKeyboard = [[UIToolbar alloc] init];
        [ViewForDoneButtonOnKeyboard sizeToFit];
        UIBarButtonItem *btnDoneOnKeyboard = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                              style:UIBarButtonItemStylePlain target:self
                                                                             action:@selector(doneBtnFromKeyboardClicked:)];
        [ViewForDoneButtonOnKeyboard setItems:[NSArray arrayWithObjects:btnDoneOnKeyboard, nil]];
        cell.Odometer.keyboardType = UIKeyboardTypeNumberPad;
        cell.Odometer.inputAccessoryView = ViewForDoneButtonOnKeyboard;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    }
    else if(indexPath.section == 1 && [[sectionsArray objectAtIndex:indexPath.section] isEqualToString:@"Declarations"])
    {
        if(indexPath.row == 0){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:confrim];
            return cell;
        }
        else{
            DeclaraionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Declarations];
            int check = [[checkForBoxes objectAtIndex:indexPath.row-1] intValue];
            if(check)
                cell.checkBox.image = [UIImage imageNamed:@"checked"];
            else
                cell.checkBox.image = [UIImage imageNamed:@"uncheck"];
            cell.desc.text = [declerations objectAtIndex:indexPath.row-1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    else if(indexPath.section == 1 && [[sectionsArray objectAtIndex:indexPath.section] isEqualToString:@"End of Shift"])
    {
        if(indexPath.row == 0)
        {
            TruckInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:clockOut];
            cell.propertyLbl.text = @"Odometer Reading";
            cell.Odometer.placeholder = @"Reading";
            cell.Odometer.tag = 201;
            cell.Odometer.hidden = NO;
            cell.details.hidden = YES;
            cell.Odometer.text = endOdometer;
            cell.Odometer.keyboardType = UIKeyboardTypeNumberPad;
            UIToolbar *ViewForDoneButtonOnKeyboard = [[UIToolbar alloc] init];
            [ViewForDoneButtonOnKeyboard sizeToFit];
            UIBarButtonItem *btnDoneOnKeyboard = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                  style:UIBarButtonItemStylePlain target:self
                                                                                 action:@selector(doneForEndReading:)];
            [ViewForDoneButtonOnKeyboard setItems:[NSArray arrayWithObjects:btnDoneOnKeyboard, nil]];
            cell.Odometer.inputAccessoryView = ViewForDoneButtonOnKeyboard;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if(indexPath.row == 1)
        {
            TruckInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:clockOut];
            cell.propertyLbl.text = @"Cash Income";
            cell.Odometer.placeholder = @"Income";
            cell.Odometer.tag = 202;
            cell.Odometer.hidden = NO;
            cell.details.hidden = YES;
            cell.Odometer.text = cashIncome;
            UIToolbar *ViewForDoneButtonOnKeyboard = [[UIToolbar alloc] init];
            [ViewForDoneButtonOnKeyboard sizeToFit];
            UIBarButtonItem *btnDoneOnKeyboardss = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                    style:UIBarButtonItemStylePlain target:self
                                                                                   action:@selector(doneForCashIncome:)];
            [ViewForDoneButtonOnKeyboard setItems:[NSArray arrayWithObjects:btnDoneOnKeyboardss, nil]];
            cell.Odometer.keyboardType = UIKeyboardTypeDecimalPad;
            cell.Odometer.inputAccessoryView = ViewForDoneButtonOnKeyboard;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            VechicleOptionsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextView"];
            cell.txtView.tag = 203;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    else
    {
        SingleButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:Agree];
        
        cell.btn.enabled = YES;
        cell.btn.alpha = 1.0;
        
        if([[sectionsArray objectAtIndex:1] isEqualToString:@"End of Shift"] && !clockedOut)
        {
            [cell.btn setTitle:@"Clock Out" forState:UIControlStateNormal];
            cell.btn.tag = 101;
            isClockinRq =  NO;
        }
        else if(isClockinRq)
        {
            cell.btn.tag = 100;
            [cell.btn setTitle:@"Agree & Clock In" forState:UIControlStateNormal];
        }
        else
        {
            cell.btn.enabled = NO;
            cell.btn.alpha = 0.5;
        }
        
        [cell.btn addTarget:self action:@selector(ClockIn:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 1){
        float labelSize = [[_sizesArray objectAtIndex:indexPath.row ] floatValue];
        if(labelSize <= 21)
            labelSize = 0;
        NSInteger row_Constant;
        if(_vehicleList.count % 2 == 0){
            row_Constant = _vehicleList.count / 2;
        }else{
            row_Constant = _vehicleList.count / 2 + 1;
        }
        if(labelSize >21 )
            return (90 + (labelSize/3)) + (row_Constant * 30);
        else
            return 90 + + (row_Constant * 30);
    }
    else{
        if(indexPath.section == 0){
            return 43;
        }
        else if(indexPath.section == 1 && [[sectionsArray objectAtIndex:indexPath.section] isEqualToString:@"End of Shift"]){
            if(indexPath.row == 2)
                return 140;
            return 43;
        }
        else
            return 33;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    UITextField *getTextView = (UITextField*)[_tblView viewWithTag:200];
    //    odometerReading = getTextView.text;
    if(indexPath.section == 1 && [[sectionsArray objectAtIndex:1] isEqualToString:@"Declarations"] && indexPath.row != 7 && indexPath.row != 0){
        [self.view endEditing:YES];
        int check = [[checkForBoxes objectAtIndex:indexPath.row-1] intValue];
        if(check)
            [checkForBoxes replaceObjectAtIndex:indexPath.row-1 withObject:@0];
        else
            [checkForBoxes replaceObjectAtIndex:indexPath.row-1 withObject:@1];
        
        NSInteger indexToLoad = indexPath.row -1 ;
        // Build the two index paths
        NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:indexToLoad inSection:1];
        
        // Add them in an index path array
        NSArray* indexArray = [NSArray arrayWithObjects:indexPath1, nil];
        // Launch reload for the two index path
        [self.tblView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
        _isHideKeyboard = YES;
        [_tblView reloadData];
    }
}

#pragma mark Clock IN
-(void)ClockIn:(UIButton*)sender
{
    UIButton *btn  = (UIButton*)sender;
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    NSString *sId = [UVLAppglobals sharedAppGlobals].shiftId;
    if(btn.tag == 100)
    {
        BOOL declarationAccepted = YES;
        for (int i = 0; i<6; i++) {
            NSNumber *tempUncheck = checkForBoxes[i];
            NSInteger uncheck = [tempUncheck integerValue];
            if(uncheck == 0){
                declarationAccepted = NO;
            }
        }
        
        if(odometerReading.length > 0  /*&& defectTicketNumber.length > 0*/ && [odometerReading intValue] > 0){
            if(declarationAccepted) {
                serviceParams = [[NSMutableDictionary alloc] init];
                [serviceParams setValue:SHIFT_START forKey:@"request"];
                [serviceParams setValue:dApikey forKey:@"driver_api_key"];
                [serviceParams setValue:dID forKey:@"driver_id"];
                [serviceParams setValue:sId forKey:@"shift_id"];
                
//                [serviceParams setValue:defectTicketNumber forKey:@"defect_ticket_no"];
                
                [serviceParams setValue:[Utils getTodayDateWithoutTime] forKey:@"date_start"];
                if(driverLocation.length > 0){
                    [serviceParams setValue:driverLocation forKey:@"date_start_location"];
                }
                else{
                    [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"date_start_location"];
                }
                [serviceParams setValue:[checkForBoxes objectAtIndex:0] forKey:@"driver_fit_for_work"];
                [serviceParams setValue:[checkForBoxes objectAtIndex:1] forKey:@"driver_valid_license"];
                [serviceParams setValue:[checkForBoxes objectAtIndex:2] forKey:@"driver_valid_dcpc_card"];
                [serviceParams setValue:[checkForBoxes objectAtIndex:3] forKey:@"driver_valid_digi_card"];
                [serviceParams setValue:[checkForBoxes objectAtIndex:4] forKey:@"driver_wearing_correct_ppe"];
                [serviceParams setValue:[checkForBoxes objectAtIndex:5] forKey:@"driver_agreed_terms"];
                
                UITextField *field = (UITextField *)[self.tblView viewWithTag:200];
                odometerReading = field.text;
                [serviceParams setValue:odometerReading forKey:@"start_odometer"];
                [self clockinCall];
            } else {
                [self showAlertView:nil message:@"Please Confirm All Declarations"];
            }
        }
        else
        {
            if([odometerReading intValue] < 0 || [odometerReading isEqualToString:@""])
            {
                [self showAlertView:nil message:@"Enter Odometer Reading"];
            }
//            else if(defectTicketNumber.length < 1 || [defectTicketNumber isEqualToString:@""])
//            {
//                [self showAlertView:nil message:@"Enter defect ticket number"];
//            }
        }
        
    }
    else if(btn.tag == 101)
    {
        if(endOdometer.length > 0 && cashIncome.length > 0){
            serviceParams = [[NSMutableDictionary alloc] init];
            [serviceParams setValue:END_SHIFT forKey:@"request"];
            [serviceParams setValue:dApikey forKey:@"driver_api_key"];
            [serviceParams setValue:dID forKey:@"driver_id"];
            [serviceParams setValue:sId forKey:@"shift_id"];
            [serviceParams setValue:[Utils getTodayDateWithoutTime] forKey:@"date_end"];
            if(driverLocation.length > 0)
            {
                [serviceParams setValue:driverLocation forKey:@"date_end_location"];
            }
            else
            {
                [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"date_end_location"];
            }
            [serviceParams setValue:cashIncome forKey:@"cash_income"];
            [serviceParams setValue:endOdometer forKey:@"end_odometer"];
            if(_driver_notes.length == 0)
            {
                _driver_notes = @" ";
            }
            [serviceParams setValue:_driver_notes forKey:@"shift_notes"];
            [self clockOutCall];
        }
        else{
            [self showAlertView:@"" message:@"Please fill out the fields."];
        }
    }
}

-(void)clockinCall
{
    [ApiManager getRequest:serviceParams success:^(id result){
        [sectionsArray replaceObjectAtIndex:1 withObject:@"End of Shift"];
        [self.tblView reloadData];
        int flag = [[result objectForKey:@"flag"] intValue];
        if(flag)
        {
            isClockinRq = NO;
            [UVLAppglobals sharedAppGlobals].isClockedIn = YES;
            [UVLAppglobals sharedAppGlobals].homeRefreshCall = YES;
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shiftStatus"];
            
            NSString *shiftId = [result objectForKey:@"shift_id"];
            if (shiftId != nil && ![shiftId isEqualToString:@""])
            {
                [[NSUserDefaults standardUserDefaults] setValue:shiftId forKey:@"shiftId"];
                DefectViewController* defectVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"DefectViewController"];
                [self.navigationController pushViewController:defectVC animated:TRUE];
            }
            else
            {
                [self.tabBarController setSelectedIndex:0];
            }
        }
    }failure:^(NSError *error) {

    }];
}

-(void)clockOutCall
{
    [ApiManager getRequest:serviceParams success:^(id result){
        NSDictionary *driverData  = (NSDictionary *)[result objectForKey:@"data"];
        clockedOut = YES;
        [self.tblView reloadData];
        [UVLAppglobals sharedAppGlobals].isClockedIn = NO;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Succesfully Clocked Out!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
//            [UVLAppglobals sharedAppGlobals].isClockedIn = isClockinRq;
            [self.tabBarController setSelectedIndex:0];
            _noShiftLbl.hidden = NO;
            [self prepareServerCall];
        }];
        
        [alertController addAction:yesAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        if(driverData != nil){
            
        }
    }failure:^(NSError *error) {
        
    }];
}

#pragma mark TEXTFIELD DELEGATES
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    // odometerReading = textField.text;
    [_tblView reloadData];
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag >= 201) {
        if(IS_IPHONE_6 || IS_IPHONE_6Plus){
            [self.tblView setContentOffset:CGPointMake(0, 100) animated:YES];
        } else {
            [self.tblView setContentOffset:CGPointMake(0, 200) animated:YES];

        }
    }
    if(textField.tag == 200 || textField.tag == 199) {
        NSLog(@"screen height %f",[[UIScreen mainScreen] bounds].size.height);
        [self.tblView setContentOffset:CGPointMake(0, 100) animated:YES];
    }
}
- (BOOL) textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
 replacementString:(NSString *)string {
    if(textField.tag == 200 || textField.tag == 199){
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([newString doubleValue] > 0 || [newString isEqualToString:@""])
        {
            // Text Field contains a numeric value greater than 0
            return YES;
        }
        else{
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"TEXT FIELD TAG IS %ld",textField.tag);
    if (textField.tag >= 201) {
        //[self.tblview setContentOffset:CGPointMake(0, 100) animated:YES];
        UITextField *field = (UITextField *)[self.tblView viewWithTag:201];
        endOdometer = field.text;
        UITextField *fieldP = (UITextField *)[self.tblView viewWithTag:202];
        cashIncome = fieldP.text;
    }
    else if (textField.tag == 200){
        UITextField *field = (UITextField *)[self.tblView viewWithTag:200];
        odometerReading = field.text;
    }
//    else if(textField.tag == 199)
//    {
//        UITextField *field = (UITextField *)[self.tblView viewWithTag:199];
//        defectTicketNumber = field.text;
//    }
}

#pragma mark TEXTVIEW DELEGATES
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        [self.tblView setContentOffset:CGPointMake(0, 0) animated:YES];
        return NO; // or true, whetever you's like
    }
    
     _driver_notes = textView.text;
    if([text isEqualToString:@""])
    {
        _driver_notes = [_driver_notes substringToIndex:[_driver_notes length]-1];
    }
    else{
        _driver_notes = [_driver_notes stringByAppendingString:text];
    }
  
   
    NSLog(@"driver notes %@", _driver_notes);
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *) textView {
    [textView setText:@""];
    if(IS_IPHONE_6Plus || IS_IPHONE_6) {
        [self.tblView setContentOffset:CGPointMake(0, 160) animated:YES];
    } else {
        [self.tblView setContentOffset:CGPointMake(0, 280) animated:YES];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    _driver_notes = textView.text;
    
}

#pragma mark Show AlertView
-(void)showAlertView:(NSString *)tittle message:(NSString *)message{
    UIAlertController * alert= [UIAlertController
                                alertControllerWithTitle:tittle
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Dismiss"
                                style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction * action)
                                {
                                    //Handel your yes please button action here
                                    
                                }];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark DONEBUTON
- (IBAction)doneBtnFromKeyboardClicked:(id)sender
{
    UITextField *odoMeter = (UITextField*)[_tblView viewWithTag:200];
    odometerReading = odoMeter.text;
    [self.tblView setContentOffset:CGPointMake(0, 0) animated:YES];
    //Hide Keyboard by endEditing or Anything you want.
    [self.view endEditing:YES];
}

- (IBAction)doneForEndReading:(id)sender
{
    UITextField *odoMeter = (UITextField*)[_tblView viewWithTag:201];
    endOdometer = odoMeter.text;
    //Hide Keyboard by endEditing or Anything you want.
    [self.tblView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.view endEditing:YES];
}

- (IBAction)doneForCashIncome:(id)sender
{
    UITextField *odoMeter = (UITextField*)[_tblView viewWithTag:202];
    cashIncome = odoMeter.text;
    //Hide Keyboard by endEditing or Anything you want.
    [self.tblView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.view endEditing:YES];
}

@end

