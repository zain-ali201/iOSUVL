//
//  HomeViewController.m
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "HomeViewController.h"
#import "ApiManager.h"
#import "Constants.h"
#import "JobDo.h"
#import "JobTableViewCell.h"
#import "VehicleDo.h"
#import "VehicleCollectionCell.h"
#import "JobInfoViewController.h"
#import "Utils.h"
#import "DataManager.h"
#import "SVProgressHUD.h"
#import "CollectionDeliveryVC.h"
#import "UVLAppglobals.h"
#import "UIColor+Style.h"
#import "MoreViewController.h"
#import "AppDelegate.h"

@interface HomeViewController (){
    UIGestureRecognizer *tapper;
    NSMutableDictionary *serviceParams;
    UIRefreshControl *refreshControl;
}
@end

@implementation HomeViewController
@synthesize datasource;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (sendRemoveCall:) name:@"CompleteNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendRemoveCall:) name:@"refreshHome" object:nil];
    _nojobCheck = false;
    _refreshCheck = false;
    [DataManager sharedManager].isUpdated = NO;
    // Do any additional setup after loading the view.
    [self prepareServerCall];
    [self setupRefreshControl];
    [self initalizeContent];
    
}

-(void)viewDidDisappear:(BOOL)animated{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

NSTimer *timer1;
NSString *timerInterval;

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(![UVLAppglobals sharedAppGlobals].isClockedIn)
    {
        [self.tabBarController setSelectedIndex:2];
        [self checkShiftStatus];
    }
    
    [timer1 invalidate];
    timer1 = nil;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"breakOnKey"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"availableKey"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"otherWorkKey"])
    {
        timer1 = [NSTimer scheduledTimerWithTimeInterval: 600
                                                  target: self
                                                selector: @selector(showAlertView)
                                                userInfo: nil
                                                 repeats: YES];
    }
}

-(void)checkShiftStatus
{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:CHECK_SHIF_STATUS forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    
    [self callShiftApi];
}

-(void)callShiftApi
{
    [ApiManager getRequestWihtoutProgress:serviceParams success:^(id result){
        
        NSDictionary *driverData  = (NSDictionary *)[result objectForKey:@"data"];
        NSLog(@"shiftData %@",driverData);
        if(driverData != nil)
        {
            NSLog(@"checkShift:",[[driverData objectForKey:@"clock_in_required"] boolValue]);
            if([[driverData objectForKey:@"clock_in_required"] boolValue])
            {
                [self.tabBarController setSelectedIndex:2];
            }
            else
            {
                [self.tabBarController setSelectedIndex:0];
            }
        }
        else
        {
//            [self.tabBarController setSelectedIndex:2];
        }
     
    }failure:^(NSError *error) {
        
    }];
    
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
                                   [timer1 invalidate];
                                   timer1 = nil;
                               }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendServerCall:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0 green:122.0/256 blue:255.0/256 alpha:1]];
    if(![UVLAppglobals sharedAppGlobals].isClockedIn){
       // [self.tabBarController setSelectedIndex:2];
        _tblview.hidden = YES;
        _noJobs.hidden = NO;
    }
    else{
        _tblview.hidden = NO;
        _noJobs.hidden = YES;
    }
    
    if(_nojobCheck){
        _noJobs.hidden = NO;
    }
    else{
        _noJobs.hidden = YES;
    }
    
    _noJobs.frame = CGRectMake(_noJobs.frame.origin.x, _headerView.frame.origin.y + _headerView.frame.size.height + 20, _noJobs.frame.size.width, _noJobs.frame.size.height);
    //[self checkForClockIn];
    [UVLAppglobals sharedAppGlobals].justGoneForBreak = 0;
    [self removeCompletedJobs];
    if([UVLAppglobals sharedAppGlobals].homeRefreshCall) {
        [UVLAppglobals sharedAppGlobals].homeRefreshCall = NO;
        [self prepareServerCall];
    }
}

- (void) sendServerCall:(NSNotification *) note {
    if([UVLAppglobals sharedAppGlobals].isClockedIn){
    NSArray *array = [self.navigationController viewControllers];
        if(array.count == 1){
            [self prepareServerCall];
        }
    }
}

