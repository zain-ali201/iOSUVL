//
//  DefectViewController.m
//  UVL
//
//  Created by cellzone on 1/27/21.
//  Copyright © 2021 TxLabz. All rights reserved.
//

#import "DefectViewController.h"
#import "DefectDataTableCell.h"
#import "TyreTableCell.h"
#import "ApiManager.h"
#import "DriverDO.h"
#import "AppDelegate.h"
#import "DailyDefectCheck.h"
#import "SVProgressHUD.h"
#import "PhotosViewController.h"
//#import "UIImageView+AFNetworking.h"
#import "Constants.h"
#import "UVLAppglobals.h"
#import "AFNetworking.h"
#import "ApiManager.h"
#import "DataManager.h"
#import "EXPhotoViewer.h"

@import Photos;
@interface DefectViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,QBImagePickerControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

{
    IBOutlet UIView *imagesView;
    
    int totalAssets;
    
    int imagesLimit;
    
    NSMutableArray* totalImages;
    NSMutableArray* slideImages;
    NSArray *images;
   // JOLImageSlider *imageSlider;
    
    NSInteger currentImageIndex;
    NSInteger imageIndex;
    
    float progressFloat;
    
    BOOL notesFlag;
    NSString *msg;
}

@property (strong, nonatomic)NSMutableArray<DailyDefectCheck*>*DefectDataArray;
@property(nonatomic, strong) NSData* shopImageData;
@end

@implementation DefectViewController
NSMutableDictionary *serviceParams;
float progressFloat;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    
    notesFlag = TRUE;
    totalImages = [[NSMutableArray alloc]init];
    
    self.defectChecksArray = [[NSMutableArray alloc] init];
    self.DefectDataArray = [[NSMutableArray alloc] init];
    self.tyreArray1 = @[@"NS", @"OSF"];
    self.tyreArray2 = @[@"NS", @"OS"];
    self.tyreArray3 = @[@"NS Outer", @"NS Inner", @"OS Outer", @"OS Inner"];
    // Connect data
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.hidden = true;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated{
    [self getDailyDefect];
}
- (void)loadData{
    self.tyreView.hidden = true;
    self.tyreViewHeight.constant = 0;
    
    
    self.lbl =  [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0,_txtView.frame.size.width - 10.0, 34.0)];
    
    [self.lbl setText:@"I.e. Defect Notes"];
    [self.lbl setBackgroundColor:[UIColor clearColor]];
    [self.lbl setTextColor:[UIColor lightGrayColor]];
    _txtView.delegate = self;
    
    [_txtView addSubview:self.lbl];
    
    self.txtView.layer.borderWidth = 0.5;
    self.defectView.layer.borderWidth = 0.5;
    self.txtView.layer.borderColor = [UIColor grayColor].CGColor;
    self.defectView.layer.borderColor = [UIColor grayColor].CGColor;
}

- (void)loadImages
{
    for(UIView *view in imagesView.subviews)
    {
        [view removeFromSuperview];
    }
    
    double xAxis = 0.0;
    
    for (UIImage *img in totalImages)
    {
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(xAxis, 0, 50,50)];
        imgView.image = img;
        NSLog(@"image");
        [imagesView addSubview:imgView];
        xAxis += 60.0;
    }
}


- (IBAction)ActionBtnSubmit:(id)sender {
    [self CreatDefectReport];
}
           ///-================ Multiples  Images Upload-============================//////
-(void)pickImageFromGallery:(UIButton*)sender
{
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 5 - totalImages.count;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    imagePickerController.mediaType = QBImagePickerMediaTypeAny;

    [self presentViewController:imagePickerController animated:YES completion:NULL];

}
-(void)pickImageFromCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
//        [self showErrorAlertWithTitle:@"Info!" andMessage:@"This device have no camera"];
    }
    else
    {
        UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
}


#pragma mark Multi image delegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"assets: %d",assets.count);
    for (PHAsset *asset in assets)
    {
        
        UIImage* img = [self getAssetThumbnail:asset];
        if (img != nil)
        {
            NSLog(@"--------");
            [totalImages addObject:img];
        }
        
    }
    
    [self loadImages];

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIImage*)getAssetThumbnail:(PHAsset*)asset
{
    PHImageManager* manager = [PHImageManager defaultManager];
    PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
    options.synchronous  = YES;

    __block UIImage* image = [[UIImage alloc] init];

    [manager requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        image = result;
    }];

    return image;
}

