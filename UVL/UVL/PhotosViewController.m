//
//  PhotosViewController.m
//  UVL
//
//  Created by Osama on 07/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "PhotosViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"
#import "UVLAppglobals.h"
#import "AFNetworking.h"
#import "ApiManager.h"
#import "DataManager.h"
#import "EXPhotoViewer.h"


@interface PhotosViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    NSMutableDictionary *serviceParams;
    float progressFloat;
}
@end

@implementation PhotosViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0 green:122.0/256 blue:255.0/256 alpha:1]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _deleteCount = 0;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.title = self.titleOfNav;
    
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap setNumberOfTapsRequired:1];
    UILongPressGestureRecognizer *longTap1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnImage:)];
    longTap1.minimumPressDuration = .5;
    [self.image1 addGestureRecognizer:longTap1];
    [self.image1 addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *singleTap2 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap2 setNumberOfTapsRequired:1];
    UILongPressGestureRecognizer *longTap2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnImage:)];
    longTap1.minimumPressDuration = .5;
    [self.image2 addGestureRecognizer:longTap2];
    [self.image2 addGestureRecognizer:singleTap2];
    
    UITapGestureRecognizer *singleTap3 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap3 setNumberOfTapsRequired:1];
    UILongPressGestureRecognizer *longTap3 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnImage:)];
    longTap1.minimumPressDuration = .5;
    [self.image3 addGestureRecognizer:longTap3];
    [self.image3 addGestureRecognizer:singleTap3];
    
    UITapGestureRecognizer *singleTap4 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap4 setNumberOfTapsRequired:1];
    UILongPressGestureRecognizer *longTap4 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnImage:)];
    longTap1.minimumPressDuration = .5;
    [self.image4 addGestureRecognizer:longTap4];
    [self.image4 addGestureRecognizer:singleTap4];
    
    UITapGestureRecognizer *singleTap5 =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap5 setNumberOfTapsRequired:1];
    UILongPressGestureRecognizer *longTap5 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnImage:)];
    longTap1.minimumPressDuration = .5;
    [self.image5 addGestureRecognizer:longTap5];
    [self.image5 addGestureRecognizer:singleTap5];
    // Do any additional setup after loading the view.
    if(_isScussessFul){
        [self hideViews];
        [self loadPicturesFromUrl];
        
        _camerabtn.enabled= false;
    }
    else{
        [self fetchPhotosFromserver];
    }
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(home:)];
    self.navigationItem.leftBarButtonItem=newBackButton;
}

-(void)loadPicturesFromUrl{
    for(int i = 0; i < _imagesArray.count; i++){
        UIImageView *imgView = (UIImageView*)[self.view viewWithTag:i+1];
        {
            NSDictionary *singleObject1 = [_imagesArray objectAtIndex:i];
            NSString *photoUrl = [singleObject1 objectForKey:@"photo"];
            NSLog(@"%@",[singleObject1 objectForKey:@"photo"]);
            imgView.imageURL =  [NSURL URLWithString:photoUrl];
        }
    }
}

-(void)home:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)singleTapping:(UIGestureRecognizer *)recognizer {
    UIImageView *view = (UIImageView *)recognizer.view;
    NSLog(@"%ld", (long)view.tag);
    if(view.tag == 1){
        [EXPhotoViewer showImageFrom:self.image1];
    }
    else if(view.tag == 2){
        [EXPhotoViewer showImageFrom:self.image2];
    }
    else if(view.tag == 3){
        [EXPhotoViewer showImageFrom:self.image3];
    }
    else if(view.tag == 4){
        [EXPhotoViewer showImageFrom:self.image4];
    }
    else if(view.tag == 5){
        [EXPhotoViewer showImageFrom:self.image5];
    }
}

-(void)longPressOnImage:(UILongPressGestureRecognizer *)recognizer {
    UIImageView *view = (UIImageView *)recognizer.view;
    NSLog(@"%ld", (long)view.tag);
    [self showDeleteChoice:view.tag-1];
}

