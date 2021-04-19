//
//  VehicleDetails.h
//  UVL
//
//  Created by Osama on 04/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface VehicleDetails : NSObject
@property (strong, nonatomic) NSString *personName;
@property (strong, nonatomic) NSString *personEmail;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) UIImage *signatureImage;

@property (nonatomic, assign) long jobNumber;
@property (nonatomic, assign) int isCollectionData;
@property (strong, nonatomic) NSString *updatedJobId;

@property (strong, nonatomic) NSMutableArray *cacheUploadPhot;

@property ( nonatomic) BOOL isCache;
@property ( nonatomic) BOOL isSubmit;
@property ( nonatomic) BOOL isEnable;

@property (strong, nonatomic) NSString *vehicle_odometer;
@property (strong, nonatomic) NSString *number_of_mats;
@property (strong, nonatomic) NSString *number_of_keys;
@property (strong, nonatomic) NSString *service_book;
@property (strong, nonatomic) NSString *locking_kit;
@property (strong, nonatomic) NSString *spare_wheel;
@property (strong, nonatomic) NSString *vehicle_defects;
@property (strong, nonatomic) NSString *journey_type;
@property (strong, nonatomic) NSString *signatureImageUrl;

@property (strong, nonatomic) NSMutableArray *interior_photos;
@property (strong, nonatomic) NSMutableArray *offside_photos;
@property (strong, nonatomic) NSMutableArray *front_photos;
@property (strong, nonatomic) NSMutableArray *nearside_photos;
@property (strong, nonatomic) NSMutableArray *rear_photos;
@property (strong, nonatomic) NSMutableArray *boot_photos;
@property (strong, nonatomic) NSMutableArray *glove_box_photos;


-(id)initWithDictionary:(NSDictionary *)_dictionary;
@end
