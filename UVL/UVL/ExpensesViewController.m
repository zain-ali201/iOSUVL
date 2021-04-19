//
//  ExpensesViewController.m
//  UVL
//
//  Created by Osama on 05/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "ExpensesViewController.h"
#import "Constants.h"
#import "UVLAppglobals.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "LocationService.h"
#import "MoreViewController.h"
#import "AppDelegate.h"

@interface ExpensesViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    BOOL forReceipt;
    NSMutableDictionary *serviceParams;
    NSString *type;
    float progressFloat;
    NSString *driverLocation;
}
@end

@implementation ExpensesViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0 green:122.0/256 blue:255.0/256 alpha:1]];
    [self getLocation];
    if(![UVLAppglobals sharedAppGlobals].isClockedIn){
        self.submitBtn.enabled = NO;
        self.submitBtn.alpha = 0.5;
    }else{
        self.submitBtn.enabled = YES;
        self.submitBtn.alpha = 1.0;
    }
}

NSTimer *timer5;

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(![UVLAppglobals sharedAppGlobals].isClockedIn){
        [self.tabBarController setSelectedIndex:2];
    }
    [timer5 invalidate];
    timer5 = nil;
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"breakOnKey"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"availableKey"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"otherWorkKey"])
    {
//        NSDate *interval = [NSDate dateWithTimeIntervalSinceNow: 1.0];
//
//        timer5 = [[NSTimer alloc] initWithFireDate: interval
//                                              interval: 1.0
//                                                target: self
//                                              selector:@selector(onTick:)
//                                              userInfo:nil repeats:YES];
        
        
        timer5 = [NSTimer scheduledTimerWithTimeInterval: 600
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
                                   
//                                   [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"otherWorkKey"];
//                                   [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"availableKey"];
//                                   [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"breakOnKey"];
                                   
//                                   AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//                                   delegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//                                   delegate.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
//                                   UITabBarController *tabBar = (UITabBarController *)delegate.window.rootViewController;
//                                   [tabBar setSelectedIndex:4];
//                                   [delegate.window makeKeyAndVisible];
                                   
                                   [UVLAppglobals sharedAppGlobals].justGoneForBreak = 3;
                                   UINavigationController *moreVc = [[self.tabBarController viewControllers] objectAtIndex:4];
                                   NSArray *viewControllers = moreVc.viewControllers;
                                   MoreViewController *rootViewController = [viewControllers objectAtIndex:0];
                                   [rootViewController timerCallturnTheSwitchesoff];
//                                   [self changeJobStatusCall];
                                   
                                   [timer5 invalidate];
                                   timer5 = nil;
                               }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
    //                                   initWithTarget:self
    //                                   action:@selector(handleSingleTap:)];
    //
    //    tap.cancelsTouchesInView = NO;
    //    tap.delegate = self;
    //    [self.view addGestureRecognizer:tap];
    UIToolbar *ViewForDoneButtonOnKeyboard = [[UIToolbar alloc] init];
    [ViewForDoneButtonOnKeyboard sizeToFit];
    UIBarButtonItem *btnDoneOnKeyboard = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                          style:UIBarButtonItemStylePlain target:self
                                                                         action:@selector(doneForReading:)];
    [ViewForDoneButtonOnKeyboard setItems:[NSArray arrayWithObjects:btnDoneOnKeyboard, nil]];
    _fuelAmount.inputAccessoryView = ViewForDoneButtonOnKeyboard;
    _fuelOdometer.inputAccessoryView = ViewForDoneButtonOnKeyboard;
    _tollAmount.inputAccessoryView = ViewForDoneButtonOnKeyboard;
    _expenseType.tag = 1;
    [[self.txtView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [[self.txtView layer] setBorderWidth:1.0];
    [[self.txtView layer] setCornerRadius:0];
    self.txtView.textContainerInset = UIEdgeInsetsMake(0,0,0,0);
    
    driverLocation = [UVLAppglobals sharedAppGlobals].currentDriverLocation;
}

-(void)getLocation
{
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    [[LocationService sharedInstance] startUpdatingLocation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"currentLocation"]) {
        // do some stuff
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
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
//        [SVProgressHUD dismiss];
//        driverLocation = [UVLAppglobals sharedAppGlobals].currentDriverLocation;
    }
}

