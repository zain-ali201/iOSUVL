//
//  CollectionDeliveryVC.m
//  UVL
//
//  Created by Osama on 27/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "CollectionDeliveryVC.h"
#import "VehicleDo.h"
#import "VehicleOptionViewController.h"
#import "DataManager.h"
#import "VehicleDetails.h"
#import "UIColor+Style.h"
#import "UVLAppglobals.h"
#import "MoreViewController.h"
#import "Constants.h"
#import "ApiManager.h"
#import "CarDetail.h"

@interface CollectionDeliveryVC ()
{
    NSArray *sectionsArray;
    NSString *jType;
    BOOL isFrom;
    NSInteger selecttedIndx;
    NSMutableDictionary *serviceParams;
}
@end

@implementation CollectionDeliveryVC
-(void) setupCaceh{
    for (int i=0; i<_collectionArray.count; i++) {
        VehicleDetails *vehicleDetail = [[VehicleDetails alloc]init];
        [vehicleDetail setJobNumber:i];
        [vehicleDetail setType:@"collection"];
        NSArray *temp  = @[@"0",@"0",@"0",@"0",@"0",@"0",@"0"];
        [vehicleDetail setCacheUploadPhot:temp.mutableCopy];
        [[DataManager sharedManager].cacheCollectionDataArray addObject:vehicleDetail];
    }
    for (int i=0; i<_deliveryArray.count; i++) {
        VehicleDetails *vehicleDetail = [[VehicleDetails alloc]init];
        [vehicleDetail setJobNumber:i];
        [vehicleDetail setType:@"delivery"];
        NSArray *temp  = @[@"0",@"0",@"0",@"0",@"0",@"0",@"0"];
        [vehicleDetail setCacheUploadPhot:temp.mutableCopy];
        [[DataManager sharedManager].cacheDeliveryDataArray addObject:vehicleDetail];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSArray *array = [self.navigationController viewControllers];
    if(array.count == 1){
        NSLog(@"here");
    }
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0 green:122.0/256 blue:255.0/256 alpha:1]];
    [self initviewContent];
     if([UVLAppglobals sharedAppGlobals].justGoneForBreak == 1 && self.jObj.jobStatus != 5  ){
        //show popup and change status
        //[UVLAppglobals sharedAppGlobals].justGoneForBreak = 0;
        [self showPopups];
     }else if([UVLAppglobals sharedAppGlobals].justGoneForBreak == 3){
         [UVLAppglobals sharedAppGlobals].justGoneForBreak = 0;
         [self.navigationController popToRootViewControllerAnimated:NO];
     }
    [_tblview reloadData];
}

#pragma mark UPDATE STATUS CALL

-(void)showPopups{
    UIAlertController * alert= [UIAlertController
                                alertControllerWithTitle:nil
                                message:@"Are you now ready for Delivery Point?"
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* enrouteToDelivery = [UIAlertAction
                                        actionWithTitle:@"YES"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            //Handel your yes please button action here
                                            [UVLAppglobals sharedAppGlobals].justGoneForBreak = 0;
                                            UINavigationController *moreVc = [[self.tabBarController viewControllers] objectAtIndex:4];
                                            NSArray *viewControllers = moreVc.viewControllers;
                                            MoreViewController *rootViewController = [viewControllers objectAtIndex:0];
                                            rootViewController.isNormal = @"0";
                                            rootViewController.jobIdForBreakOrPOA = self.jObj.jobId;
                                            [rootViewController turnTheSwitchesoff];
                                            [self changeJobStatusCall];
                                        }];
    
    UIAlertAction* onBreak = [UIAlertAction
                              actionWithTitle:@"NO"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                 
                              }];
    
    [alert addAction:enrouteToDelivery];
    [alert addAction:onBreak];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)changeJobStatusCall{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:CHANGE_JOB_STATUS forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:self.jObj.jobId forKey:@"job_id"];
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
            self.jObj.jobStatus = 4;
            [self initviewContent];
            [self.tblview reloadData];
        }
    }failure:^(NSError *error) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (![DataManager sharedManager].isUpdated) {
        [self setupCaceh];
    }
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(home:)];
    self.navigationItem.leftBarButtonItem=newBackButton;
    sectionsArray = @[@"Collection",@"Delivery"];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.noteslbl.text = [NSString stringWithFormat:@"%@",self.jObj.specialInstructions];
    [self getLabelHeight:(_noteslbl)];
    //[self initviewContent];
}

