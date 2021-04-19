//
//  VehiclePhotosViewController.m
//  UVL
//
//  Created by Osama on 28/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "VehiclePhotosViewController.h"
#import "VechicleOptionsCell.h"
#import "PhotosViewController.h"
#import "DataManager.h"
#import "VehicleDetails.h"
@interface VehiclePhotosViewController ()
{
    NSArray *photoTypes;
    NSString *typeOfPhotos;
    NSInteger selctedIndex;
    DataManager *sharMngr;
    NSString *titleOfNavbar;
}
@end

@implementation VehiclePhotosViewController
@synthesize alreadyUploaded;
-(void) setupView{
    
    
    NSMutableArray *uploadPhoto = _vehicleChechData.cacheUploadPhot; //[[NSUserDefaults standardUserDefaults] objectForKey:@"uploadPhoto"];
    
    if (uploadPhoto.count>0 ) {
        
        if (_vehicleChechData.isSubmit && _isFromCollection) {
            NSArray *temp  = @[@"0",@"0",@"0",@"0",@"0",@"0",@"0"];
            [DataManager sharedManager].photoIsUploadedArray = temp.mutableCopy;
            
        }
        else if (!_isFromCollection && _vehicleChechData.isSubmit ){
            NSArray *temp  = @[@"0",@"0",@"0",@"0",@"0",@"0",@"0"];
            [DataManager sharedManager].photoIsUploadedArray = temp.mutableCopy;
            
        }
        else if ([DataManager sharedManager].isUpdated && ![_vehicleChechData.updatedJobId isEqualToString:[DataManager sharedManager].updatedJobId]){
            NSArray *temp  = @[@"0",@"0",@"0",@"0",@"0",@"0",@"0"];
            [DataManager sharedManager].photoIsUploadedArray = temp.mutableCopy;
            
        }
        else{
            
            [DataManager sharedManager].photoIsUploadedArray = uploadPhoto.mutableCopy;
        }
        
    }
    else{
        NSArray *temp  = @[@"0",@"0",@"0",@"0",@"0",@"0",@"0"];
        [DataManager sharedManager].photoIsUploadedArray = temp.mutableCopy;
    }
    if (![_vDetails.interior_photos isEqual:nil]&& _vDetails.interior_photos.count>0) {
        
        [[DataManager sharedManager].photoIsUploadedArray replaceObjectAtIndex:0 withObject:@"1"];
    }
    if (![_vDetails.glove_box_photos isEqual:nil]&&_vDetails.glove_box_photos.count>0) {
        
        [[DataManager sharedManager].photoIsUploadedArray replaceObjectAtIndex:1 withObject:@"1"];
        
    }  if (![_vDetails.offside_photos isEqual:nil]&&_vDetails.offside_photos.count>0) {
        
        [[DataManager sharedManager].photoIsUploadedArray replaceObjectAtIndex:2 withObject:@"1"];
        
        
    }  if (![_vDetails.front_photos isEqual:nil]&&_vDetails.front_photos.count>0) {
        
        [[DataManager sharedManager].photoIsUploadedArray replaceObjectAtIndex:3 withObject:@"1"];
        
        
    }  if (![_vDetails.nearside_photos isEqual:nil]&&_vDetails.nearside_photos.count>0) {
        [[DataManager sharedManager].photoIsUploadedArray replaceObjectAtIndex:4 withObject:@"1"];
        
        
    }  if (![_vDetails.rear_photos isEqual:nil]&&_vDetails.rear_photos.count>0) {
        
        [[DataManager sharedManager].photoIsUploadedArray replaceObjectAtIndex:5 withObject:@"1"];
        
    }
    if (![_vDetails.boot_photos isEqual:nil]&&_vDetails.boot_photos.count>0) {
        
        [[DataManager sharedManager].photoIsUploadedArray replaceObjectAtIndex:6 withObject:@"1"];
        
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
    photoTypes  = @[@"Interior",@"Glove Box / Console Content",@"Offside",@"Front",@"Nearside",@"Rear",@"Boot"];
    _photosUrls = [[NSMutableArray alloc] init];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(home:)];
    self.navigationItem.leftBarButtonItem=newBackButton;
   
}
-(void)home:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0 green:122.0/256 blue:255.0/256 alpha:1]];
    
    [self.tblView reloadData];
}
#pragma mark TableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addNewMsg:)
                                                 name:@"makeTick"
                                               object:nil];
}

-(void) addNewMsg:(NSNotification *) notification{
    if ([notification.name isEqualToString:@"makeTick"])
    {
        NSDictionary* userInfo = notification.object;
        _typeDone= userInfo[@"Type"];
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return photoTypes.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(17, 10, 320, 24);
    myLabel.font = [UIFont boldSystemFontOfSize:20];
    myLabel.text =  @"Vehicle Photos";
    myLabel.backgroundColor=[UIColor clearColor];
    myLabel.textColor = [UIColor colorWithRed:0.0/255.0f green:107.0/255.0f blue:255.0/255.0f alpha:1.0f];
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor colorWithRed:232.0/255.0f green:232.0/255.0f blue:232.0/255.0f alpha:1.0f]];
    [headerView addSubview:myLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *prop = @"PhotoTypes";
    VechicleOptionsCell *cell = [tableView dequeueReusableCellWithIdentifier:prop];
    cell.propertyLbl.text = [photoTypes objectAtIndex:indexPath.row];
    if ([[DataManager sharedManager].photoIsUploadedArray[indexPath.row] isEqualToString:@"1"]) {
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryImg.image = [UIImage imageNamed:@"tick"];
    }
    else
        // cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 43;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selctedIndex = indexPath.row;
    titleOfNavbar = [photoTypes objectAtIndex:indexPath.row];
    switch (indexPath.row) {
        case 0:
            _photosUrls = [_vDetails.interior_photos mutableCopy];
            typeOfPhotos = @"INTERIOR";
            break;
        case 1:
            _photosUrls = [_vDetails.glove_box_photos mutableCopy];
            typeOfPhotos = @"GLOVE_BOX";
            break;
        case 2:
            _photosUrls = [_vDetails.offside_photos mutableCopy];
            typeOfPhotos = @"OFFSIDE";
            break;
        case 3:
            _photosUrls = [_vDetails.front_photos mutableCopy];
            typeOfPhotos = @"FRONT";
            break;
        case 4:
            _photosUrls = [_vDetails.nearside_photos mutableCopy];
            typeOfPhotos = @"NEARSIDE";
            break;
        case 5:
            _photosUrls = [_vDetails.rear_photos mutableCopy];
            typeOfPhotos = @"REAR";
            break;
        case 6:
            _photosUrls = [_vDetails.boot_photos mutableCopy];
            typeOfPhotos = @"BOOT";
            break;
        default:
            break;
    }
    [self performSegueWithIdentifier:@"pushToTakePhotos" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PhotosViewController *tpd  = [segue destinationViewController];
    tpd.imagesArray = [_photosUrls mutableCopy];
    tpd.isScussessFul = alreadyUploaded;
//    tpd.isScussessFul = NO;
    tpd.type = typeOfPhotos;
    tpd.vehicleId = _veId;
    tpd.selectedIndex = selctedIndex;
    tpd.vehicleChechData = _vehicleChechData;
    tpd.journeyType = self.journeyType;
    tpd.jobId = self.jId;
    tpd.titleOfNav = titleOfNavbar;
}


@end
