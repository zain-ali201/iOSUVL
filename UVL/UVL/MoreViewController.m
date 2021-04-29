//
//  MoreViewController.m
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "MoreViewController.h"
#import "Constants.h"
#import "ApiManager.h"
#import "UVLAppglobals.h"
#import "HomeViewController.h"
#import "DefectViewController.h"

@interface MoreViewController (){
    NSMutableDictionary *serviceParams;
    BOOL breaked;
    BOOL available;
    
}
@end

@implementation MoreViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0 green:122.0/256 blue:255.0/256 alpha:1]];
    if(![UVLAppglobals sharedAppGlobals].isClockedIn){
        self.availableSwitch.enabled = NO;
        self.breakSwrich.enabled = NO;
        self.otherWorkSwitch.enabled = NO;
    }else{
        self.availableSwitch.enabled = YES;
        self.breakSwrich.enabled = YES;
        self.otherWorkSwitch.enabled = YES;
    }
    if([UVLAppglobals sharedAppGlobals].isClockedIn && !self.justOnce){
        self.justOnce = YES;
        [self getSwitchesSatuses];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"timerCheckFlag"])
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"breakOnKey"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"availableKey"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"otherWorkKey"])
        {
            self.availableSwitch.on = NO;
            self.breakSwrich.on = NO;
            self.otherWorkSwitch.on = NO;

            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"timerCheckFlag"];
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"otherWorkKey"];
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"availableKey"];
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"breakOnKey"];

        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(triggerAction:) name:@"BreakEnd" object:nil];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getSwitchesSatuses{
    serviceParams = [NSMutableDictionary dictionary];
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    NSString *sId = [UVLAppglobals sharedAppGlobals].shiftId;
    
    [serviceParams setValue:GET_MORE_STATUS forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:sId forKey:@"shift_id"];
    [self statusCall];
}

-(void)statusCall{
    [ApiManager postRequest:serviceParams success:^(id result){
        int flag = [[result objectForKey:@"flag"] intValue];
        NSDictionary *statuses = [result objectForKey:@"status"];
        if(flag){
            BOOL isPOA = [[statuses objectForKey:@"is_poa"] boolValue];
            BOOL isOnBreak = [[statuses objectForKey:@"is_on_break"] boolValue];
            BOOL isOnOtherWork = [[statuses objectForKey:@"on_other_work"] boolValue];
            
            if(isPOA){
                self.otherWorkSwitch.on = NO;
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"otherWorkKey"];
                self.breakSwrich.on  = NO;
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"breakOnKey"];
                self.availableSwitch.on = YES;
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"availableKey"];
            }
            else{
                self.availableSwitch.on = NO;
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"availableKey"];
            }
            if (isOnBreak){
                self.availableSwitch.on = NO;
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"availableKey"];
                self.otherWorkSwitch.on = NO;
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"otherWorkKey"];
                self.breakSwrich.on  = YES;
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"breakOnKey"];
            }
            else{
                self.breakSwrich.on  = NO;
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"breakOnKey"];
            }
            if(isOnOtherWork){
                self.availableSwitch.on = NO;
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"availableKey"];
                self.breakSwrich.on  = NO;
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"breakOnKey"];
                self.otherWorkSwitch.on = YES;
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"otherWorkKey"];
            }
            else{
                self.otherWorkSwitch.on = NO;
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"otherWorkKey"];
            }
        }else{
        }
    }failure:^(NSError *error) {
        
    }];
}

-(IBAction)PanicBtnPressed:(id)sender{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:PANIC forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [self makeServerCall];
}

-(IBAction)defectBtnAction:(id)sender
{
    NSString *defectID = [[NSUserDefaults standardUserDefaults]stringForKey:@"defect_id"];
    NSLog(@"defectID: %@", defectID);
    if (defectID != nil && ![defectID isEqualToString:@""])
    {
        DefectViewController* defectVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"DefectViewController"];
        [self.navigationController pushViewController:defectVC animated:TRUE];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Please create defect report." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)makeServerCall{
    [ApiManager postRequest:serviceParams success:^(id result){
        
        int flag = [[result objectForKey:@"flag"] intValue];
        NSString *message = [result objectForKey:@"message"];
        if(flag){
            [self showAlertView:@"Request sent" message:message];
            UINavigationController *moreVc = [[self.tabBarController viewControllers] objectAtIndex:0];
            NSArray *viewControllers = moreVc.viewControllers;
            HomeViewController *rootViewController = [viewControllers objectAtIndex:0];
            [rootViewController updateJobs];
        }else{
            self.breakSwrich.on = false;
            self.availableSwitch.on = false;
            [self showAlertView:@"Failure" message:message];
        }
    }failure:^(NSError *error) {
        
    }];
}