-(void)getPhotosCall{
    [ApiManager getRequest:serviceParams success:^(id result){
        int success = [[result objectForKey:@"flag"] intValue];
        if(success){
            NSArray *jobData  = (NSArray *)[result objectForKey:@"photos"];
            if(jobData != nil){
                self.imagesArray = [[NSMutableArray alloc] init];
                self.imagesIDArray = [[NSMutableArray alloc] init];
                for(int i = 0; i < jobData.count; i++){
                    NSDictionary *dict = [jobData objectAtIndex:i];
                    NSLog(@"%@",dict);
                    NSString *photoUrl = [dict objectForKey:@"photo"];
                    NSString *photoID = [dict objectForKey:@"photo_id"];
                    [self.imagesArray addObject:photoUrl];
                    [self.imagesIDArray addObject:photoID];
                }
                if(self.imagesArray.count >= 5)
                    _camerabtn.enabled= false;
                [self loadPictures];
                if (self.imagesArray.count>0) {
                    [[DataManager sharedManager].photoIsUploadedArray replaceObjectAtIndex:_selectedIndex withObject:@"1"];
                    //  [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].photoIsUploadedArray forKey:@"uploadPhoto"];
                }
                //  [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
        }
    }failure:^(NSError *error) {
        
    }];
    
}

-(void)fetchPhotosFromserver{
    serviceParams = [[NSMutableDictionary alloc] init];
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    [serviceParams setValue:GET_PHOTO forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:_jobId forKey:@"job_id"];
    [serviceParams setValue:self.vehicleId forKey:@"vehicle_id"];
    [serviceParams setValue:self.journeyType forKey:@"journey_type"];
    [serviceParams setValue:self.type forKey:@"option_image_name"];
    
    [self getPhotosCall];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)hideViews{
    _act1.hidden = YES;
    _act2.hidden = YES;
    _act3.hidden = YES;
    _act4.hidden = YES;
    _act5.hidden = YES;
}

-(void)loadPictures{
    
    NSLog(@"%i",_imagesArray.count);
    for(int i = 0; i < _imagesArray.count; i++){
        UIImageView *imgView = (UIImageView*)[self.view viewWithTag:i+1];
        {
            imgView.imageURL =  [NSURL URLWithString:[_imagesArray objectAtIndex:i]];
        }
    }
}
-(IBAction)cameraPressed:(id)sender{
    [self showPickerChoice];
}

-(void)showDeleteChoice:(NSInteger )index{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *Delete = [UIAlertAction
                             actionWithTitle:@"Delete"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action)
                             {
                                 [self deleteImageCall:index];
                             }];
    
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction *action)
                             {
                                 
                             }];
    [alertController addAction:Delete];
    [alertController addAction:cancel];
    if(index < self.imagesArray.count)
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
                                   picker.allowsEditing = NO;
                                   picker.delegate = self;
                                   [self presentViewController:picker animated:YES completion:NULL];
                               }
                               else
                               {
//                                   UIAlertView *altnot=[[UIAlertView alloc]initWithTitle:@"Camera Not Available" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                                   [altnot show];
                                   
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
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    if(_image1.image == nil){
        _image1.image = chosenImage;
        CGSize newSize;
        if IS_IPHONE_6Plus {
            //            newSize = CGSizeMake(400, 367);
            newSize = CGSizeMake(284, 284);
        } else {
            //newSize = CGSizeMake(600, 550);
            newSize = CGSizeMake(425, 425);
        }
        
        chosenImage = [self imageWithImage:chosenImage scaledToSize:newSize];
        _image1.alpha = 0.5;
        [self prepareCall:chosenImage];
    }
    else if(_image2.image == nil){
        _image2.image = chosenImage;
        CGSize newSize;
        if IS_IPHONE_6Plus {
            //            newSize = CGSizeMake(400, 367);
            newSize = CGSizeMake(284, 284);
        } else {
            //newSize = CGSizeMake(600, 550);
            newSize = CGSizeMake(425, 425);
        }        chosenImage = [self imageWithImage:chosenImage scaledToSize:newSize];
//        _image2.alpha = 0.5;
        [self prepareCall2:chosenImage];
    }
    else if(_image3.image == nil){
        _image3.image = chosenImage;
        CGSize newSize;
        if IS_IPHONE_6Plus {
            //            newSize = CGSizeMake(400, 367);
            newSize = CGSizeMake(284, 284);
        } else {
            //newSize = CGSizeMake(600, 550);
            newSize = CGSizeMake(425, 425);
        }
        chosenImage = [self imageWithImage:chosenImage scaledToSize:newSize];
//        _image3.alpha = 0.5;
        [self prepareCall3:chosenImage];
    }
    else if(_image4.image == nil){
        _image4.image = chosenImage;
        CGSize newSize;
        if IS_IPHONE_6Plus {
            //            newSize = CGSizeMake(400, 367);
            newSize = CGSizeMake(284, 284);
        } else {
            //newSize = CGSizeMake(600, 550);
            newSize = CGSizeMake(425, 425);
        }
        chosenImage = [self imageWithImage:chosenImage scaledToSize:newSize];
//        _image4.alpha = 0.5;
        [self prepareCall4:chosenImage];
    }
    else  if(_image5.image == nil){
        _image5.image = chosenImage;
        CGSize newSize;
        if IS_IPHONE_6Plus {
            //            newSize = CGSizeMake(400, 367);
            newSize = CGSizeMake(284, 284);
        } else {
            //newSize = CGSizeMake(600, 550);
            newSize = CGSizeMake(425, 425);
        }
        chosenImage = [self imageWithImage:chosenImage scaledToSize:newSize];
//        _image5.alpha = 0.5;
        _camerabtn.enabled = NO;
        [self prepareCall5:chosenImage];
    }
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

#pragma mark - ServerCall

-(void)prepareCall:(UIImage *)choosenImage{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:ADD_PHOTO forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:_jobId forKey:@"job_id"];
    [serviceParams setValue:self.vehicleId forKey:@"vehicle_id"];
    [serviceParams setValue:self.journeyType forKey:@"journey_type"];
    [serviceParams setValue:self.type forKey:@"option_image_name"];
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self makeServerCall:choosenImage];
    });
}