- (IBAction)doneForReading:(id)sender
{
    
    [self.view endEditing:YES];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    return YES;
}
-(IBAction)expensetypeTapped:(id)sender{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:@"Choose your expense type"
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *Fuel = [UIAlertAction
                           actionWithTitle:@"Fuel"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action)
                           {
                               self.FuelNext.image = [UIImage imageNamed:@"next"];
                               self.tollView.hidden = YES;
                               self.otherView.hidden = YES;
                               [UIView transitionWithView:self.FuelView
                                                 duration:0.4
                                                  options:UIViewAnimationOptionTransitionCrossDissolve
                                               animations:^{
                                                   self.FuelView.hidden = NO;
                                                   [self.expenseType setTitle:@"Fuel" forState:UIControlStateNormal];
                                                   self.expenseType.tag = 1;
                                               }
                                               completion:NULL];
                           }];
    
    UIAlertAction *Toll = [UIAlertAction
                           actionWithTitle:@"Toll"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action)
                           {
                               self.FuelView.hidden = YES;
                               self.otherView.hidden = YES;
                               self.tollNext.image = [UIImage imageNamed:@"next"];
                               [UIView transitionWithView:self.tollView
                                                 duration:0.4
                                                  options:UIViewAnimationOptionTransitionCrossDissolve
                                               animations:^{
                                                   self.tollView.hidden = NO;
                                                   self.expenseType.tag = 2;
                                                   [self.expenseType setTitle:@"Toll" forState:UIControlStateNormal];
                                               }
                                               completion:NULL];
                           }];
    UIAlertAction *Other = [UIAlertAction
                            actionWithTitle:@"Other"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action)
                            {
                                self.tollView.hidden = YES;
                                self.FuelView.hidden = YES;
                                self.otherNext.image = [UIImage imageNamed:@"next"];
                                [UIView transitionWithView:self.otherView
                                                  duration:0.4
                                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                                animations:^{
                                                    self.otherView.hidden = NO;
                                                    self.expenseType.tag = 3;
                                                    [self.expenseType setTitle:@"Other" forState:UIControlStateNormal];
                                                }
                                                completion:NULL];
                            }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction *action)
                             {
                                 
                             }];
    [alertController addAction:Fuel];
    [alertController addAction:Toll];
    [alertController addAction:Other];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(IBAction)photoBtnPressed:(id)sender{
    if(_expenseType.tag == 1){
        [self showPhotoChoice];
    }else if(_expenseType.tag == 2){
        forReceipt = YES;
        [self showPickerChoice];
    }else if(_expenseType.tag ==3){
        forReceipt = YES;
        [self showPickerChoice];
    }
}

-(void)showPhotoChoice{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:@"Choose type"
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *Fuel = [UIAlertAction
                           actionWithTitle:@"Odometer"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action)
                           {
                               forReceipt = NO;
                               [self showPickerChoice];
                           }];
    
    UIAlertAction *Toll = [UIAlertAction
                           actionWithTitle:@"Receipt"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action)
                           {
                               forReceipt = YES;
                               [self showPickerChoice];
                           }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction *action)
                             {
                                 
                             }];
    [alertController addAction:Fuel];
    [alertController addAction:Toll];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)showPickerChoice{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:@"Choose Picker"
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *Fuel = [UIAlertAction
                           actionWithTitle:@"Camera"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action)
                           {
                               if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                               {
                                   UIImagePickerController* picker = [[UIImagePickerController alloc] init];
                                   picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                   picker.allowsEditing = YES;
                                   picker.delegate = self;
                                   [self presentViewController:picker animated:YES completion:NULL];
                               }
                               else
                               {
                                   UIAlertView *altnot=[[UIAlertView alloc]initWithTitle:@"Camera Not Available" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                   [altnot show];
                                   
                               }
                           }];
    
    UIAlertAction *Toll = [UIAlertAction
                           actionWithTitle:@"Gallery"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action)
                           {
                               UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                               
                               picker.delegate = self;
                               picker.editing = YES;
                               picker.allowsEditing = YES;
                               
                               picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                               [self presentViewController:picker animated:YES completion:NULL];
                           }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction *action)
                             {
                                 
                             }];
    [alertController addAction:Fuel];
    [alertController addAction:Toll];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    if(forReceipt){
        _receiptImage = chosenImage;
        CGImageRef cgrefO = [_odometerImage CGImage];
        
        if(_expenseType.tag == 1 && cgrefO != NULL)
            self.FuelNext.image = [UIImage imageNamed:@"tick"];
        else if(_expenseType.tag == 2)
            self.tollNext.image = [UIImage imageNamed:@"tick"];
        else if(_expenseType.tag == 3)
            self.otherNext.image = [UIImage imageNamed:@"tick"];
    }
    else{
        _odometerImage = chosenImage;
        CGImageRef cgrefO = [_receiptImage CGImage];
        
        if(_expenseType.tag == 1 && cgrefO != NULL)
            self.FuelNext.image = [UIImage imageNamed:@"tick"];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)submitPressed:(id)sender{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    NSString *sId = [UVLAppglobals sharedAppGlobals].shiftId;
    
    if(_expenseType.tag == 1){
        type = @"Fuel";
        CGImageRef cgref = [_receiptImage CGImage];
        CIImage *cim = [_receiptImage CIImage];
        CGImageRef cgrefO = [_odometerImage CGImage];
        CIImage *cimO = [_odometerImage CIImage];
        if (cim == nil && cgref == NULL){
            [self showAlertView:@"" message:@"Please provide Receipt image."];
        }
        else if(cimO == nil && cgrefO == NULL){
            [self showAlertView:@"" message:@"Please provide Odometer image."];
        }
        else if(!(_fuelOdometer.text.length > 0)){
            [self showAlertView:@"" message:@"Please enter Odometer reading."];
        }else if(!(_fuelAmount.text.length > 0)){
            [self showAlertView:@"" message:@"Please enter Amount."];
        }
        else{
            serviceParams = [[NSMutableDictionary alloc] init];
            [serviceParams setValue:EXPENSE_REQUEST forKey:@"request"];
            [serviceParams setValue:dApikey forKey:@"driver_api_key"];
            [serviceParams setValue:dID forKey:@"driver_id"];
            [serviceParams setValue:sId forKey:@"shift_id"];
            if(driverLocation.length > 0)
                [serviceParams setValue:driverLocation forKey:@"expense_location"];
            else
                [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"expense_location"];
            [serviceParams setValue:type forKey:@"expense_type"];
            [serviceParams setValue:_fuelAmount.text forKey:@"expense_amount"];
            [serviceParams setValue:_fuelOdometer.text forKey:@"vehicle_odometer"];
            [self serverCall];
        }
    }else if(_expenseType.tag == 2){
        type = @"Toll";
        CGImageRef cgref = [_receiptImage CGImage];
        CIImage *cim = [_receiptImage CIImage];
        if (cim == nil && cgref == NULL){
            [self showAlertView:@"" message:@"Please provide Receipt image."];
        }else if(!(_tollAmount.text.length > 0)){
            [self showAlertView:@"" message:@"Please enter Toll amount."];
        }
        else{
            serviceParams = [[NSMutableDictionary alloc] init];
            [serviceParams setValue:EXPENSE_REQUEST forKey:@"request"];
            [serviceParams setValue:dApikey forKey:@"driver_api_key"];
            [serviceParams setValue:dID forKey:@"driver_id"];
            [serviceParams setValue:sId forKey:@"shift_id"];
            if(driverLocation.length > 0)
                [serviceParams setValue:driverLocation forKey:@"expense_location"];
            else
                [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"expense_location"];
            [serviceParams setValue:type forKey:@"expense_type"];
            [serviceParams setValue:_tollAmount.text forKey:@"expense_amount"];
            [self serverCall];
            
        }
    }
    else if(_expenseType.tag == 3){
        type = @"Other";
        CGImageRef cgref = [_receiptImage CGImage];
        CIImage *cim = [_receiptImage CIImage];
        if (cim == nil && cgref == NULL){
            [self showAlertView:@"" message:@"Please provide Receipt image."];
        }else if(!(_txtView.text.length > 0)){
            [self showAlertView:@"" message:@"Please enter Description text"];
        }
        else{
            serviceParams = [[NSMutableDictionary alloc] init];
            [serviceParams setValue:EXPENSE_REQUEST forKey:@"request"];
            [serviceParams setValue:dApikey forKey:@"driver_api_key"];
            [serviceParams setValue:dID forKey:@"driver_id"];
            [serviceParams setValue:sId forKey:@"shift_id"];
            if(driverLocation.length > 0)
                [serviceParams setValue:driverLocation forKey:@"expense_location"];
            else
                [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"expense_location"];
            [serviceParams setValue:type forKey:@"expense_type"];
            [serviceParams setValue:_txtView.text forKey:@"description"];
            [self serverCall];
            
        }
    }
}