-(IBAction)callUrbanNumber:(id)sender{
    NSString *phNo = @"+441213278786";//@"+01213278786";
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        NSLog(@"Simulator");
    }
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

-(IBAction)availableAction:(UISwitch *)sender{
    
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"otherWorkKey"];
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"availableKey"];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"breakOnKey"];
    
    serviceParams = [NSMutableDictionary dictionary];
    available = sender.on;
    
    if(self.breakSwrich.isOn){
        self.breakSwrich.on = NO;
    }
    if(self.otherWorkSwitch.isOn){
        self.otherWorkSwitch.on = NO;
    }
    [UVLAppglobals sharedAppGlobals].justGoneForBreak = 3;
    [serviceParams setValue:@"0" forKey:@"on_other_work"];
    [serviceParams setValue:@"0" forKey:@"is_on_break"];
    NSString *avail = [NSString stringWithFormat:@"%d",available];
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    NSString *sId = [UVLAppglobals sharedAppGlobals].shiftId;
    
    [serviceParams setValue:ON_BREAK forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:sId forKey:@"shift_id"];
    [serviceParams setValue:avail forKey:@"is_poa"];
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }
    [self makeServerCall];
}

-(IBAction)otherWorkAction:(UISwitch *)sender{
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"otherWorkKey"];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"availableKey"];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"breakOnKey"];
    
    serviceParams = [NSMutableDictionary dictionary];
    BOOL isBreakerOn = sender.on;
    NSString *workStatus = [NSString stringWithFormat:@"%d",isBreakerOn];
    
    self.breakSwrich.on = NO;
    self.availableSwitch.on = NO;
    
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    NSString *sId = [UVLAppglobals sharedAppGlobals].shiftId;
    [UVLAppglobals sharedAppGlobals].justGoneForBreak = 3;
    [serviceParams setValue:ON_BREAK forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:sId forKey:@"shift_id"];
    [serviceParams setValue:@"0" forKey:@"is_poa"];
    [serviceParams setValue:@"0" forKey:@"is_on_break"];
    [serviceParams setValue:workStatus forKey:@"on_other_work"];
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }
    [self makeServerCall];
}

- (IBAction)brekedAction:(UISwitch *)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"otherWorkKey"];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"availableKey"];
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"breakOnKey"];
    
    [UVLAppglobals sharedAppGlobals].justGoneForBreak = 3;
    serviceParams = [NSMutableDictionary dictionary];
    breaked = sender.on;
    if(self.availableSwitch.isOn){
        self.availableSwitch.on = NO;
    }
    if(self.otherWorkSwitch.isOn){
        self.otherWorkSwitch.on = NO;
    }
    [serviceParams setValue:@"0" forKey:@"is_poa"];
    [serviceParams setValue:@"0" forKey:@"on_other_work"];
    NSString *onbreak = [NSString stringWithFormat:@"%d",breaked];
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    NSString *sId = [UVLAppglobals sharedAppGlobals].shiftId;
    [serviceParams setValue:ON_BREAK forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:sId forKey:@"shift_id"];
    [serviceParams setValue:onbreak forKey:@"is_on_break"];
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }
    
    [self makeServerCall];
}

-(void)breakOn{
    serviceParams = [NSMutableDictionary dictionary];
    self.breakSwrich.on  = YES;
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"breakOnKey"];
    if(self.availableSwitch.isOn){
        self.availableSwitch.on = NO;
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"availableKey"];
    }
    if(self.otherWorkSwitch.isOn){
        self.otherWorkSwitch.on = NO;
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"otherWorkKey"];
    }
    
    [serviceParams setValue:@"0" forKey:@"is_poa"];
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    NSString *sId = [UVLAppglobals sharedAppGlobals].shiftId;
    [serviceParams setValue:ON_BREAK forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:sId forKey:@"shift_id"];
    [serviceParams setValue:@"1" forKey:@"is_on_break"];
    [serviceParams setValue:@"0" forKey:@"is_normal"];
    [serviceParams setValue:self.jobIdForBreakOrPOA forKey:@"job_id"];
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }
    
    [self makeServerCall];
}

