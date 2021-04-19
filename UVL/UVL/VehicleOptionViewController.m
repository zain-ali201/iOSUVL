//
//  VehicleOptionViewController.m
//  UVL
//
//  Created by Osama on 27/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

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

NSString *nameOfPerson;
NSString *emailOfPerson;
NSString *odometerOfcars = @"";
NSString *selectedMat = @"";
NSString *selectedKey = @"";
NSString *vehicleDefects = @"";
NSString *serviceBook = @"0";
NSString *loginKit = @"0";
NSString *spareWheel = @"0";
NSString *selectedVehicleID = @"";

@interface VehicleOptionViewController ()<MKDropdownMenuDelegate,MKDropdownMenuDataSource,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,UITextViewDelegate,UpdateSignatureView>
{
    NSArray *sectionsArray;
    NSArray *propArray;
    NSMutableArray *defaultFeildValues;
    UIGestureRecognizer *tapper;
    NSMutableDictionary *serviceParams;
    NSArray *noOfMats;
    NSArray *noOfKey;
    
    NSString *numMats;
    NSString *numKeys;
//    NSString *odometerOfcars;
//    NSString *serviceBook;
//    NSString *loginKit;
//    NSString *spareWheel;
//    NSString *selectedMat;
//    NSString *selectedKey;
//    NSString *vehicleDefects;
    //this is string for preference
    NSString *strForPropertyLbl;
    
    VehicleDetails *vehicleChechData;
    DataManager *sharMngr;
    float progressFloat;
    
    NSUserDefaults *userDefaults;
    
    BOOL isCheckedBoxSelected;
}
@end

@implementation VehicleOptionViewController
@synthesize delegate,jPrice;

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    sectionsArray = @[@"Vehicle Options",@"Acknowledgement"];
    propArray = @[@"Odometer",@"No. of mats",@"No. of keys",@"Service Book",@"Locking Kit",@"Spare Wheel/Kit",@"Vehicle Photos"];
    noOfMats = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    noOfKey = @[@"0",@"1",@"2",@"3"];
//    selectedKey = @"";
//    selectedMat = @"";
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
//    serviceBook = @"0";
//    loginKit = @"0";
//    spareWheel = @"0";
    defaultFeildValues = [[NSMutableArray alloc] init];
    sharMngr = [DataManager sharedManager];
    if (_isFromCollection  ) {
        //vehicleChechData = [sharMngr.cacheCollectionDataArray objectAtIndex:_selectedIndex];
    }
    else
    {
        vehicleChechData = [sharMngr.cacheDeliveryDataArray objectAtIndex:_selectedIndex];
    }
    
    if (selectedVehicleID != self.vehicleId)
    {
        selectedVehicleID = self.vehicleId;
        odometerOfcars = @"";
        selectedMat = @"";
        selectedKey = @"";
        vehicleDefects = @"";
        serviceBook = @"0";
        loginKit = @"0";
        spareWheel = @"0";
    }
    
    NSString *jType = [userDefaults stringForKey:@"journeyType"];
    
    if (![jType isEqualToString:_journeyType])
    {
        selectedVehicleID = self.vehicleId;
        odometerOfcars = @"";
        selectedMat = @"";
        selectedKey = @"";
        vehicleDefects = @"";
        serviceBook = @"0";
        loginKit = @"0";
        spareWheel = @"0";
        
        [userDefaults setObject:_journeyType forKey:@"journeyType"];
        [userDefaults setObject:@"" forKey:@"nameOfPerson"];
        [userDefaults setObject:@"" forKey:@"emailOfPerson"];
        
        nameOfPerson = @"";
        emailOfPerson = @"";
    }
    
    if (nameOfPerson.length == 0)
    {
        nameOfPerson = [userDefaults stringForKey:@"nameOfPerson"];
    }
    
    if (emailOfPerson.length == 0)
    {
        emailOfPerson = [userDefaults stringForKey:@"emailOfPerson"];
    }
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(home:)];
    self.navigationItem.leftBarButtonItem=newBackButton;
    [self initializeView];
    [self prepareServerCall];
}
-(void)home:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0 green:122.0/256 blue:255.0/256 alpha:1]];
    //    if([UVLAppglobals sharedAppGlobals].signatureImage){
    //        vehicleChechData.signatureImage = [UVLAppglobals sharedAppGlobals].signatureImage;
    //        self.sigImage =  [UVLAppglobals sharedAppGlobals].signatureImage;
    //    }
    [self.tblview reloadData];
}

-(void)initializeView{
    //    tapper = [[UITapGestureRecognizer alloc]
    //              initWithTarget:self action:@selector(handleSingleTap:)];
    //    tapper.cancelsTouchesInView = NO;
    //    [self.view addGestureRecognizer:tapper];
}

#pragma mark DONEBUTON
- (IBAction)doneForReading:(id)sender
{
    UITextField *txtField = (UITextField*)[_tblview viewWithTag:100];
    NSLog(@"TAG TAG  : %ld",txtField.tag);
    odometerOfcars = txtField.text;
    [[NSUserDefaults standardUserDefaults] setObject:odometerOfcars forKey:@"odometerOfcars"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCache"];
    [vehicleChechData setVehicle_odometer:odometerOfcars];
    [DataManager sharedManager].isUpdated = YES;
    [vehicleChechData setUpdatedJobId:[DataManager sharedManager].updatedJobId];
    
    //Hide Keyboard by endEditing or Anything you want.
    [self.view endEditing:YES];
}

- (IBAction)doneForMats:(id)sender
{
    UITextField *txtField = (UITextField*)[_tblview viewWithTag:101];
    NSLog(@"TAG TAG  : %ld",txtField.tag);
    numMats = txtField.text;
    //Hide Keyboard by endEditing or Anything you want.
    [self.view endEditing:YES];
}

- (IBAction)doneForKeys:(id)sender
{
    UITextField *txtField = (UITextField*)[_tblview viewWithTag:102];
    NSLog(@"TAG TAG  : %ld",txtField.tag);
    numKeys = txtField.text;
    //Hide Keyboard by endEditing or Anything you want.
    [self.view endEditing:YES];
}
//Columns in picker views

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return 1;
}
//Rows in each Column

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; {
    return noOfMats.count;
}