-(void)prepareCall2:(UIImage *)choosenImage{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:ADD_PHOTO forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:_jobId forKey:@"job_id"];
    [serviceParams setValue:self.vehicleId forKey:@"vehicle_id"];
    [serviceParams setValue:self.journeyType forKey:@"journey_type"];
    [serviceParams setValue:self.type forKey:@"option_image_name"];
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self makeServerCall2:choosenImage];
    });
}
-(void)prepareCall3:(UIImage *)choosenImage{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:ADD_PHOTO forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:_jobId forKey:@"job_id"];
    [serviceParams setValue:self.vehicleId forKey:@"vehicle_id"];
    [serviceParams setValue:self.journeyType forKey:@"journey_type"];
    [serviceParams setValue:self.type forKey:@"option_image_name"];
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self makeServerCall3:choosenImage];
    });
}
-(void)prepareCall4:(UIImage *)choosenImage{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:ADD_PHOTO forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:_jobId forKey:@"job_id"];
    [serviceParams setValue:self.vehicleId forKey:@"vehicle_id"];
    [serviceParams setValue:self.journeyType forKey:@"journey_type"];
    [serviceParams setValue:self.type forKey:@"option_image_name"];
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self makeServerCall4:choosenImage];
    });
    
}
-(void)prepareCall5:(UIImage *)choosenImage
{
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    
    serviceParams = [NSMutableDictionary dictionary];
    [serviceParams setValue:ADD_PHOTO forKey:@"request"];
    [serviceParams setValue:dID forKey:@"driver_id"];
    [serviceParams setValue:dApikey forKey:@"driver_api_key"];
    [serviceParams setValue:_jobId forKey:@"job_id"];
    [serviceParams setValue:self.vehicleId forKey:@"vehicle_id"];
    [serviceParams setValue:self.journeyType forKey:@"journey_type"];
    [serviceParams setValue:self.type forKey:@"option_image_name"];
    if([UVLAppglobals sharedAppGlobals].currentDriverLocation.length  > 0){
        [serviceParams setValue:[UVLAppglobals sharedAppGlobals].currentDriverLocation forKey:@"remote_address"];
    }
    else{
        [serviceParams setValue:@"Couldn't get Driver's Location!" forKey:@"remote_address"];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self makeServerCall5:choosenImage];
    });
}