-(void)poaOn{
    serviceParams = [NSMutableDictionary dictionary];
    self.availableSwitch.on = YES;
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"availableKey"];
    
    if(self.breakSwrich.isOn){
        self.breakSwrich.on = NO;
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"breakOnKey"];
    }
    if(self.otherWorkSwitch.isOn){
        self.otherWorkSwitch.on = NO;
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"otherWorkKey"];
    }
    
    [serviceParams setValue:@"0" forKey:@"is_on_break"];
    
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    NSString *sId = [UVLAppglobals sharedAppGlobals].shiftId;
    
    [serviceParams setValue:ON_BREAK forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:sId forKey:@"shift_id"];
    [serviceParams setValue:@"1" forKey:@"is_poa"];
    [serviceParams setValue:@"0" forKey:@"is_normal"];
    [serviceParams setValue:self.jobIdForBreakOrPOA forKey:@"job_id"];
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }
    
    [self makeServerCall];
}

-(void)otherWorkOn{
    serviceParams = [NSMutableDictionary dictionary];
    self.otherWorkSwitch.on  = YES;
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"otherWorkKey"];
   
    if(self.breakSwrich.isOn){
        self.breakSwrich.on = NO;
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"breakOnKey"];
    }
    if(self.availableSwitch.isOn){
        self.availableSwitch.on = NO;
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"availableKey"];
        
    }
    
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    NSString *sId = [UVLAppglobals sharedAppGlobals].shiftId;
    
    [serviceParams setValue:ON_BREAK forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:sId forKey:@"shift_id"];
    [serviceParams setValue:@"0" forKey:@"is_poa"];
    [serviceParams setValue:@"0" forKey:@"is_normal"];
    [serviceParams setValue:@"0" forKey:@"is_on_break"];
    [serviceParams setValue:@"1" forKey:@"on_other_work"];
    [serviceParams setValue:self.jobIdForBreakOrPOA forKey:@"job_id"];
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }
    
    [self makeServerCall];
}

-(void)turnTheSwitchesoff{
    //1 for POA 2 for Break 3 for other work
    serviceParams = [NSMutableDictionary dictionary];
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    NSString *sId = [UVLAppglobals sharedAppGlobals].shiftId;
    [serviceParams setValue:ON_BREAK forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:sId forKey:@"shift_id"];
    [serviceParams setValue:@"0" forKey:@"is_poa"];
    [serviceParams setValue:@"0" forKey:@"is_normal"];
    [serviceParams setValue:@"0" forKey:@"is_on_break"];
    [serviceParams setValue:@"0" forKey:@"on_other_work"];
    [serviceParams setValue:self.jobIdForBreakOrPOA forKey:@"job_id"];
    switch ([UVLAppglobals sharedAppGlobals].swictchToChange) {
        case 1:
            self.availableSwitch.on = NO;
            break;
        case 2:
            self.breakSwrich.on = NO;
            break;
        case 3:
            self.otherWorkSwitch.on = NO;
            break;
        default:
            break;
    }
    [self makeServerCall];
}

-(void)timerCallturnTheSwitchesoff{
    //1 for POA 2 for Break 3 for other work
    serviceParams = [NSMutableDictionary dictionary];
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    NSString *sId = [UVLAppglobals sharedAppGlobals].shiftId;
    [serviceParams setValue:ON_BREAK forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:sId forKey:@"shift_id"];
    [serviceParams setValue:@"0" forKey:@"is_poa"];
//    [serviceParams setValue:@"0" forKey:@"is_normal"];
    [serviceParams setValue:@"0" forKey:@"is_on_break"];
    [serviceParams setValue:@"0" forKey:@"on_other_work"];
//    [serviceParams setValue:self.jobIdForBreakOrPOA forKey:@"job_id"];
    switch ([UVLAppglobals sharedAppGlobals].swictchToChange) {
        case 1:
            self.availableSwitch.on = NO;
            break;
        case 2:
            self.breakSwrich.on = NO;
            break;
        case 3:
            self.otherWorkSwitch.on = NO;
            break;
        default:
            break;
    }
    [self makeServerCall];
}

#pragma mark DELEGATES
-(void)startBreak{
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.selectedBreakTimeSlot forKey:DriverBreakTimeSlot];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"%lu",(unsigned long)self.selectedBreakTimeSlot);
    NSDate *alertTime = [[NSDate date]
                         dateByAddingTimeInterval:2]; //replace 1 with self.selectedBreakTimeSlot
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = alertTime;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertBody = NSLocalizedString(@"Break Time Is Over.", nil);
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = 0;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:DriverBreakTimeSlot forKey:@"identifier"];
    localNotification.userInfo = userInfo;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
}

-(void) breakSwitchDelegate:(VehicleOptionViewController *)sender{
    [self brekedAction:self];
}

-(void) poaSwitchDelegate:(VehicleOptionViewController *)sender{
    
}


#pragma mark NEW
-(void) triggerAction:(NSNotification *) notification
{
    NSDictionary *dict = notification.userInfo;
    NSLog(@"%@",dict);
}
@end
