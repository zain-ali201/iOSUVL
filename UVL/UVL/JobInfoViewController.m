//
//  JobInfoViewController.m
//  UVL
//
//  Created by Osama on 27/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "JobInfoViewController.h"
#import "CTCheckbox.h"
#import "CollectionDeliveryVC.h"
#import "Constants.h"
#import "ApiManager.h"
#import "DataManager.h"
#import "VehicleDetails.h"
#import "UIColor+Style.h"
#import "LocationService.h"
#import "UVLAppglobals.h"
#import "SVProgressHUD.h"
#import "Utils.h"

@interface JobInfoViewController ()
{
    CGFloat screenWidth;
    CGFloat initialScrollViewY;
    NSMutableDictionary *serviceParams;
    NSString *driverLocation;
}
@end

@implementation JobInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(home:)];
    self.navigationItem.leftBarButtonItem=newBackButton;
    
    // Do any additional setup after loading the view.
    self.checkbox1.textLabel.text = @"";
    self.checkbox1.checked = NO;
    //[self getLocation];
    [self initalizeContent];
    
    driverLocation = [UVLAppglobals sharedAppGlobals].currentDriverLocation;
    
}
-(void)home:(UIBarButtonItem *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0 green:122.0/256 blue:255.0/256 alpha:1]];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.mainScroll setContentSize:CGSizeMake(0, 625)];
}

NSInteger *company;
NSInteger *name;
NSInteger *add1;
NSInteger *add2;
NSInteger *town;
NSInteger *postcode;