- (IBAction)ActionBtnCamera:(id)sender {
    

//    UIAlertController *alertController = [UIAlertController
//                                              alertControllerWithTitle:@""
//                                              message:@"Choose Picker"
//                                              preferredStyle:UIAlertControllerStyleActionSheet];
//        UIAlertAction *Fuel = [UIAlertAction
//                               actionWithTitle:@"Camera"
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction *action)
//                               {
//                                   if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//                                   {
//                                       UIImagePickerController* picker = [[UIImagePickerController alloc] init];
//                                       picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//                                       picker.allowsEditing = NO;
//                                       picker.delegate = self;
//                                       [self presentViewController:picker animated:YES completion:NULL];
//                                   }
//                                   else
//                                   {
    //                                   UIAlertView *altnot=[[UIAlertView alloc]initWithTitle:@"Camera Not Available" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //                                   [altnot show];
//
//                                   }
//                               }];
//
//        UIAlertAction *Toll = [UIAlertAction
//                               actionWithTitle:@"Gallery"
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction *action)
//                               {
//                                   UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//
//                                   picker.delegate = self;
//                                   picker.editing = YES;
//                                   picker.allowsEditing = YES;
//                                   picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//                                   [self presentViewController:picker animated:YES completion:NULL];
//                               }];
//
//        UIAlertAction *cancel = [UIAlertAction
//                                 actionWithTitle:@"Cancel"
//                                 style:UIAlertActionStyleCancel
//                                 handler:^(UIAlertAction *action)
//                                 {
//
//                                 }];
//        [alertController addAction:Fuel];
//        [alertController addAction:Toll];
//        [alertController addAction:cancel];
//        [self presentViewController:alertController animated:YES completion:nil];
//
    
  
    UIButton* b = (UIButton*)sender;

    UIAlertController* alert = [UIAlertController
                               alertControllerWithTitle:nil
                               message:@"Choose Picker"
                               preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction* button1 = [UIAlertAction
                             actionWithTitle:@"Gallery"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 if (totalImages.count < 5)
                                 {
                                     [self pickImageFromGallery:b];
                                 }
                                 else
                                 {
                                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"You cannot upload more than five images." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                     [alert show];
                                 }
                             }];

    UIAlertAction* button2 = [UIAlertAction
                             actionWithTitle:@"Camera"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                if (totalImages.count < 5)
                                {
                                    [self pickImageFromCamera];
                                }
                                else
                                {
                                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"You cannot upload more than five images." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    [alert show];
                                }
                                 
                             }];
    UIAlertAction* button3 = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                             }];

    [alert addAction:button2];
    [alert addAction:button1];
    [alert addAction:button3];

    [self presentViewController:alert animated:YES completion:nil];
}




//--------------------------- TABLE VIEW --------------------------//

