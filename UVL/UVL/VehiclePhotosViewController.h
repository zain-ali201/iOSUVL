//
//  VehiclePhotosViewController.h
//  UVL
//
//  Created by Osama on 28/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VehicleDetails.h"
@interface VehiclePhotosViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *tblView;
@property (assign) BOOL alreadyUploaded;
@property (assign) BOOL isFromCollection;

@property (strong, nonatomic) VehicleDetails *vehicleChechData;
@property (strong, nonatomic) VehicleDetails *vDetails;
@property (strong, nonatomic) NSMutableArray *photosUrls;
@property (strong, nonatomic) NSString *veId;
@property (strong, nonatomic) NSString *journeyType;
@property (strong, nonatomic) NSString *jId;
@property (strong, nonatomic) NSString *typeDone;
@end