- (void)getLabelHeight:(UILabel*)label
{
    CGSize constraint = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    self.heightConstrains.constant = size.height + 12;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.mainScroll setContentSize:CGSizeMake(0, 625)];
}

-(void)home:(UIBarButtonItem *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initviewContent{
    _name.text = _jObj.bookingName;
    _countlbl.text = [NSString stringWithFormat:@"%d",_jObj.position];
    NSLog(@"%@",self.jObj.paymentType);
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
    else{
        self.positionOfView.constant = 57;
    }

}

#pragma mark TableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionsArray objectAtIndex:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor colorWithRed:232.0/255.0f green:232.0/255.0f blue:232.0/255.0f alpha:1.0f]];
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(17, headerView.frame.origin.y/2 + 10, 320, 24);
    myLabel.font = [UIFont boldSystemFontOfSize:20];
    myLabel.text =  [sectionsArray objectAtIndex:section];
    myLabel.backgroundColor=[UIColor clearColor];
    myLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:107.0/255.0f blue:255.0/255.0f alpha:1.0f];
    NSLog(@"jobstatus %d",_jObj.jobStatus);
    if ((self.jObj.jobStatus == 4 && section == 0) || (self.jObj.jobStatus == 5 && section == 0)){
        UIImageView *tickImage = [[UIImageView alloc] init];
        tickImage.frame = CGRectMake(myLabel.frame.origin.x + 100, myLabel.frame.origin.y, 20, 20);
        tickImage.image = [UIImage imageNamed:@"tick"];
        [headerView addSubview:myLabel];
        [headerView addSubview:tickImage];
    }
    else
    [headerView addSubview:myLabel];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return _collectionArray.count + 1;
    else
        return _deliveryArray.count + 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *CarIdentifier = @"CarDetail";
    static NSString *HeaderIdentifier = @"Header";
    if(indexPath.row == 0 && indexPath.section == 0){
        [cell.textLabel setTag:900];
        cell = [tableView dequeueReusableCellWithIdentifier:HeaderIdentifier];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.font = [UIFont systemFontOfSize:9];
        NSString *finalAddress = @"";
       // _jObj.collection_
        NSLog(@"%@",_jObj.collectionCompany);
        NSLog(@"%@",_jObj.collection_address2);
        
        if(_jObj.collectionCompany.length > 0){
            finalAddress = [finalAddress stringByAppendingString:[NSString stringWithFormat:@"%@, ",_jObj.collectionCompany]];
        }
        if(_jObj.collection_name.length > 0){
            finalAddress = [finalAddress stringByAppendingString:[NSString stringWithFormat:@"%@, ",_jObj.collection_name]];
        }
        if(_jObj.collectionAddress.length > 0){
            finalAddress =  [finalAddress stringByAppendingString:[NSString stringWithFormat:@"%@",_jObj.collectionAddress]];
        }
        if(_jObj.collection_address2.length > 0){
            finalAddress =  [finalAddress stringByAppendingString:[NSString stringWithFormat:@" %@",_jObj.collection_address2]];
        }
        if(_jObj.collection_town.length > 0){
            finalAddress = [finalAddress stringByAppendingString:[NSString stringWithFormat:@", %@",_jObj.collection_town]];
        }
        if(_jObj.collection_postcode){
            finalAddress = [finalAddress stringByAppendingString:[NSString stringWithFormat:@", %@",_jObj.collection_postcode]];
        }
        if(_jObj.collection_telephone.length > 0){
            finalAddress = [finalAddress stringByAppendingString:[NSString stringWithFormat:@", %@",_jObj.collection_telephone]];
        }

        NSLog(@"%@",finalAddress);
        cell.textLabel.text =  finalAddress;
        cell.textLabel.font = [UIFont systemFontOfSize:11];
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnCollection:)];
        // if labelView is not set userInteractionEnabled, you must do so
        [cell.textLabel setUserInteractionEnabled:YES];
        [cell.textLabel addGestureRecognizer:gesture];
    }
    else if(indexPath.row == 0 && indexPath.section == 1){
        [cell.textLabel setTag:901];
        
        cell = [tableView dequeueReusableCellWithIdentifier:HeaderIdentifier];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:9];
        NSString *finalAddress = @"";
        
        NSLog(@"%@",_jObj.delivery_company);
        NSLog(@"%@",_jObj.delivery_address2);
        
        if(_jObj.delivery_company.length > 0){
            finalAddress = [finalAddress stringByAppendingString:[NSString stringWithFormat:@"%@, ",_jObj.delivery_company]];
        }
        if(_jObj.delivery_name.length > 0){
            finalAddress = [finalAddress stringByAppendingString:[NSString stringWithFormat:@"%@, ",_jObj.delivery_name]];
        }
        if(_jObj.delivery_address.length > 0){
            finalAddress =  [finalAddress stringByAppendingString:[NSString stringWithFormat:@"%@",_jObj.delivery_address]];
        }
        if(_jObj.delivery_address2.length > 0){
            finalAddress =  [finalAddress stringByAppendingString:[NSString stringWithFormat:@" %@",_jObj.delivery_address2]];
        }
        if(_jObj.delivery_town.length > 0){
            finalAddress = [finalAddress stringByAppendingString:[NSString stringWithFormat:@", %@",_jObj.delivery_town]];
        }