#pragma mark Intializing the View
-(void)initalizeContent{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handleSingleTap:)];
    tap.cancelsTouchesInView = NO;
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    [[self.declineReasontxtView layer] setBorderColor:[UIColor grayColor].CGColor];
    [[self.declineReasontxtView layer] setBorderWidth:1.0];
    [[self.declineReasontxtView layer] setCornerRadius:0];
    self.declineReasontxtView.textContainerInset = UIEdgeInsetsMake(0,0,0,0);
    [[self.specialInstructionstxtView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [[self.specialInstructionstxtView layer] setBorderWidth:1.0];
    [[self.specialInstructionstxtView layer] setCornerRadius:0];
    self.specialInstructionstxtView.textContainerInset = UIEdgeInsetsMake(0,0,0,0);
    
    self.specialInstructionstxtView.text = _jObj.specialInstructions;
    
//    _jObj.collectionCompany = @"";
//    _jObj.delivery_company = @"";
    
    if(_jObj.collectionCompany.length == 0)
    {
        company = 0;
        name = 62;
        add1 = 83;
        add2 = 104;
        town = 125;
        postcode = 146;
    }
    if(_jObj.collection_name.length == 0){
        if(_jObj.collectionCompany.length == 0)
        {
            company = 0;
            name = 0;
            add1 = 62;
            add2 = 83;
            town = 104;
            postcode = 125;
        }
        else
        {
            company = 62;
            name = 0;
            add1 = 83;
            add2 = 104;
            town = 125;
            postcode = 146;
        }
    }
    
    
    NSLog(@"%@",self.jObj.collectionCompany);
    if(_jObj.collectionCompany.length > 0){
        _companyName.text = _jObj.collectionCompany;
    }else{
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:62 onView:_customerName completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:83 onView:_address1 completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:104 onView:_address2 completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:125 onView:_town completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:146 onView:_postCode completion:^(BOOL finished) {
            }];
        }];
    }
    
        
    if(_jObj.collection_name.length > 0){
        _customerName.text = _jObj.collection_name;
    }
    else{
        if(_jObj.collectionCompany.length == 0){
            [UIView performWithoutAnimation:^{
                [Utils moveViewPosition:62 onView:_address1 completion:^(BOOL finished) {
                }];
            }];
            [UIView performWithoutAnimation:^{
                [Utils moveViewPosition:83 onView:_address2 completion:^(BOOL finished) {
                }];
            }];
            [UIView performWithoutAnimation:^{
                [Utils moveViewPosition:104 onView:_town completion:^(BOOL finished) {
                }];
            }];
            [UIView performWithoutAnimation:^{
                [Utils moveViewPosition:125 onView:_postCode completion:^(BOOL finished) {
                }];
            }];
        }
        else
        {
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:83 onView:_address1 completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:104 onView:_address2 completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:125 onView:_town completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:146 onView:_postCode completion:^(BOOL finished) {
            }];
        }];
        }
    }
    
    if(_jObj.collectionAddress.length > 0){
        _address1.text = _jObj.collectionAddress;
    }
    else{
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:104 onView:_address2 completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:125 onView:_town completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:146 onView:_postCode completion:^(BOOL finished) {
            }];
        }];
    }
    
    if(_jObj.collection_address2.length > 0){
        _address2.text = _jObj.collection_address2;
    }
    else{
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:125 onView:_town completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:146 onView:_postCode completion:^(BOOL finished) {
            }];
        }];
    }
    
    if(_jObj.collection_town.length > 0){
        _town.text = _jObj.collection_town;
    }
    else{
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:146 onView:_postCode completion:^(BOOL finished) {
            }];
        }];
    }
    
    _companyName.text = _jObj.collectionCompany;
    _customerName.text = _jObj.collection_name;
    _address1.text = _jObj.collectionAddress;
    _address2.text = _jObj.collection_address2;
    _town.text = _jObj.collection_town;
    _postCode.text = _jObj.collection_postcode;
    
    //Delivery
    
    if(_jObj.delivery_company.length > 0){
        _dcompanyName.text = _jObj.delivery_company;
    }else{
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:62 onView:_dcustomerName completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:83 onView:_daddress1 completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:104 onView:_daddress2 completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:125 onView:_dtown completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:146 onView:_dpostCode completion:^(BOOL finished) {
            }];
        }];
    }
    
    if(_jObj.delivery_name.length > 0){
        _dcustomerName.text = _jObj.delivery_name;
    }
    else{
        
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:83 onView:_daddress1 completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:104 onView:_daddress2 completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:125 onView:_dtown completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:146 onView:_dpostCode completion:^(BOOL finished) {
            }];
        }];
        
    }
    
    if(_jObj.delivery_address.length > 0){
        _daddress1.text = _jObj.delivery_address;
    }
    else{
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:104 onView:_daddress2 completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:125 onView:_dtown completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:146 onView:_dpostCode completion:^(BOOL finished) {
            }];
        }];
    }
    
    if(_jObj.delivery_address2.length > 0){
        _daddress2.text = _jObj.delivery_address2;
    }
    else{
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:125 onView:_dtown completion:^(BOOL finished) {
            }];
        }];
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:146 onView:_dpostCode completion:^(BOOL finished) {
            }];
        }];
    }
    
    if(_jObj.delivery_town.length > 0){
        _dtown.text = _jObj.delivery_town;
    }
    else{
        [UIView performWithoutAnimation:^{
            [Utils moveViewPosition:146 onView:_dpostCode completion:^(BOOL finished) {
            }];
        }];
    }
    
    _dcompanyName.text = _jObj.delivery_company;
    _dcustomerName.text = _jObj.delivery_name;
    _daddress1.text = _jObj.delivery_address;
    _daddress2.text = _jObj.delivery_address2;
    _dtown.text = _jObj.delivery_town;
    _dpostCode.text = _jObj.delivery_postcode;
    
    
    