-(void)makeServerCall:(UIImage *)imageToUpload{
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSData *profileData = UIImageJPEGRepresentation(imageToUpload, 0.3);
    [_act1 setHidden:NO];
    [_act1 startAnimating];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    [manager POST:BASE_URL_PHOTOS parameters:serviceParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:profileData name:@"image[]" fileName:@"image.jpg" mimeType:@"image/jpg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressFloat = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
            
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[DataManager sharedManager].photoIsUploadedArray replaceObjectAtIndex:_selectedIndex withObject:@"1"];
        [DataManager sharedManager].isUpdated = YES;
        [_vehicleChechData setUpdatedJobId:[DataManager sharedManager].updatedJobId];
        
        //        [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].photoIsUploadedArray forKey:@"uploadPhoto"];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        [_vehicleChechData setCacheUploadPhot:[DataManager sharedManager].photoIsUploadedArray];
        NSDictionary *obj = @{@"Type": self.type};
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"makeTick"
         object:obj];
        [_act1 removeFromSuperview];
        [_image1 setAlpha:1.0];
        NSLog(@" %@", responseObject);
        int flag = [[responseObject objectForKey:@"flag"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        NSString *photoID = [responseObject objectForKey:@"photo_id"];
        NSString *photoURL = [responseObject objectForKey:@"photo"];
        [self.imagesArray addObject:photoURL];
        [self.imagesIDArray addObject:photoID];
        self.navigationController.navigationBar.userInteractionEnabled = YES;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Unable to process request at the moment. Try again Later" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
        self.navigationController.navigationBar.userInteractionEnabled = YES;
    }];
}
-(void)makeServerCall2:(UIImage *)imageToUpload{
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSData *profileData = UIImageJPEGRepresentation(imageToUpload, 0.3);
    [_act2 setHidden:NO];
    [_act2 startAnimating];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    [manager POST:BASE_URL_PHOTOS parameters:serviceParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:profileData name:@"image[]" fileName:@"image.png" mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressFloat = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
            
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[DataManager sharedManager].photoIsUploadedArray replaceObjectAtIndex:_selectedIndex withObject:@"1"];
        //        [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].photoIsUploadedArray forKey:@"uploadPhoto"];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [_vehicleChechData setCacheUploadPhot:[DataManager sharedManager].photoIsUploadedArray];
        
        NSDictionary *obj = @{@"Type": self.type};
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"makeTick"
         object:obj];
        [_act2 removeFromSuperview];
//        _image2.alpha = 1.0;
        NSLog(@" %@", responseObject);
        int flag = [[responseObject objectForKey:@"flag"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        NSString *photoID = [responseObject objectForKey:@"photo_id"];
        NSString *photoURL = [responseObject objectForKey:@"photo"];
        [self.imagesArray addObject:photoURL];
        [self.imagesIDArray addObject:photoID];
        self.navigationController.navigationBar.userInteractionEnabled = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.navigationController.navigationBar.userInteractionEnabled = YES;

    }];
}
-(void)makeServerCall3:(UIImage *)imageToUpload{
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSData *profileData = UIImageJPEGRepresentation(imageToUpload, 0.3);
    [_act3 setHidden:NO];
    [_act3 startAnimating];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    [manager POST:BASE_URL_PHOTOS parameters:serviceParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:profileData name:@"image[]" fileName:@"image.png" mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressFloat = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
            
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[DataManager sharedManager].photoIsUploadedArray replaceObjectAtIndex:_selectedIndex withObject:@"1"];
        //        [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].photoIsUploadedArray forKey:@"uploadPhoto"];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        [_vehicleChechData setCacheUploadPhot:[DataManager sharedManager].photoIsUploadedArray];
        
        
        NSDictionary *obj = @{@"Type": self.type};
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"makeTick"
         object:obj];
        [_act3 removeFromSuperview];