#pragma mark UITableviewdelegate/datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tblView)
    {
        return 1;
    }
    else
    {
        return 3;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tblView)
    {
        return @"";
    }
    else
    {
        if (section == 0)
        {
            return @"Axle 1";
        }
        else if (section == 1)
        {
            return @"Axle 2";
        }
        else
        {
            return @"Axle 3";
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tblView)
    {
        return 0;
    }
    else
    {
        return 30;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor redColor]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 42;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tblView)
    {
        return self.DefectDataArray.count;
    }
    else
    {
        if (section == 0)
        {
            return _tyreArray1.count;
        }
        else if (section == 1)
        {
            return _tyreArray2.count;
        }
        else
        {
            return _tyreArray3.count;
        }
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblView)
    {
        DefectDataTableCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"DefectDataTableCell"];
        
        DailyDefectCheck *DefectData = [self.DefectDataArray objectAtIndex:indexPath.row];
        cell.defectDataLbl.text = DefectData.defectName;
        cell.switcher.tag = indexPath.row;
        if ([DefectData.defectValue isEqual: @"1"])
        {
            [cell.switcher setOn:TRUE];
            [self.defectChecksArray addObject:DefectData.defectKey];
        }
        [cell.switcher addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else
    {
        TyreTableCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"TyreTableCell"];
        
        if (indexPath.section == 0)
        {
            cell.tyreLbl.text = self.tyreArray1[indexPath.row];
            if (indexPath.row == 0 && ![self.Tyre1 isEqual:@""])
            {
                cell.tyreLbl.text = self.Tyre1;
            }
            else if (indexPath.row == 1 && ![self.Tyre2 isEqual:@""])
            {
                cell.tyreLbl.text = self.Tyre2;
            }
        }
        else if (indexPath.section == 1)
        {
            cell.tyreLbl.text = self.tyreArray2[indexPath.row];
            
            if (indexPath.row == 0 && ![self.Tyre3 isEqual:@""])
            {
                cell.tyreLbl.text = self.Tyre3;
            }
            else if (indexPath.row == 1 && ![self.Tyre4 isEqual:@""])
            {
                cell.tyreLbl.text = self.Tyre4;
            }
        }
        else
        {
            cell.tyreLbl.text = self.tyreArray3[indexPath.row];
            
            if (indexPath.row == 0 && ![self.Tyre5 isEqual:@""])
            {
                cell.tyreLbl.text = self.Tyre5;
            }
            else if (indexPath.row == 1 && ![self.Tyre6 isEqual:@""])
            {
                cell.tyreLbl.text = self.Tyre6;
            }
            else if (indexPath.row == 2 && ![self.Tyre7 isEqual:@""])
            {
                cell.tyreLbl.text = self.Tyre7;
            }
            else if (indexPath.row == 3 && ![self.Tyre8 isEqual:@""])
            {
                cell.tyreLbl.text = self.Tyre8;
            }
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tblView){}else
    {
        self.indexPathRow = indexPath;
        self.pickerView.hidden = false;
    }
}

- (void)didTapButton:(UISwitch*)sender {
    
    if(sender.isOn)
    {
        NSString *check = self.DefectDataArray[sender.tag].defectKey;
        [self.defectChecksArray addObject:check];
        
        if ([self.DefectDataArray[sender.tag].defectKey isEqual: @"types-wheel-nutes"])
        {
            self.tyreView.hidden = false;
            self.tyreViewHeight.constant = 280;
            self.isTyreSelect = YES;
        }
    }
    else
    {
        NSString *check = self.DefectDataArray[sender.tag].defectKey;
        [self.defectChecksArray removeObject:check];
        if ([self.DefectDataArray[sender.tag].defectKey isEqual: @"types-wheel-nutes"]){
            self.isTyreSelect = NO;
            self.tyreView.hidden = true;
            self.tyreViewHeight.constant = 0;
        }
    }
}

//--------------------------- TEXTFEILD DELEGATE --------------------------//

- (void)textViewDidEndEditing:(UITextView *) textView
{
    if (![textView hasText]) {
        self.lbl.hidden = NO;
    }
}

- (void) textViewDidChange:(UITextView *)textView
{
    if(![textView hasText]) {
        self.lbl.hidden = NO;
    }
    else{
        self.lbl.hidden = YES;
    }
}

//--------------------------- PICKER VIEW --------------------------//

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.tyresData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //     TyreTableCell *cell =  [self.tyreTblView dequeueReusableCellWithIdentifier:@"TyreTableCell"];
    // cell.tyreLbl.text = self.tyreItemArray[row];
    return self.tyresData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    TyreTableCell *cell = [self.tyreTblView cellForRowAtIndexPath:self.indexPathRow];
    cell.tyreLbl.text = @"";
    cell.tyreLbl.text = self.tyresData[indexPath.row];
    
    if (self.indexPathRow.row == 0)
    {
        self.Tyre1 = self.tyresData[row];
    }
    else if (self.indexPathRow.row == 1)
    {
        self.Tyre2 = self.tyresData[row];
    }
    else if (self.indexPathRow.row == 2)
    {
        self.Tyre3 = self.tyresData[row];
    }
    else if (self.indexPathRow.row == 3)
    {
        self.Tyre4 = self.tyresData[row];
    }
    else if (self.indexPathRow.row == 4)
    {
        self.Tyre5 = self.tyresData[row];
    }
    else if (self.indexPathRow.row == 5)
    {
        self.Tyre6 = self.tyresData[row];
    }
    else if (self.indexPathRow.row == 6)
    {
        self.Tyre7 = self.tyresData[row];
    }
    else if (self.indexPathRow.row == 7)
    {
        self.Tyre8 = self.tyresData[row];
    }
    
    NSLog(@"%@", self.tyresData[indexPath.row]);
    self.pickerView.hidden = true;
}

