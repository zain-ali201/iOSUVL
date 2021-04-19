//
//  JobDo.h
//  UVL
//
//  Created by Osama on 02/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VehicleDo.h"
@interface JobDo : NSObject
@property (strong, nonatomic) NSString *bookingName;
//Collection
@property (strong, nonatomic) NSString *collectionAddress;
@property (strong, nonatomic) NSString *collectionCompany;
@property (strong, nonatomic) NSString *collection_address2;
@property (strong, nonatomic) NSString *collection_contact_location;
@property (strong, nonatomic) NSString *collection_contact_signature;
@property (strong, nonatomic) NSString *collection_country;
@property (strong, nonatomic) NSString *collection_date;
@property (strong, nonatomic) NSString *collection_email;
@property (strong, nonatomic) NSString *collection_name;
@property (strong, nonatomic) NSString *collection_postcode;
@property (strong, nonatomic) NSString *collection_time;
@property (strong, nonatomic) NSString *collection_town;
@property (strong, nonatomic) NSString *collection_telephone;
//Delivery
@property (strong, nonatomic) NSString *delivery_address;
@property (strong, nonatomic) NSString *delivery_address2;
@property (strong, nonatomic) NSString *delivery_company;
@property (strong, nonatomic) NSString *delivery_contact_location;
@property (strong, nonatomic) NSString *delivery_contact_signature;
@property (strong, nonatomic) NSString *delivery_country;
@property (strong, nonatomic) NSString *delivery_date;
@property (strong, nonatomic) NSString *delivery_email;
@property (strong, nonatomic) NSString *delivery_name;
@property (strong, nonatomic) NSString *delivery_postcode;
@property (strong, nonatomic) NSString *delivery_telephone;
@property (strong, nonatomic) NSString *delivery_time;
@property (strong, nonatomic) NSString *delivery_town;
@property (strong, nonatomic) NSString *driver_notes;

@property (nonatomic,strong) NSString *jobId;
@property (nonatomic) int jobStatus;
@property (nonatomic, strong) NSString *movementNotes;
@property (nonatomic, strong) NSString *specialInstructions;

@property (nonatomic, strong) NSString *paymentType;
@property (nonatomic, strong) NSString *jobPrice;

@property (strong,nonatomic) NSMutableArray *vehiclesList;
@property (strong,nonatomic) NSMutableArray *vehiclesListDelivery;
@property int position;
-(id)initWithDictionary:(NSDictionary *)_dictionary;
@end