-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [noOfMats objectAtIndex:row];
}

#pragma mark ServerCall
-(void)prepareServerCall{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:GET_VEHICLE_DETAILS forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:_jobId forKey:@"job_id"];
    [serviceParams setValue:_vehicleId forKey:@"vehicle_id"];
    [serviceParams setValue:_journeyType forKey:@"journey_type"];
    [self makeServerCall];
}

-(void)makeServerCall
{
    [ApiManager getRequest:serviceParams success:^(id result){
        NSDictionary *tempDict = (NSDictionary *)result;
        int success = [[tempDict objectForKey:@"flag"] intValue];
        BOOL  isCashe = [DataManager sharedManager].isUpdated;
        BOOL isLast = [[tempDict objectForKey:@"is_last"] boolValue];
        self.isLastCar = isLast;
        _isCallSuccessful = NO;
        [self.tblview reloadData];
        
        if(success == 1)
        {
            NSDictionary *dict = [tempDict objectForKey:@"data"];
            details = [[VehicleDetails alloc] initWithDictionary:dict];
            details.rear_photos = [dict objectForKey:@"rear_photos"];
            details.nearside_photos = [dict objectForKey:@"nearside_photos"];
            
            if (details.personName.length > 0)
            {
                nameOfPerson = details.personName;
                [userDefaults setObject:nameOfPerson forKey:@"nameOfPerson"];
            }
            
            if (details.personEmail.length > 0)
            {
                emailOfPerson = details.personEmail;
                [userDefaults setObject:emailOfPerson forKey:@"emailOfPerson"];
            }
            
            _isCallSuccessful = YES;
            
            if(details.isCollectionData && [_journeyType isEqualToString:@"DELIVERY"])
            {
                _isCallSuccessful = NO;
                
                if (details.personName.length > 0)
                {
                    nameOfPerson = details.personName;
                    [userDefaults setObject:nameOfPerson forKey:@"nameOfPerson"];
                }
                
                if (details.personEmail.length > 0)
                {
                    emailOfPerson = details.personEmail;
                    [userDefaults setObject:emailOfPerson forKey:@"emailOfPerson"];
                }
                
                if (details.number_of_keys.length > 0)
                {
                    selectedKey = details.number_of_keys;
                }
                
                if (details.number_of_mats.length > 0)
                {
                    selectedMat = details.number_of_mats;
                }
                
                if (details.vehicle_odometer.length > 0)
                {
                    odometerOfcars = details.vehicle_odometer;
                }
                
                if (details.vehicle_defects.length > 0)
                {
                    vehicleDefects = details.vehicle_defects;
                }
                
//                nameOfPerson = details.personName;
//                emailOfPerson = details.personEmail;
                spareWheel = details.spare_wheel;
                loginKit  = details.locking_kit;
                serviceBook = details.service_book;
                
            }
            [defaultFeildValues addObject:details.vehicle_odometer];
            [defaultFeildValues addObject:details.number_of_mats];
            [defaultFeildValues addObject:details.number_of_keys];
            [defaultFeildValues addObject:details.service_book];
            [defaultFeildValues addObject:details.locking_kit];
            [defaultFeildValues addObject:details.spare_wheel];
            [defaultFeildValues addObject:details.vehicle_defects];
            selectedKey = details.number_of_keys;
            selectedMat = details.number_of_mats;
            [self.tblview reloadData];
        }
        else if(isCashe && [vehicleChechData.updatedJobId isEqualToString:[DataManager sharedManager].updatedJobId])
        {
            _isCallSuccessful = NO;
            selectedKey =vehicleChechData.number_of_keys;
            selectedMat = vehicleChechData.number_of_mats;
            odometerOfcars =vehicleChechData.vehicle_odometer;
            
            if (vehicleChechData.personName.length > 0)
            {
                nameOfPerson = details.personName;
                [userDefaults setObject:nameOfPerson forKey:@"nameOfPerson"];
            }
            
            if (vehicleChechData.personEmail.length > 0)
            {
                emailOfPerson = details.personEmail;
                [userDefaults setObject:emailOfPerson forKey:@"emailOfPerson"];
            }
            
            
//            nameOfPerson =vehicleChechData.personName;
//            emailOfPerson = vehicleChechData.personEmail;
            spareWheel = vehicleChechData.spare_wheel;
            loginKit  = vehicleChechData.locking_kit;
            serviceBook = vehicleChechData.service_book;
            vehicleDefects = vehicleChechData.vehicle_defects;
            self.sigImage = vehicleChechData.signatureImage;
            
            if (odometerOfcars == nil) {
                odometerOfcars = @"";
                
            }
            if (selectedMat == nil) {
                selectedMat = @"";
                
            } if (selectedKey == nil) {
                selectedKey = @"";
                
            } if (serviceBook == nil) {
                serviceBook=@"0";
                
                
            } if (loginKit == nil) {
                loginKit = @"0";
                
            } if (spareWheel == nil) {
                spareWheel=@"0";
                
            }
            numKeys = selectedKey;
            numMats = selectedMat;
            [defaultFeildValues addObject:odometerOfcars];
            [defaultFeildValues addObject:selectedMat];
            [defaultFeildValues addObject:selectedKey];
            [defaultFeildValues addObject:serviceBook];
            [defaultFeildValues addObject:loginKit];
            [defaultFeildValues addObject:spareWheel];
            [defaultFeildValues addObject:@""];
            [self.tblview reloadData];
        }
    }failure:^(NSError *error) {
        
    }];
}