-(BOOL)validate
{
    BOOL valid = true;
    NSString *message = @"";
    
    if (self.defectChecksArray.count <= 0)
    {
        valid = NO;
        message = @"Please select Defects";
    }
    else if (self.isTyreSelect)
    {
        if (self.Tyre1 != nil && self.Tyre2 != nil && self.Tyre3 != nil  && self.Tyre4 != nil  && self.Tyre5!= nil && self.Tyre6!= nil && self.Tyre7!= nil && self.Tyre8!= nil)
        {
            
        }
        else
        {
            valid = NO;
            message = @"Please enter tyres value";
        }
    }
    else if (self.txtView.text.length <= 0 && notesFlag == TRUE)
    {
        valid = NO;
        message = @"Please enter Defect Notes";
    }
    else if (totalImages.count == 0)
    {
        valid = NO;
        message = @"Please attach atleast one image";
    }
    
    
    if (!valid) {
        [self showAlertView:nil message:message];
    }
    
    return valid;
}


//--------------------------- WEB SERVICES --------------------------//
-(void)getDailyDefect
{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    
    serviceParams = [NSMutableDictionary dictionary];
    
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    
    NSString *defectID = [[NSUserDefaults standardUserDefaults]objectForKey:@"defect_id"];
    if (defectID != nil && ![defectID isEqualToString:@""])
    {
        [serviceParams setValue:defectID forKey:@"defect_id"];
        [serviceParams setValue:GET_EXISTED_DEFECT forKey:@"request"];
    }
    else
    {
        [serviceParams setValue:GET_DAILY_DEFECT forKey:@"request"];
    }
    NSLog(@"%@", serviceParams);
    [self makeServerCall];
}

-(void)makeServerCall
{
    [ApiManager postRequest:serviceParams success:^(id result){
        if([result objectForKey:@"error"] == nil){
            if (self.isApiCreat){}
            else
            {
                NSArray *DefectDetails = [result objectForKey:@"check_options"];
                self.tyresData = (NSDictionary *)[result objectForKey:@"tyre_options"];
                if([DefectDetails count] > 0){
                    [self.DefectDataArray removeAllObjects];
                    for (NSDictionary *dic  in DefectDetails) {
                        
                        DailyDefectCheck *defectdata = [[DailyDefectCheck alloc] initWithDailyDefect:dic];
                        if (![self.DefectDataArray containsObject:defectdata]) {
                            [self.DefectDataArray addObject:defectdata];
                        }
                        
                    }
                }
                
                NSString *notes = [result objectForKey:@"defect_notes"];
                
                if (notes != nil && ![notes isEqual:@""])
                {
                    _txtView.text = notes;
                    notesFlag = TRUE;
                    self.lbl.hidden = YES;
                }
                
                self.Tyre1 = [result objectForKey:@"tyre1"];
                self.Tyre2 = [result objectForKey:@"tyre2"];
                self.Tyre3 = [result objectForKey:@"tyre3"];
                self.Tyre4 = [result objectForKey:@"tyre4"];
                self.Tyre5 = [result objectForKey:@"tyre5"];
                self.Tyre6 = [result objectForKey:@"tyre6"];
                self.Tyre7 = [result objectForKey:@"tyre7"];
                self.Tyre8 = [result objectForKey:@"tyre8"];
                
                self.tblViewHeight.constant = self.DefectDataArray.count * 42;
                [self.tblView reloadData];
            }
        }
        else{
        }
    }failure:^(NSError *error) {
        
    }];
}
      //---------------- CREAT DEFECT REPORT API ----------------//