//        if(_jObj.delivery_country.length > 0){
//            finalAddress = [finalAddress stringByAppendingString:[NSString stringWithFormat:@", %@",_jObj.delivery_country]];
//        }
        if(_jObj.delivery_postcode){
            finalAddress = [finalAddress stringByAppendingString:[NSString stringWithFormat:@", %@",_jObj.delivery_postcode]];
        }
        if(_jObj.delivery_telephone.length > 0){
            finalAddress = [finalAddress stringByAppendingString:[NSString stringWithFormat:@", %@",_jObj.delivery_telephone]];
        }
//        if(_jObj.delivery_email.length > 0){
//            finalAddress = [finalAddress stringByAppendingString:[NSString stringWithFormat:@", %@",_jObj.delivery_email]];
//        }
        
        cell.textLabel.text =  finalAddress;
        cell.textLabel.font = [UIFont systemFontOfSize:11];
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnDelivery:)];
        gesture.numberOfTapsRequired = 1;
    
        // if labelView is not set userInteractionEnabled, you must do so
        [cell.textLabel setUserInteractionEnabled:YES];
        [cell.textLabel addGestureRecognizer:gesture];

    }
    
    else if(indexPath.section == 0){
//        CarDetail *cell = [tableView dequeueReusableCellWithIdentifier:CarIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:CarIdentifier];
        VehicleDo *vobj = (VehicleDo*)[_collectionArray objectAtIndex:indexPath.row - 1];
        NSString *oneLbl;
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        if(vobj.vrnNo.length > 0){
    
            oneLbl = [NSString stringWithFormat:@"%@, %@, %@",vobj.vehicleMake,vobj.vehicleModel,vobj.vrnNo];
        }else{
            oneLbl = [NSString stringWithFormat:@"%@, %@",vobj.vehicleMake,vobj.vehicleModel];
        }
        NSLog(@"%@",oneLbl);
        cell.textLabel.text = oneLbl;
//        cell.textLabel.text = @"applying any localization. This is useful, for example, when working with fixed-format representations .";
        cell.textLabel.numberOfLines = 2;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:CarIdentifier];
        VehicleDo *vobj = (VehicleDo*)[_collectionArray objectAtIndex:indexPath.row - 1];
        NSString *oneLbl;
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        if(vobj.vrnNo.length > 0){
            oneLbl = [NSString stringWithFormat:@"%@, %@, %@",vobj.vehicleMake,vobj.vehicleModel,vobj.vrnNo];
        }else{
            oneLbl = [NSString stringWithFormat:@"%@, %@",vobj.vehicleMake,vobj.vehicleModel];
        }
        cell.textLabel.text = oneLbl;
        cell.textLabel.numberOfLines = 2;