-(void)sendRemoveCall:(NSNotification *)notification {
    [self prepareServerCall];
}



#pragma mark Refresh Control
- (void)refreshCall
{
    [self prepareServerCall];
}

-(void)setupRefreshControl{
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor clearColor];
    refreshControl.tintColor = [UIColor colorWithRed:30/255.0f green:102/255.0f blue:254/255.0f alpha:1.0];
    [refreshControl addTarget:self
                       action:@selector(refreshCall)
             forControlEvents:UIControlEventValueChanged];
    [self.tblview addSubview:refreshControl];
}

#pragma mark REMOVE COMPLETED OBJECTS
-(void)removeCompletedJobs{
    if(datasource.count > 0){
        for (int i = 0; i < datasource.count; i++){
            JobDo *obj = [datasource objectAtIndex:i];
            if(obj.jobStatus == 5){
                [datasource removeObjectAtIndex:i];
            }
        }
        [_tblview reloadData];
    }

}

#pragma mark CheckForClockin
-(void)checkForClockIn{
    BOOL iSon = [UVLAppglobals sharedAppGlobals].isON;
    if(!iSon){
       // self.headerView.hidden = YES;
        self.footerView.hidden = YES;
        self.noJobs.hidden  = NO;
        
    }else{
        self.headerView.hidden = NO;
        self.footerView.hidden = NO;
        self.noJobs.hidden  = YES;
    }
}

-(void)updateJobs{
    [self prepareServerCall];
}
#pragma mark ServerCall
-(void)prepareServerCall{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:MOVEMENT_DETAIL forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [self makeServerCall];
}