//        _image3.alpha = 1.0;
        NSLog(@" %@", responseObject);
        int flag = [[responseObject objectForKey:@"flag"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        NSString *photoID = [responseObject objectForKey:@"photo_id"];
        NSString *photoURL = [responseObject objectForKey:@"photo"];
        [self.imagesArray addObject:photoURL];
        [self.imagesIDArray addObject:photoID];
          self.navigationController.navigationBar.userInteractionEnabled = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          self.navigationController.navigationBar.userInteractionEnabled = YES;
    }];
}
-(void)makeServerCall4:(UIImage *)imageToUpload{
      self.navigationController.navigationBar.userInteractionEnabled = NO;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSData *profileData = UIImageJPEGRepresentation(imageToUpload, 0.3);
    [_act4 setHidden:NO];
    [_act4 startAnimating];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    [manager POST:BASE_URL_PHOTOS parameters:serviceParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:profileData name:@"image[]" fileName:@"image.png" mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressFloat = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
            
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[DataManager sharedManager].photoIsUploadedArray replaceObjectAtIndex:_selectedIndex withObject:@"1"];
        //        [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].photoIsUploadedArray forKey:@"uploadPhoto"];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        [_vehicleChechData setCacheUploadPhot:[DataManager sharedManager].photoIsUploadedArray];
        NSDictionary *obj = @{@"Type": self.type};
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"makeTick"
         object:obj];
        [_act4 removeFromSuperview];
//        _image4.alpha = 1.0;
        NSLog(@" %@", responseObject);
        int flag = [[responseObject objectForKey:@"flag"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        NSString *photoID = [responseObject objectForKey:@"photo_id"];
        NSString *photoURL = [responseObject objectForKey:@"photo"];
        [self.imagesArray addObject:photoURL];
        [self.imagesIDArray addObject:photoID];
          self.navigationController.navigationBar.userInteractionEnabled = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          self.navigationController.navigationBar.userInteractionEnabled = YES;
    }];
}
-(void)makeServerCall5:(UIImage *)imageToUpload{
      self.navigationController.navigationBar.userInteractionEnabled = NO;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSData *profileData = UIImageJPEGRepresentation(imageToUpload, 0.3);
    [_act5 setHidden:NO];
    [_act5 startAnimating];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    [manager POST:BASE_URL_PHOTOS parameters:serviceParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:profileData name:@"image[]" fileName:@"image.png" mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressFloat = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
            
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[DataManager sharedManager].photoIsUploadedArray replaceObjectAtIndex:_selectedIndex withObject:@"1"];
        //        [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].photoIsUploadedArray forKey:@"uploadPhoto"];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        [_vehicleChechData setCacheUploadPhot:[DataManager sharedManager].photoIsUploadedArray];
        
        NSDictionary *obj = @{@"Type": self.type};
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"makeTick"
         object:obj];
        [_act5 removeFromSuperview];
//        _image5.alpha = 1.0f;
        NSLog(@" %@", responseObject);
        int flag = [[responseObject objectForKey:@"flag"] intValue];
        NSString *message = [responseObject objectForKey:@"message"];
        NSString *photoID = [responseObject objectForKey:@"photo_id"];
        NSString *photoURL = [responseObject objectForKey:@"photo"];
        [self.imagesArray addObject:photoURL];
        [self.imagesIDArray addObject:photoID];
          self.navigationController.navigationBar.userInteractionEnabled = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          self.navigationController.navigationBar.userInteractionEnabled = YES;
    }];
}

- (void)deleteImageCall:(NSInteger)index {
    NSString *dID = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:DriverID];
    NSString *dApikey = (NSString *)
    [[NSUserDefaults standardUserDefaults]objectForKey:APiKEY];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:DELETE_VEHICLE_PHOTO forKey:@"request"];
    [params setValue:dID forKey:@"driver_id"];
    [params setValue:dApikey forKey:@"driver_api_key"];
    [params setValue:self.vehicleId forKey:@"vehicle_id"];
    [params setValue:[self.imagesIDArray objectAtIndex:index] forKey:@"photo_id"];
    [ApiManager postRequest:params success:^(id data) {
        for (NSInteger i = index; i < self.imagesArray.count; i++) {
            UIImageView *currentImageView = (UIImageView *)[self.view viewWithTag:i+1];
            UIImageView *nextImageView = (UIImageView *)[self.view viewWithTag:i+2];
            currentImageView.image = nextImageView.image;
        }
        [self.imagesArray removeObjectAtIndex:index];
        [self.imagesIDArray removeObjectAtIndex:index];
        _camerabtn.enabled= YES;
        //        _deleteCount++;
    } failure:^(NSError *error) {
        NSLog(@"Error on delete photo");
    }];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
