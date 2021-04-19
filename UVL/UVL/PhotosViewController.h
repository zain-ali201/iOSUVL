//
//  PhotosViewController.h
//  UVL
//
//  Created by Osama on 28/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VehicleDetails.h"
#import "AsyncImageView.h"

@interface PhotosViewController : UIViewController
@property (weak, nonatomic) IBOutlet AsyncImageView *image1;
@property (weak, nonatomic) IBOutlet AsyncImageView *image2;
@property (weak, nonatomic) IBOutlet AsyncImageView *image3;
@property (weak, nonatomic) IBOutlet AsyncImageView *image4;
@property (weak, nonatomic) IBOutlet AsyncImageView *image5;

@property (strong, nonatomic) NSMutableArray *imagesArray;
@property (strong, nonatomic) NSMutableArray *imagesIDArray;
@property (assign) BOOL isScussessFul;
@property (weak, nonatomic) IBOutlet UIButton *camerabtn;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *vehicleId;
@property (strong, nonatomic) NSString *journeyType;
@property (strong, nonatomic) NSString *jobId;
@property (strong, nonatomic) NSString *titleOfNav;
@property ( nonatomic) long selectedIndex;
@property (assign, nonatomic) NSInteger deleteCount;

@property (strong, nonatomic) VehicleDetails *vehicleChechData;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act1;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act2;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act3;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act4;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act5;
@end