//    if(_jObj.delivery_address2.length > 0){
//        _dcity.text = _jObj.delivery_address2;
//        if(_jObj.delivery_town.length > 0){
//            _dcountry.text = _jObj.delivery_town;
//        }
//        else{
//            [UIView performWithoutAnimation:^{
//                [Utils moveViewPosition:83 onView:_dpostcode completion:^(BOOL finished) {
//                }];
//            }];
//        }
//    }
//    else{
//        [UIView performWithoutAnimation:^{
//            [Utils moveViewPosition:83 onView:_dcountry completion:^(BOOL finished) {
//            }];
//        }];
//        [UIView performWithoutAnimation:^{
//            [Utils moveViewPosition:104 onView:_dpostcode completion:^(BOOL finished) {
//            }];
//        }];
//    }
//
//    if(_jObj.delivery_town.length > 0){
//        _dcountry.text = _jObj.delivery_name;
//    }
//    else{
//        [UIView performWithoutAnimation:^{
//            [Utils moveViewPosition:104 onView:_dpostcode completion:^(BOOL finished) {
//            }];
//        }];
//    }
    
    _noOfVehicles.text = [NSString stringWithFormat:@"%lu", (unsigned long)_jObj.vehiclesList.count];
    
    _name.text = _jObj.bookingName;
    NSLog(@"%@",self.jObj.paymentType);
    _countlbl.text = [NSString stringWithFormat:@"%d",_jObj.position];
    if(self.jObj.jobStatus == 0){
        self.jobStatus.textColor = [UIColor customRed];
        self.jobStatus.text = @"Job Status: NOT ASSIGNED";
    }else if(self.jObj.jobStatus == 1){
        self.jobStatus.textColor = [UIColor customOrange];
        self.jobStatus.text = @"Job Status: AWAITING APPROVAL";
    }else if(self.jObj.jobStatus == 2){
        self.jobStatus.textColor = [UIColor customRed];
        self.jobStatus.text = @"Job Status: ABORTED";
    }else if(self.jObj.jobStatus == 3){
        self.jobStatus.textColor = [UIColor customOrange];
        self.jobStatus.text = @"Job Status: EN-ROUTE COLLECTION";
    }else if(self.jObj.jobStatus == 4){
        self.jobStatus.textColor = [UIColor customOrange];
        self.jobStatus.text = @"Job Status: EN-ROUTE DELIVERY";
    }else if(self.jObj.jobStatus == 5){
        self.jobStatus.textColor = [UIColor customGreen];
        self.jobStatus.text = @"Job Status: COMPLETED";
    }
    
    if([self.jObj.paymentType isEqualToString:@"COC"] || [self.jObj.paymentType isEqualToString:@"COD"] || [self.jObj.paymentType isEqualToString:@"CARDOC"] || [self.jObj.paymentType isEqualToString:@"CARDOD"]){
        
        if([self.jObj.paymentType isEqualToString:@"COC"]){
            self.pricelbl.text = [NSString stringWithFormat:@"Cash on Collection: £%@",self.jObj.jobPrice];
        }
        else if([self.jObj.paymentType isEqualToString:@"COD"]){
            self.pricelbl.text = [NSString stringWithFormat:@"Cash on Delivery: £%@",self.jObj.jobPrice];
        }
        else if([self.jObj.paymentType isEqualToString:@"CARDOC"]){
            self.pricelbl.text = [NSString stringWithFormat:@"Card on Collection: £%@",self.jObj.jobPrice];
        }
        else if([self.jObj.paymentType isEqualToString:@"CARDOD"]){
            self.pricelbl.text = [NSString stringWithFormat:@"Card on Delivery: £%@",self.jObj.jobPrice];
        }
    }
    
//    if([self.jObj.paymentType isEqualToString:@"COC"] || [self.jObj.paymentType isEqualToString:@"COD"]){
//        if([self.jObj.paymentType isEqualToString:@"COC"]){
//            self.pricelbl.text = [NSString stringWithFormat:@"Cash on Collection: £%@",self.jObj.jobPrice];
//        }
//        else{
//            self.pricelbl.text = [NSString stringWithFormat:@"Cash on Delivery: £%@",self.jObj.jobPrice];
//        }
//    }
    else{
        self.positionOfView.constant = 57;
    }
}