//        cell.textLabel.frame = CGRectMake(0, 0, 300, 43);
    }
    if(indexPath.row == _collectionArray.count){
//        UIView *lineView = [cell.contentView viewWithTag:10];
//        lineView.hidden = YES;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selecttedIndx = indexPath.row;
    if(indexPath.row != 0){
        VehicleDo *vobj = (VehicleDo*)[_collectionArray objectAtIndex:indexPath.row - 1];
        if(indexPath.section == 0){
            jType = @"COLLECTION";
            isFrom = YES;
            [self performSegueWithIdentifier:@"VehicleOptions" sender:vobj];
        }
        else{
            jType = @"DELIVERY";
            isFrom = NO;
//            VehicleDetails *vehicleChechData = [[DataManager sharedManager].cacheCollectionDataArray objectAtIndex:indexPath.row - 1];
            if (self.jObj.jobStatus == 4 || self.jObj.jobStatus == 5){
                [self performSegueWithIdentifier:@"VehicleOptions" sender:vobj];
            }
        }
    }
}

#pragma mark - GestureRecognizer Call delegates
- (void)userTappedOnCollection:(UIGestureRecognizer*)gestureRecognizer{
    
    NSString *phNo = _jObj.collection_telephone;
    NSLog(@"%@",phNo);
    if(phNo.length > 0){
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
        NSLog(@"%@",phoneUrl);
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
            [self.callObserver setDelegate:self queue:nil];
            
        } else
        {
            UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [calert show];
        }
    }
}

- (void)userTappedOnDelivery:(UIGestureRecognizer*)gestureRecognizer{
    
    NSString *phNo = _jObj.delivery_telephone;
    NSLog(@"%@",phNo);
    if(phNo.length > 0){
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
        NSLog(@"%@",phoneUrl);
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
            [self.callObserver setDelegate:self queue:nil];
            
        } else
        {
            UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [calert show];
        }
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"VehicleOptions"]) {
        VehicleOptionViewController *tpd  = [segue destinationViewController];
        VehicleDo *vobj = (VehicleDo*)sender;
        NSLog(@"%@",self.jObj.paymentType);
        if([self.jObj.paymentType isEqualToString:@"COC"]) {
            tpd.isCOCOrCOD = 1;
        }
        else if ([self.jObj.paymentType isEqualToString:@"COD"]) {
            tpd.isCOCOrCOD = 2;
        }
        else if ([self.jObj.paymentType isEqualToString:@"CARDOC"]) {
            tpd.isCOCOrCOD = 3;
        }
        else if ([self.jObj.paymentType isEqualToString:@"CARDOD"]) {
            tpd.isCOCOrCOD = 4;
        }
        else{
            tpd.isCOCOrCOD = 0;
        }
        tpd.jobId = _jObj.jobId;
        if(selecttedIndx == self.collectionArray.count){
            tpd.isLastCar = YES;
        }else{
            tpd.isLastCar = NO;
        }
        tpd.selectedIndex = selecttedIndx-1;
        tpd.isFromCollection = isFrom;
        tpd.vehicleId = vobj.vehicleId;
        tpd.journeyType = jType;
        tpd.jPrice = self.jObj.jobPrice;
        
    }
}

@end