#pragma mark DismissKeyboard
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

#pragma mark TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if(indexPath.row <= 6)
            return 43;
        else
            return 130;
    }
    else{
        if (self.isCOCOrCOD > 0 && self.isLastCar){
            return 418;
        }else{
            return 390;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 6){
        [self performSegueWithIdentifier:@"pushToVehiclePhotos" sender:nil];
    }
    else if(indexPath.section == 1 && !self.isCallSuccessful){
        [self performSegueWithIdentifier:@"pushTosignaturesView" sender:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 8;
    else
        return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(17, 10, 322, 24);
    myLabel.font = [UIFont boldSystemFontOfSize:20];
    myLabel.text =  [sectionsArray objectAtIndex:section];
    myLabel.backgroundColor=[UIColor clearColor];
    myLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:107.0/255.0f blue:255.0/255.0f alpha:1.0f];
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor colorWithRed:232.0/255.0f green:232.0/255.0f blue:232.0/255.0f alpha:1.0f]];
    [headerView addSubview:myLabel];
    return headerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionsArray objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *prop = @"Properties";
    static NSString *noofMats = @"matsNo";
    static NSString *noofKeys = @"matsKeys";
    static NSString *txtView = @"TextView";
    static NSString *Signature = @"Signature";
    
    if(indexPath.section == 0)
    {
        VechicleOptionsCell *cell;
        if(indexPath.row <= 6){
            if(indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 4  || indexPath.row == 5 ||  indexPath.row == 6){
                cell = [tableView dequeueReusableCellWithIdentifier:prop];
            }
            else if(indexPath.row == 1){
                cell = [tableView dequeueReusableCellWithIdentifier:noofMats];
            }
            else if(indexPath.row == 2){
                cell = [tableView dequeueReusableCellWithIdentifier:noofKeys];
            }
            cell.propertyLbl.text = [propArray objectAtIndex:indexPath.row];
            // this is string for preference
            strForPropertyLbl = cell.propertyLbl.text;
            
            if (cell.propertyLbl.text == nil)
            {
                cell.propertyLbl.text = strForPropertyLbl ;
            }
            cell.propertyField.tag = indexPath.row;
            cell.propertyField.delegate = self;
            if (indexPath.row ==1 ||indexPath.row ==2){
                cell.dropDown.tag = indexPath.row;
                cell.dropDown.delegate = self;
                cell.dropDown.dataSource = self;
                cell.dropDown.hidden = NO;
            }
            else{
                cell.dropDown.hidden = YES;
            }
            if(indexPath.row < 3){
                if(self.isCallSuccessful){
                    cell.dropDown.hidden = YES;
                    if (indexPath.row==1) {
                        cell.propertyField.text = selectedMat;
                    }
                    else if (indexPath.row==2){
                        cell.propertyField.text = selectedKey;
                    }
                    else{
                        cell.propertyField.text = [defaultFeildValues objectAtIndex:indexPath.row];
                    }
                    cell.propertyField.enabled = NO;
                }else{
                    cell.propertyField.enabled = YES;
                    if(indexPath.row == 0){
                        UIToolbar *ViewForDoneButtonOnKeyboard = [[UIToolbar alloc] init];
                        [ViewForDoneButtonOnKeyboard sizeToFit];
                        UIBarButtonItem *btnDoneOnKeyboard = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                              style:UIBarButtonItemStylePlain target:self
                                                                                             action:@selector(doneForReading:)];
                        UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                        [ViewForDoneButtonOnKeyboard setItems:[NSArray arrayWithObjects:flexibleSpaceLeft,btnDoneOnKeyboard, nil]];
                        cell.propertyField.inputAccessoryView = ViewForDoneButtonOnKeyboard;
                        cell.propertyField.placeholder = @"Reading";
                        cell.propertyField.tag = 100;
                        if (![odometerOfcars isEqualToString:@""]) {
                            cell.propertyField.text = odometerOfcars;
                        }
                    }else if(indexPath.row == 1){
                        UIToolbar *ViewForDoneButtonOnKeyboard = [[UIToolbar alloc] init];
                        [ViewForDoneButtonOnKeyboard sizeToFit];
                        UIBarButtonItem *btnDoneOnKeyboard = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                              style:UIBarButtonItemStylePlain target:self
                                                                                             action:@selector(doneForMats:)];
                        [ViewForDoneButtonOnKeyboard setItems:[NSArray arrayWithObjects:btnDoneOnKeyboard, nil]];
                        cell.propertyField.tag = 101;
                        cell.propertyField.inputAccessoryView = ViewForDoneButtonOnKeyboard;
                        cell.propertyField.placeholder = @"0 - 10";
                        if (![selectedMat isEqualToString:@""] && cell.propertyField.tag == 101) {
                            cell.propertyField.text = selectedMat;
                        }
                    }else{
                        UIToolbar *ViewForDoneButtonOnKeyboard = [[UIToolbar alloc] init];
                        [ViewForDoneButtonOnKeyboard sizeToFit];
                        UIBarButtonItem *btnDoneOnKeyboard = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                              style:UIBarButtonItemStylePlain target:self
                                                                                             action:@selector(doneForKeys:)];
                        [ViewForDoneButtonOnKeyboard setItems:[NSArray arrayWithObjects:btnDoneOnKeyboard, nil]];
                        cell.propertyField.tag = 102;
                        cell.propertyField.inputAccessoryView = ViewForDoneButtonOnKeyboard;
                        cell.propertyField.placeholder = @"0 - 3";
                        if (![selectedKey isEqualToString:@""]) {
                            cell.propertyField.text = selectedKey;
                        }
                    }
                }
                cell.yesOrNo.hidden = YES;
            }
            else{
                if(_isCallSuccessful){
                    cell.yesOrNo.enabled = NO;
                    cell.yesOrNo.on = [[defaultFeildValues objectAtIndex:indexPath.row] boolValue];
                }else{
                    [cell.yesOrNo addTarget: self action: @selector(flip:) forControlEvents: UIControlEventValueChanged];
                    cell.yesOrNo.tag = indexPath.row * 10;
                    cell.yesOrNo.enabled = YES;
                    if(indexPath.row == 3){
                        cell.yesOrNo.on = [serviceBook boolValue];
                    }
                    else if(indexPath.row == 4){
                        cell.yesOrNo.on = [loginKit boolValue];
                    } else  if(indexPath.row == 5){
                        cell.yesOrNo.on = [spareWheel boolValue];
                    }
                }
                cell.propertyField.hidden = YES;
                cell.dropDown.hidden = YES;
                cell.yesOrNo.hidden = NO;
            }
            if(indexPath.row == 6){
                cell.propertyField.enabled = NO;
                cell.yesOrNo.hidden = YES;
                cell.aview.hidden = NO;
            }
        }
        else if(indexPath.row == 7){
            cell = [tableView dequeueReusableCellWithIdentifier:txtView];
            if(_isCallSuccessful ){
                cell.txtView.text = [defaultFeildValues objectAtIndex:indexPath.row-1];
                cell.txtView.editable = NO;
            }
            else if(details.isCollectionData == 1){
                cell.txtView.text = [defaultFeildValues objectAtIndex:indexPath.row-1];
                cell.txtView.editable = YES;
            }
            else{
                cell.txtView.editable = YES;
            }
            cell.txtView.delegate = self;
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else{
        AcknowledgementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Signature];
        cell.checkbox1.hidden = YES;
        cell.checkbox1.tag = 801;
        if((self.isCOCOrCOD == 1 || self.isCOCOrCOD == 3) && self.isFromCollection && self.isLastCar){
            cell.checkbox1.textLabel.text = [NSString stringWithFormat:@"Have you collected the Payment of £%@?",self.jPrice];
            cell.checkbox1.hidden = NO;
        }
        else if((self.isCOCOrCOD == 2 || self.isCOCOrCOD == 4) && !self.isFromCollection && self.isLastCar){
            
            cell.checkbox1.textLabel.text = [NSString stringWithFormat:@"Have you collected the Payment of £%@?",self.jPrice];
            cell.checkbox1.hidden = NO;
        }
        else {
            cell.checkbox1.hidden  = YES;
            cell.checkbox1.checked =  YES;
            isCheckedBoxSelected = YES;
        }
        if(_isCallSuccessful){
            cell.checkbox1.hidden  = YES;
        }
        if(self.isCallSuccessful || details.isCollectionData){
            
            if(!self.isCallSuccessful  && details.isCollectionData == 0){
                CGImageRef cgref = [self.sigImage CGImage];
                CIImage *cim = [self.sigImage CIImage];
                if (cim == nil && cgref == NULL)
                {
                    NSLog(@"no underlying data");
                }else{
                    cell.signatureImg.image = self.sigImage;
                }
            }
            else{
                cell.signatureImg.image = self.sigImage;
            }
            if(details.isCollectionData == 0)
            {
                cell.signatureImg.imageURL =  [NSURL URLWithString:details.signatureImageUrl];
                NSLog(@"first");
                
                if (details.personName.length > 0)
                {
                    cell.name.text = details.personName;
                }
                else
                {
                    cell.name.text = nameOfPerson;
                }
                
                if (details.personEmail.length > 0)
                {
                    cell.email.text = details.personEmail;
                }
                else
                {
                    cell.email.text = emailOfPerson;
                }
            }
        }
        else
        {
            CGImageRef cgref = [self.sigImage CGImage];
            CIImage *cim = [self.sigImage CIImage];
            if (cim == nil && cgref == NULL)
            {
                NSLog(@"no underlying data");
            }else{
                cell.signatureImg.image = self.sigImage;
            }
            NSLog(@"second");
            
            if (nameOfPerson.length > 0)
            {
                cell.name.text = nameOfPerson;
            }
            else
            {
                cell.name.text = [userDefaults stringForKey:@"nameOfPerson"];
            }
            
            if (nameOfPerson.length > 0)
            {
                cell.email.text = emailOfPerson;
            }
            else
            {
                cell.email.text = [userDefaults stringForKey:@"emailOfPerson"];
            }
            
//            cell.name.text = nameOfPerson;
//            cell.email.text = emailOfPerson;
        }
        
        if(_isCallSuccessful){
            cell.submitBtn.enabled = NO;
            cell.checkbox1.checked = YES;
            cell.submitBtn.alpha = 0.5;
        }else {
            [cell.submitBtn addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.name.tag = 104;
        cell.email.tag = 105;
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

#pragma mark TextView Delegates
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if([textView.text isEqualToString:@"Vehicle Defects / Other"]){
        textView.text = @"";
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if(details.isCollectionData == 1){
        vehicleDefects = textView.text;
        vehicleDefects = [vehicleDefects stringByAppendingString:text];
        [defaultFeildValues replaceObjectAtIndex:6 withObject:vehicleDefects];
        NSLog(@"strings %@: %@: %@",vehicleDefects, [defaultFeildValues objectAtIndex:6], textView.text);
    }
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


-(void)textViewDidEndEditing:(UITextView *)textView{
    vehicleDefects = textView.text;
}
#pragma mark TEXTFIELD DELEGATES
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    // odometerReading = textField.text;
    if(textField.tag == 104)
    {
        nameOfPerson = textField.text;
        [[NSUserDefaults standardUserDefaults] setObject:nameOfPerson forKey:@"nameOfPerson"];
        [vehicleChechData setPersonName:nameOfPerson];
        [DataManager sharedManager].isUpdated = YES;
        [vehicleChechData setUpdatedJobId:[DataManager sharedManager].updatedJobId];
    }else if(textField.tag == 105){
        emailOfPerson = textField.text;
        [[NSUserDefaults standardUserDefaults] setObject:emailOfPerson forKey:@"emailOfPerson"];
        [vehicleChechData setPersonEmail:emailOfPerson];
        [vehicleChechData setUpdatedJobId:[DataManager sharedManager].updatedJobId];
        [DataManager sharedManager].isUpdated = YES;
    }
    [self.view endEditing:YES];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"TEXT FIELD TAG IS %ld",textField.tag);
    if (textField.tag >= 103) {
        //[self.tblview setContentOffset:CGPointMake(0, 100) animated:YES];
        UITextField *field = (UITextField *)[_tblview viewWithTag:104];
        nameOfPerson = field.text;
        UITextField *fieldP = (UITextField *)[_tblview viewWithTag:105];
        emailOfPerson = fieldP.text;
    }
    else{
        UITextField *field = (UITextField *)[_tblview viewWithTag:100];
        odometerOfcars =  field.text;
        //        UITextField *fields = (UITextField *)[_tblview viewWithTag:101];
        //        numMats =  fields.text;
        //        UITextField *fieldP = (UITextField *)[_tblview viewWithTag:102];
        //        numKeys = fieldP.text;
    }
    
}

- (BOOL) textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
 replacementString:(NSString *)string {
    if(textField.tag == 101){
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        //first, check if the new string is numeric only. If not, return NO;
        NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        if ([newString rangeOfCharacterFromSet:characterSet].location != NSNotFound)
        {
            return NO;
        }
        return [newString doubleValue] <= 10;
    }
    else if(textField.tag == 102){
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        //first, check if the new string is numeric only. If not, return NO;
        NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        if ([newString rangeOfCharacterFromSet:characterSet].location != NSNotFound)
        {
            return NO;
        }
        return [newString doubleValue] <= 3;
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"hidePickerView"
     object:nil];
}
- (IBAction) flip: (id) sender {
    UISwitch *onoff = (UISwitch *) sender;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCache"];
    [vehicleChechData setIsCache:YES];
    
    if(onoff.tag == 30){
        if (onoff.on == YES) {
            serviceBook = @"1";
        }
        else{
            serviceBook = @"0";
            
        }
        // serviceBook = onoff ? @"1" : @"0";
        
        [[NSUserDefaults standardUserDefaults] setObject:serviceBook forKey:@"serviceBook"];
        [vehicleChechData setService_book:serviceBook];
        [DataManager sharedManager].isUpdated = YES;
        [vehicleChechData setUpdatedJobId:[DataManager sharedManager].updatedJobId];
        
    }
    else if(onoff.tag == 40){
        //loginKit = onoff ? @"1" : @"0";
        if (onoff.on == YES) {
            loginKit = @"1";
        }
        else{
            loginKit = @"0";
            
        }
        [[NSUserDefaults standardUserDefaults] setObject:loginKit forKey:@"loginKit"];
        [vehicleChechData setLocking_kit:loginKit];
        [DataManager sharedManager].isUpdated = YES;
        [vehicleChechData setUpdatedJobId:[DataManager sharedManager].updatedJobId];
    }
    else if(onoff.tag == 50){
        // spareWheel = onoff ? @"1" : @"0";
        if (onoff.on == YES) {
            spareWheel = @"1";
        }
        else{
            spareWheel = @"0";
            
        }
        [[NSUserDefaults standardUserDefaults] setObject:spareWheel forKey:@"spareWheel"];
        [vehicleChechData setSpare_wheel:spareWheel];
        [DataManager sharedManager].isUpdated = YES;
        [vehicleChechData setUpdatedJobId:[DataManager sharedManager].updatedJobId];
    }
}

#pragma mark Email verification
-(BOOL)validateEmail:(NSString *)candidate {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}



-(IBAction)submit:(id)sender{
    NSLog(@"%@%@%@%@%@",nameOfPerson,emailOfPerson,selectedKey,selectedMat,odometerOfcars);
    CTCheckbox *collectedMoneyCheck = (CTCheckbox *)[_tblview viewWithTag:801];
    NSLog(@"is Checked %d",collectedMoneyCheck.checked);
    if(collectedMoneyCheck.checked)
    {
        
        if (!self.isLastCar){
            if([nameOfPerson isEqualToString:@""] || [selectedKey isEqualToString:@""] || [selectedMat isEqualToString:@""] || [odometerOfcars isEqualToString:@""])
            {
                [self showAlertView:@"Error" message:@"Please fill out fields with valid data."];
            }
            else
            {
                NSString *dID = (NSString *)
                [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
                NSString *dApikey = (NSString *)
                [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
                serviceParams = [NSMutableDictionary dictionary];
                [serviceParams setValue:ADD_VEHICLE_DETAILS forKey:@"request"];
                [serviceParams setValue:dID forKey:@"driver_id"];
                [serviceParams setValue:dApikey forKey:@"driver_api_key"];
                [serviceParams setValue:_jobId forKey:@"job_id"];
                [serviceParams setValue:_vehicleId forKey:@"vehicle_id"];
                [serviceParams setValue:_journeyType forKey:@"journey_type"];
                [serviceParams setValue:odometerOfcars forKey:@"vehicle_odometer"];
                [serviceParams setValue:selectedMat forKey:@"number_of_mats"];
                [serviceParams setValue:selectedKey forKey:@"number_of_keys"];
                [serviceParams setValue:serviceBook forKey:@"service_book"];
                [serviceParams setValue:loginKit forKey:@"locking_kit"];
                [serviceParams setValue:spareWheel forKey:@"spare_wheel"];
                [serviceParams setValue:nameOfPerson forKey:@"name"];
                [serviceParams setValue:emailOfPerson forKey:@"email"];
                if(![vehicleDefects isEqualToString:@"Vehicle Defects / Other"] && vehicleDefects){
                    [serviceParams setValue:vehicleDefects forKey:@"vehicle_defects"];
                }
                if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
                    [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
                }
                else{
                    [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
                }
                if([Utils hasCachedImage:self.sigImage]){
                    [self serverCallwithImage];
                }
                else{
                    [self bakeServerData];
                }
            }
        }
        else if (self.isLastCar){
            if([nameOfPerson isEqualToString:@""] || [selectedKey isEqualToString:@""] || [selectedMat isEqualToString:@""] || [odometerOfcars isEqualToString:@""]){
                [self showAlertView:@"Error" message:@"Please fill out fields with valid data."];
            }
            else if([Utils hasCachedImage:self.sigImage]){
                NSString *dID = (NSString *)
                [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
                NSString *dApikey = (NSString *)
                [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
                serviceParams = [NSMutableDictionary dictionary];
                [serviceParams setValue:ADD_VEHICLE_DETAILS forKey:@"request"];
                [serviceParams setValue:dID forKey:@"driver_id"];
                [serviceParams setValue:dApikey forKey:@"driver_api_key"];
                [serviceParams setValue:_jobId forKey:@"job_id"];
                [serviceParams setValue:_vehicleId forKey:@"vehicle_id"];
                [serviceParams setValue:_journeyType forKey:@"journey_type"];
                [serviceParams setValue:odometerOfcars forKey:@"vehicle_odometer"];
                [serviceParams setValue:selectedMat forKey:@"number_of_mats"];
                [serviceParams setValue:selectedKey forKey:@"number_of_keys"];
                [serviceParams setValue:serviceBook forKey:@"service_book"];
                [serviceParams setValue:loginKit forKey:@"locking_kit"];
                [serviceParams setValue:spareWheel forKey:@"spare_wheel"];
                [serviceParams setValue:nameOfPerson forKey:@"name"];
                [serviceParams setValue:emailOfPerson forKey:@"email"];
                if(![vehicleDefects isEqualToString:@"Vehicle Defects / Other"] && vehicleDefects){
                    [serviceParams setValue:vehicleDefects forKey:@"vehicle_defects"];
                }
                if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
                    [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
                }
                else{
                    [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
                }
                
                [self serverCallwithImage];
            }
            else{
                [self bakeServerData];
            }
            
        }
        
    }
    else{
        
        UIAlertController * alert= [UIAlertController
                                    alertControllerWithTitle:nil
                                    message:@"Have you collected the payment?"
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* enrouteToDelivery = [UIAlertAction
                                            actionWithTitle:@"YES"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action)
                                            {
                                                //Handel your yes please button action here
                                                CTCheckbox *collectedMoneyCheck = (CTCheckbox *)[_tblview viewWithTag:801];
                                                collectedMoneyCheck.checked = YES;
                                                [self submit:self];
                                            }];
        UIAlertAction* otherWork = [UIAlertAction
                                    actionWithTitle:@"Dismiss"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //Handel your yes please button action here
                                        
                                    }];
        [alert addAction:enrouteToDelivery];
        [alert addAction:otherWork];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)bakeServerData{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:ADD_VEHICLE_DETAILS forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:_jobId forKey:@"job_id"];
    [serviceParams setValue:_vehicleId forKey:@"vehicle_id"];
    [serviceParams setValue:_journeyType forKey:@"journey_type"];
    [serviceParams setValue:odometerOfcars forKey:@"vehicle_odometer"];
    [serviceParams setValue:selectedMat forKey:@"number_of_mats"];
    [serviceParams setValue:selectedKey forKey:@"number_of_keys"];
    [serviceParams setValue:serviceBook forKey:@"service_book"];
    [serviceParams setValue:loginKit forKey:@"locking_kit"];
    [serviceParams setValue:spareWheel forKey:@"spare_wheel"];
    [serviceParams setValue:nameOfPerson forKey:@"name"];
    [serviceParams setValue:emailOfPerson forKey:@"email"];
    if(![vehicleDefects isEqualToString:@"Vehicle Defects / Other"] && vehicleDefects){
        [serviceParams setValue:vehicleDefects forKey:@"vehicle_defects"];
    }
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }
    [self makeCallForUpdate];
}

-(void)serverCallwithImage{
    [SVProgressHUD showProgress:progressFloat];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSData *profileData;
    profileData = UIImagePNGRepresentation(self.sigImage);
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    [manager POST:BASE_URL_PHOTOS parameters:serviceParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:profileData name:@"signature_image[]" fileName:@"image.png" mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressFloat = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
            [SVProgressHUD showProgress:progressFloat];
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        NSDictionary *tempDict = (NSDictionary *)responseObject;
        int success = [[tempDict objectForKey:@"flag"] intValue];
        if(success == 1){
            
            odometerOfcars = @"";
            selectedMat = @"";
            selectedKey = @"";
            vehicleDefects = @"";
            serviceBook = @"0";
            loginKit = @"0";
            spareWheel = @"0";
            
            NSDictionary *data = [tempDict objectForKey:@"data"];
            CollectionDeliveryVC *viewController = (CollectionDeliveryVC *)[self.navigationController.viewControllers objectAtIndex:1];
            int jobS = [[data objectForKey:@"job_status"] intValue];
            viewController.jObj.jobStatus = jobS;
            
            if (self.isLastCar)
            {
                [self showPopups:jobS];
            }
            else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            [self onSuccess];
        }
        else{
            NSString *message = [tempDict objectForKey:@"message"];
            [self showAlertView:nil message:message];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
    }];
}

-(void)makeCallForUpdate{
    [ApiManager getRequest:serviceParams success:^(id result){
        NSDictionary *tempDict = (NSDictionary *)result;
        int success = [[tempDict objectForKey:@"flag"] intValue];
        if(success == 1)
        {
            odometerOfcars = @"";
            selectedMat = @"";
            selectedKey = @"";
            vehicleDefects = @"";
            serviceBook = @"0";
            loginKit = @"0";
            spareWheel = @"0";
            NSDictionary *data = [tempDict objectForKey:@"data"];
            CollectionDeliveryVC *viewController = (CollectionDeliveryVC *)[self.navigationController.viewControllers objectAtIndex:1];
            int jobS = [[data objectForKey:@"job_status"] intValue];
            viewController.jObj.jobStatus = jobS;
            [self onSuccess];
            if (self.isLastCar)
            {
                [self showPopups:jobS];
            }
            else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }
    }failure:^(NSError *error) {
        
    }];
}

-(void)onSuccess{
    if (_isFromCollection) {
        [vehicleChechData setIsSubmit:YES];
    }
    else{
        
        [vehicleChechData setIsSubmit:YES];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark UPDATE STATUS CALL
-(IBAction)changeJobStatusCall{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:CHANGE_JOB_STATUS forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:_jobId forKey:@"job_id"];
    [serviceParams setValue:@"EN-ROUTE-TO-DELIVERY" forKey:@"job_status"];
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
        if(flag == 1)
        {
            CollectionDeliveryVC *viewController = (CollectionDeliveryVC *)[self.navigationController.viewControllers objectAtIndex:1];
            viewController.jObj.jobStatus = 4;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

-(void)showPopups:(int)jobInt{
    UIAlertController * alert= [UIAlertController
                                alertControllerWithTitle:nil
                                message:@"What you're up to now?"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* enrouteToDelivery = [UIAlertAction
                                        actionWithTitle:@"En-route to Delivery?"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            //Handel your yes please button action here
                                            [self changeJobStatusCall];
                                        }];
    
    UIAlertAction* onBreak = [UIAlertAction
                              actionWithTitle:@"On a break?"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //Handel your yes please button action here
                                  [self.tabBarController setSelectedIndex:4];
                                  UINavigationController *moreVc = [[self.tabBarController viewControllers] objectAtIndex:4];
                                  NSArray *viewControllers = moreVc.viewControllers;
                                  MoreViewController *rootViewController = [viewControllers objectAtIndex:0];
                                  rootViewController.justOnce = YES;
                                  rootViewController.isNormal = @"0";
                                  rootViewController.jobIdForBreakOrPOA = _jobId;
                                  [rootViewController breakOn];
                                  [UVLAppglobals sharedAppGlobals].justGoneForBreak = 1;
                                  [UVLAppglobals sharedAppGlobals].swictchToChange = 2;
                                  [self.navigationController popViewControllerAnimated:NO];
                              }];
    
    UIAlertAction* POA = [UIAlertAction
                          actionWithTitle:@"POA?"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {//Handel your yes please button action here
                              [self.tabBarController setSelectedIndex:4];
                              UINavigationController *moreVc = [[self.tabBarController viewControllers] objectAtIndex:4];
                              NSArray *viewControllers = moreVc.viewControllers;
                              MoreViewController *rootViewController = [viewControllers objectAtIndex:0];
                              rootViewController.justOnce = YES;
                              rootViewController.isNormal = @"0";
                              rootViewController.jobIdForBreakOrPOA = _jobId;
                              [rootViewController poaOn];
                              [UVLAppglobals sharedAppGlobals].justGoneForBreak = 1;
                              [UVLAppglobals sharedAppGlobals].swictchToChange = 1;
                              [self.navigationController popViewControllerAnimated:NO];
                          }];
    
    UIAlertAction* otherWork = [UIAlertAction
                                actionWithTitle:@"Other work?"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {//Handel your yes please button action here
                                    [self.tabBarController setSelectedIndex:4];
                                    UINavigationController *moreVc = [[self.tabBarController viewControllers] objectAtIndex:4];
                                    NSArray *viewControllers = moreVc.viewControllers;
                                    MoreViewController *rootViewController = [viewControllers objectAtIndex:0];
                                    rootViewController.justOnce = YES;
                                    rootViewController.isNormal = @"0";
                                    rootViewController.jobIdForBreakOrPOA = _jobId;
                                    [rootViewController otherWorkOn];
                                    [UVLAppglobals sharedAppGlobals].justGoneForBreak = 1;
                                    [UVLAppglobals sharedAppGlobals].swictchToChange = 3;
                                    [self.navigationController popViewControllerAnimated:NO];
                                }];
    
    UIAlertAction* readyForNext = [UIAlertAction
                                   actionWithTitle:@"Ready for next job?"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {//Handel your yes please button action here
                                       [UVLAppglobals sharedAppGlobals].justGoneForBreak = 0;
                                       [NSNotificationCenter defaultCenter];
                                       
                                       NSNotification* notification = [NSNotification notificationWithName:@"CompleteNotification" object:self];
                                       
                                       [[NSNotificationCenter defaultCenter] postNotification:notification];

                                       [self.navigationController popToRootViewControllerAnimated:NO];
                                   }];
    
    
    
    if (jobInt == 3){       //STATUS 3 REPRESENTS COLLECTION COMPLETION******//STATUS 5,4 REPRESENTS DELIVERY COMPLETION
        [alert addAction:enrouteToDelivery];
    }
    
    
    
    
    
    
    
    [alert addAction:onBreak];
    [alert addAction:POA];
    [alert addAction:otherWork];
    if(jobInt == 5 || jobInt == 4){
        [alert addAction:readyForNext];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"pushToVehiclePhotos"]) {
        VehiclePhotosViewController *tpd  = [segue destinationViewController];
        tpd.alreadyUploaded = _isCallSuccessful;
        tpd.vDetails = details;
        tpd.veId = _vehicleId;
        tpd.isFromCollection = _isFromCollection;
        tpd.vehicleChechData = vehicleChechData;
        tpd.journeyType = self.journeyType;
        tpd.jId = self.jobId;
    }
    else if([[segue identifier] isEqualToString:@"pushTosignaturesView"]){
        SignatureVC *sVC = [segue destinationViewController];
        sVC.delegate = self;
    }
}

#pragma mark Signature VC Delegate
-(void)sendSignatureBack:(UIImage *)signatureImage{
    self.sigImage = signatureImage;
    UIImageView *signatureView  = (UIImageView *)[_tblview viewWithTag:90];
    signatureView.image = signatureImage;
    [self.tblview reloadData];
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


#pragma mark - MKDropdownMenuDataSource

- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu {
    return 1;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component {
    if (dropdownMenu.tag==1) {
        return noOfMats.count;
    }else{
        return noOfKey.count;
        
    }
}

#pragma mark - MKDropdownMenuDelegate

- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu rowHeightForComponent:(NSInteger)component {
    //    if (component == DropdownComponentCity) {
    //        return 20;
    //    }
    return 40; // use default row height
}

- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu widthForComponent:(NSInteger)component {
    return MAX(dropdownMenu.bounds.size.width, 90);
}

- (BOOL)dropdownMenu:(MKDropdownMenu *)dropdownMenu shouldUseFullRowWidthForComponent:(NSInteger)component {
    [self.view endEditing:YES];
    
    
    
    return NO;
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component {
    return [[NSAttributedString alloc] initWithString:@""
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightLight],
                                                        NSForegroundColorAttributeName: self.view.tintColor}];
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForSelectedComponent:(NSInteger)component {
    return [[NSAttributedString alloc] initWithString:@""
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightRegular],
                                                        NSForegroundColorAttributeName: self.view.tintColor}];
}

- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (dropdownMenu.tag==1) {
        return noOfMats[row];
    }else{
        return noOfKey[row];
    }
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component {
    //    if (component == DropdownComponentCity) {
    //        return [self colorForRow:row];
    //    }
    return nil;
}

- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (dropdownMenu.tag==1) {
        // [defaultFeildValues replaceObjectAtIndex:dropdownMenu.tag withObject:noOfMats[row]];
        selectedMat = noOfMats[row];
        [[NSUserDefaults standardUserDefaults] setObject:selectedMat forKey:@"numberOfMats"];
        [vehicleChechData setNumber_of_mats:selectedMat];
        [DataManager sharedManager].isUpdated = YES;
        [vehicleChechData setUpdatedJobId:[DataManager sharedManager].updatedJobId];
        [_tblview reloadData];
    }else if(dropdownMenu.tag==2){
        // [defaultFeildValues replaceObjectAtIndex:dropdownMenu.tag withObject:noOfKey[row]];
        selectedKey = noOfKey[row];
        [[NSUserDefaults standardUserDefaults] setObject:selectedKey forKey:@"numberOfKey"];
        [vehicleChechData setNumber_of_keys:selectedKey];
        [DataManager sharedManager].isUpdated = YES;
        [vehicleChechData setUpdatedJobId:[DataManager sharedManager].updatedJobId];
        [_tblview reloadData];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCache"];
}
@end