-(void)makeServerCall{
    [SVProgressHUD show];
    [ApiManager getRequest:serviceParams success:^(id result){
        [SVProgressHUD dismiss];
        [refreshControl endRefreshing];
        [DataManager sharedManager].cacheCollectionDataArray = [[NSMutableArray alloc] init];
        [DataManager sharedManager].isUpdated = NO;
        NSArray *jobData  = (NSArray *)[result objectForKey:@"movement_detail"];
        NSString *shiftNotes = [result objectForKey:@"shift_notes"];
//        NSDictionary *driverData  = (NSDictionary *)[result objectForKey:@"data"];
//        NSArray *driverData  = (NSArray *)[result objectForKey:@"data"];
//        NSLog(@"checkDriverData %@",driverData);
        self.txtView.text = shiftNotes;
        if(jobData != nil && [jobData count] != 0){
            if(![jobData isKindOfClass:[NSNull class]]){
                datasource = [[NSMutableArray alloc] init];
                for (int i = 0; i < [jobData count]; i++){
                    NSDictionary *notiDict = [jobData objectAtIndex:i];
                    JobDo *jObj = [[JobDo alloc] initWithDictionary:notiDict];
                    [datasource addObject:jObj];
                }
                [self removeCompletedJobs];
                _tblview.hidden = NO;
                _noJobs.hidden = YES;
                _nojobCheck = false;
                [_tblview reloadData];
            }
        }
        else{
          //  self.headerView.hidden = YES;
             datasource = [[NSMutableArray alloc] init];
            _nojobCheck = true;
            self.footerView.hidden = YES;
            self.noJobs.hidden  = NO;
            [_tblview reloadData];
        }
    }failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark Intializing the View
-(void)initalizeContent{
    
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    [[self.txtView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [[self.txtView layer] setBorderWidth:1.0];
    [[self.txtView layer] setCornerRadius:0];
    self.txtView.textContainerInset = UIEdgeInsetsMake(0,0,0,0);
}

#pragma mark UITEXTVIEW Delegates
- (BOOL) textView: (UITextView*) textView
shouldChangeTextInRange: (NSRange) range
  replacementText: (NSString*) text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView *) textView {
    [textView setText:@""];
}

#pragma mark DismissKeyboard
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

#pragma mark COLLECTION VIEW DELEGATES
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return  1;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize some;
    if(IS_IPHONE_5){
        some = CGSizeMake(141, 35);
        return some;
    }
    else{
        some = CGSizeMake(141, 35);
        return some;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    UITableViewCell *cell = (UITableViewCell *)[(UIView *)collectionView superview];
    JobDo *temp = (JobDo*)[datasource objectAtIndex:cell.tag];
    return temp.vehiclesList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *carsCollection = @"CarsCollection";
    VehicleCollectionCell *cell = [collectionView
                                   dequeueReusableCellWithReuseIdentifier:carsCollection
                                   forIndexPath:indexPath
                                   ];
    UITableViewCell *tcell = (UITableViewCell *)[(UIView *)collectionView superview];
    JobDo *temp = (JobDo*)[datasource objectAtIndex:tcell.tag];
    VehicleDo *d = (VehicleDo*)[temp.vehiclesList objectAtIndex:indexPath.row];
    
    cell.makeModel.text = [NSString stringWithFormat:@"%@ / %@ / %@",d.vehicleMake,d.vehicleModel,d.vrnNo];
    
    return cell;
}

#pragma mark TableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"datacount %ld",datasource.count);
    if(datasource.count == 0)
    {
        _noJobs.hidden = NO;
    }
    return datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tblIdentifier = @"JobCell";
    JobTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tblIdentifier];
    JobDo *obj = [datasource objectAtIndex:indexPath.row];
    cell.name.text = obj.bookingName;
    cell.collectionAddress.text = obj.collection_postcode;
    cell.deliveryAddress.text = obj.delivery_postcode;
    cell.vehicleNo.text = [NSString stringWithFormat:@"%lu", (unsigned long)obj.vehiclesList.count];
    if(obj.jobStatus == 0){
        cell.jobStatus.textColor = [UIColor customRed];
        cell.jobStatus.text = @"Job Status: NOT ASSIGNED";
    }else if(obj.jobStatus == 1){
        cell.jobStatus.textColor = [UIColor customOrange];
        cell.jobStatus.text = @"Job Status: AWAITING APPROVAL";
    }else if(obj.jobStatus == 2){
        cell.jobStatus.textColor = [UIColor customRed];
        cell.jobStatus.text = @"Job Status: ABORTED";
    }else if(obj.jobStatus == 3){
        cell.jobStatus.textColor = [UIColor customOrange];
        cell.jobStatus.text = @"Job Status: EN-ROUTE COLLECTION";
    }else if(obj.jobStatus == 4){
        cell.jobStatus.textColor = [UIColor customOrange];
        cell.jobStatus.text = @"Job Status: EN-ROUTE DELIVERY";
    }else if(obj.jobStatus == 5){
        cell.jobStatus.textColor = [UIColor customGreen];
        cell.jobStatus.text = @"Job Status: COMPLETED";
    }
    obj.position = indexPath.row + 1;
    cell.countlbl.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.bottomLine.frame = CGRectMake(cell.bottomLine.frame.origin.x
                                       , cell.frame.size.height - 15, cell.bottomLine.frame.size.width, 1);
    cell.contentView.tag = indexPath.row;
    [cell.carsCollection reloadData];
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row_Constant;
    JobDo *obj = [datasource objectAtIndex:indexPath.row];
    if(obj.vehiclesList.count % 2 == 0){
        row_Constant = obj.vehiclesList.count / 2;
    }else{
        row_Constant = obj.vehiclesList.count / 2 + 1;
    }
    return 125 + (row_Constant * 27);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JobDo *obj = [datasource objectAtIndex:indexPath.row];
    [DataManager sharedManager].updatedJobId = obj.jobId;
    
    if(obj.jobStatus == 1 )
        [self performSegueWithIdentifier:@"jobDetailSegue" sender:obj];
    else if(obj.jobStatus == 3 || obj.jobStatus == 4 || obj.jobStatus == 5)
        [self performSegueWithIdentifier:@"AcceptedSegue" sender:obj];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"jobDetailSegue"]) {
        JobInfoViewController *tpd  = [segue destinationViewController];
        tpd.jObj = (JobDo *)sender;
    }
    if ([[segue identifier] isEqualToString:@"AcceptedSegue"]) {
        CollectionDeliveryVC *tpd  = [segue destinationViewController];
        JobDo *obj = (JobDo *)sender;
        tpd.jObj = (JobDo *)sender;
        tpd.collectionArray = [obj.vehiclesList mutableCopy];
        tpd.deliveryArray = [obj.vehiclesList mutableCopy];
    }
}

@end