#pragma mark DismissKeyboard
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self animateTextField:nil up:NO];
    [self.view endEditing:YES];
}
#pragma mark UITEXTVIEW Delegates
- (BOOL) textView: (UITextView*) textView
shouldChangeTextInRange: (NSRange) range
  replacementText: (NSString*) text
{
    if ([text isEqualToString:@"\n"]) {
        [self animateTextField:textView up:NO];
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView *) textView {
    [textView setText:@""];
    [self animateTextField:textView up:YES];
}

- (void) animateTextField: (UITextView*) textField up: (BOOL) up
{
    const int movementDistance = 200; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration: movementDuration];
    if(self.view.frame.origin.y < 0 || up)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(IBAction)acceptPressed:(id)sender{
    if(_checkbox1.checked){
        [self acceptServerCall];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Have you read and understood the instructions" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            [self acceptServerCall];
            _checkbox1.checked = YES;
        }];
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            // Other action
        }];

        [alertController addAction:yesAction];
        [alertController addAction:noAction];

        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    
}

-(void)acceptServerCall{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:CHANGE_JOB_STATUS forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:_jObj.jobId forKey:@"job_id"];
    [serviceParams setValue:_declineReasontxtView.text forKey:@"decline_reason"];
    [serviceParams setValue:@"ACCEPT" forKey:@"job_status"];
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }
    [self jobAcceptCall];
}

-(void)jobAcceptCall{
    [ApiManager postRequest:serviceParams success:^(id result){
        int flag = [[result objectForKey:@"flag"] intValue];
        NSString *message = [result objectForKey:@"message"];
        [UVLAppglobals sharedAppGlobals].justGoneForBreak = 0;
        if(flag == 1)
        {
            _jObj.jobStatus = 3;
            [self performSegueWithIdentifier:@"VehiclesCollection" sender:nil];
        }
    }failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

-(IBAction)rejectedPressed:(id)sender{
    if(_declineReasontxtView.text.length > 0 && ![_declineReasontxtView.text isEqualToString:@"Reason for decline"]){
        NSString *dID = (NSString *)
        [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
        NSString *dApikey = (NSString *)
        [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
        serviceParams = [NSMutableDictionary dictionary];
        [serviceParams setValue:CHANGE_JOB_STATUS forKey:@"request"];
        [serviceParams setValue:dID forKey:@"driver_id"];
        [serviceParams setValue:dApikey forKey:@"driver_api_key"];
        [serviceParams setValue:@"DECLINE" forKey:@"job_status"];
        [serviceParams setValue:_jObj.jobId forKey:@"job_id"];
        [serviceParams setValue:_declineReasontxtView.text forKey:@"decline_reason"];
        if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
            [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
        }
        else{
            [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
        }
        [self makeServerCall];
    }
    else{
        [self showAlertView:@"" message:@"Enter Reason for decline."];
    }
}

-(void)makeServerCall{
    [ApiManager getRequest:serviceParams success:^(id result){
        int flag = [[result objectForKey:@"flag"] intValue];
        if(flag == 1){
            _jObj.jobStatus = 2;
            [self.navigationController popViewControllerAnimated:NO];
        }
    }failure:^(NSError *error) {
        
    }];
}
#pragma mark GetLocation
-(void)getLocation{
    [SVProgressHUD show];
    
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
                 [SVProgressHUD dismiss];

                 CLPlacemark *placemark = [placemarks objectAtIndex:0];
                 NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                 NSString *Address = [[NSString alloc]initWithString:locatedAt];
                 NSString *Country = [[NSString alloc]initWithString:placemark.country];
                 driverLocation = [NSString stringWithFormat:@"%@, %@",Address,Country];
                 [UVLAppglobals sharedAppGlobals].currentDriverLocation = driverLocation;
             }
             else
             { [SVProgressHUD dismiss];
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
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //[self removeObserver:self forKeyPath:@"currentLocation"];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"VehiclesCollection"]) {
        CollectionDeliveryVC *tpd  = [segue destinationViewController];
        tpd.collectionArray = [_jObj.vehiclesList mutableCopy];
        tpd.deliveryArray = [_jObj.vehiclesList mutableCopy];
        tpd.jObj = _jObj;
    }
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

@end