-(void)CreatDefectReport{
    
    if ([self validate])
    {
        [serviceParams removeAllObjects];
        serviceParams = [NSMutableDictionary dictionary];
        NSString *dID = (NSString *)
        [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
        NSString *dApikey = (NSString *)
        [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
        
        NSMutableDictionary *checksDict = [[NSMutableDictionary alloc]init];
        
        for (NSString *str in self.defectChecksArray)
        {
            [checksDict setObject:str forKey:str];
        }
        
        NSString *defectID = [[NSUserDefaults standardUserDefaults]objectForKey:@"defect_id"];
        
        if (defectID != nil && ![defectID isEqualToString:@""])
        {
            [serviceParams setValue:defectID forKey:@"defect_id"];
            [serviceParams setValue:UPDATE_DEFECT forKey:@"request"];
            msg = @"Defect updated successfully.";
        }
        else
        {
            [serviceParams setValue:@"add" forKey:@"defect_id"];
            [serviceParams setValue:CREATE_DEFECT forKey:@"request"];
            msg = @"Defect added successfully.";
        }
        
        [serviceParams setValue:dID forKey:@"driver_id"];
        [serviceParams setValue:dApikey forKey:@"driver_api_key"];
        [serviceParams setValue:checksDict forKey:@"daily_checks"];
        [serviceParams setValue:self.txtView.text forKey:@"defect_notes"];
        NSString *shiftId = [[NSUserDefaults standardUserDefaults] objectForKey:@"shift_id"];
        if (shiftId != nil && ![shiftId isEqualToString:@""])
        {
            [serviceParams setValue:shiftId forKey:@"shift_id"];
        }
        else
        {
            [serviceParams setValue:@"" forKey:@"shift_id"];
        }
        
        NSString *vehicleID = [[NSUserDefaults standardUserDefaults] objectForKey:@"vehicle_id"];
        if (vehicleID != nil && ![vehicleID isEqualToString:@""])
        {
            [serviceParams setValue:vehicleID forKey:@"vehicle_id"];
        }
        else
        {
            [serviceParams setValue:@"" forKey:@"vehicle_id"];
        }
        
        [serviceParams setValue:self.Tyre1 forKey:@"tyre1"];
        [serviceParams setValue:self.Tyre2 forKey:@"tyre2"];
        [serviceParams setValue:self.Tyre3 forKey:@"tyre3"];
        [serviceParams setValue:self.Tyre4 forKey:@"tyre4"];
        [serviceParams setValue:self.Tyre5 forKey:@"tyre5"];
        [serviceParams setValue:self.Tyre6 forKey:@"tyre6"];
        [serviceParams setValue:self.Tyre7 forKey:@"tyre7"];
        [serviceParams setValue:self.Tyre8 forKey:@"tyre8"];
        NSLog(@"%@",serviceParams);
        //[self makeServerCall];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self makeServerCallForCreatReport];
        });
    }
}
-(void)makeServerCallForCreatReport
{
      self.navigationController.navigationBar.userInteractionEnabled = NO;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [SVProgressHUD showProgress:progressFloat];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    [manager POST:BASE_URL_PHOTOS parameters:serviceParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (UIImage *img in totalImages)
        {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(img, 0.3) name:@"defect_images[]" fileName:@"image.png" mimeType:@"image/jpeg"];
        }
        
        NSLog(@"formData: %@", formData);
        
//        [formData appendPartWithFileData:profileData name:@"defect_images[]" fileName:@"image.png" mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressFloat = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
            [SVProgressHUD showProgress:progressFloat];
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        NSDictionary *tempDict = (NSDictionary *)responseObject;
        NSLog(@"Response: %@", tempDict);
        NSLog(@"defectID: %@", [tempDict valueForKey:@"defect_ticket_number"]);
        
        UIAlertController * alert= [UIAlertController
                                    alertControllerWithTitle:@""
                                    message:msg
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleCancel
                                    handler:^(UIAlertAction * action)
                                    {
            
            NSString *defectID = [[NSUserDefaults standardUserDefaults]objectForKey:@"defect_id"];
            if (defectID != nil && ![defectID isEqualToString:@""])
            {
                [self.navigationController popViewControllerAnimated:TRUE];
            }
            else
            {
                NSString *defectID = [NSString stringWithFormat:@"%@",[tempDict valueForKey:@"defect_ticket_number"]];
                [[NSUserDefaults standardUserDefaults] setValue:defectID forKey:@"defect_id"];
                [self.tabBarController setSelectedIndex:0];
            }
        }];
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          self.navigationController.navigationBar.userInteractionEnabled = YES;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:TRUE];
    [_txtView resignFirstResponder];
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


#pragma mark - Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    self.chosenImage = info[UIImagePickerControllerOriginalImage];
    [totalImages addObject:info[UIImagePickerControllerOriginalImage]];
    [self loadImages];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - ImageConversion

- (UIImage *) imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