-(void)serverCall{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSData *profileData;
    NSData *profileData1;
    profileData = UIImagePNGRepresentation(_receiptImage);
    if(_expenseType.tag == 1)
        profileData1 = UIImagePNGRepresentation(_odometerImage);
    
    [SVProgressHUD showProgress:progressFloat];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    [manager POST:BASE_URL_PHOTOS parameters:serviceParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:profileData name:@"receipt_image[]" fileName:@"image.png" mimeType:@"image/png"];
        if(_expenseType.tag == 1)
            [formData appendPartWithFileData:profileData1 name:@"odometer_image[]" fileName:@"image.png" mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressFloat = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
            [SVProgressHUD showProgress:progressFloat];
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@" %@", responseObject);
        int flag = [[responseObject objectForKey:@"flag"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        if(flag){
            [self showAlertResponse:@"Success" message:message];
        }else{
            [self showAlertResponse:@"Failure" message:message];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
    
}

#pragma mark refreshAll
-(void)refreshAll{
    self.tollNext.image = [UIImage imageNamed:@"next"];
    self.otherNext.image = [UIImage imageNamed:@"next"];
    self.FuelNext.image = [UIImage imageNamed:@"next"];
    self.fuelAmount.text = @"";
    self.fuelOdometer.text = @"";
    self.tollAmount.text = @"";
    self.txtView.text = @"";
    self.receiptImage = nil;
    self.odometerImage = nil;
}

#pragma mark UITEXTVIEW Delegates
- (BOOL) textView: (UITextView*) textView
shouldChangeTextInRange: (NSRange) range
  replacementText: (NSString*) text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView *) textView {
    [textView setText:@""];
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

-(void)showAlertResponse:(NSString *)tittle message:(NSString *)message{
    UIAlertController * alert= [UIAlertController
                                alertControllerWithTitle:tittle
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Okay"
                                style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction * action)
                                {
                                    [self refreshAll];
                                    //Handel your yes please button action here
                                    
                                }];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
