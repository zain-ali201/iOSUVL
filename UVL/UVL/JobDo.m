//
//  JobDo.m
//  UVL
//
//  Created by Osama on 02/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "JobDo.h"

@implementation JobDo
- (id)initWithDictionary:(NSDictionary *) responseData
{
    self = [super init];
    if (self) {
        self.bookingName = [responseData objectForKey:@"booking_name"];
        self.collectionAddress = [responseData objectForKey:@"collection_address1"];
        self.collectionCompany = [responseData objectForKey:@"collection_company"];
        self.collection_contact_location = [responseData objectForKey:@"collection_contact_location"];
        self.collection_address2 = [responseData objectForKey:@"collection_address2"];
        self.collection_contact_signature = [responseData objectForKey:@"collection_contact_signature"];
        self.collection_country = [responseData objectForKey:@"collection_country"];
        self.collection_date = [responseData objectForKey:@"collection_date"];
        self.collection_email = [responseData objectForKey:@"collection_email"];
        self.collection_name = [responseData objectForKey:@"collection_name"];
        self.collection_telephone = [responseData objectForKey:@"collection_telephone"];
        self.collection_postcode = [responseData objectForKey:@"collection_postcode"];
        self.collection_time = [responseData objectForKey:@"collection_time"];
        self.collection_town = [responseData objectForKey:@"collection_town"];
        self.delivery_address = [responseData objectForKey:@"delivery_address1"];
        self.delivery_address2 = [responseData objectForKey:@"delivery_address2"];
        self.delivery_company = [responseData objectForKey:@"delivery_company"];
        self.delivery_contact_location = [responseData objectForKey:@"delivery_contact_location"];
        self.delivery_contact_signature = [responseData objectForKey:@"delivery_contact_signature"];
        self.delivery_country = [responseData objectForKey:@"delivery_country"];
        self.delivery_date = [responseData objectForKey:@"delivery_date"];
        self.delivery_email = [responseData objectForKey:@"delivery_email"];
        self.delivery_name = [responseData objectForKey:@"delivery_name"];
        self.delivery_postcode = [responseData objectForKey:@"delivery_postcode"];
        self.delivery_telephone = [responseData objectForKey:@"delivery_telephone"];
        self.delivery_time = [responseData objectForKey:@"delivery_time"];
        self.delivery_town = [responseData objectForKey:@"delivery_town"];
        self.driver_notes = [responseData objectForKey:@"driver_notes"];
        self.jobId = [responseData objectForKey:@"job_id"];
        self.jobStatus = [[responseData objectForKey:@"job_status"] intValue];
        self.movementNotes = [responseData objectForKey:@"movement_notes"];
        self.specialInstructions = [responseData objectForKey:@"special_instructions"];
        self.paymentType = [responseData objectForKey:@"payment_type"];
        self.jobPrice = [responseData objectForKey:@"job_price"];
        
        NSArray *vehiclesData = [responseData objectForKey:@"vehicles_list"];
        if(vehiclesData.count > 0){
            _vehiclesList = [[NSMutableArray alloc] init];
            _vehiclesListDelivery = [[NSMutableArray alloc] init];
            for(int i = 0; i < vehiclesData.count; i++){
                NSDictionary *vehicleDict = [vehiclesData objectAtIndex:i];
                VehicleDo *v = [[VehicleDo alloc] initWithDictionary:vehicleDict];
                [_vehiclesList addObject:v];
            }
            _vehiclesListDelivery = [_vehiclesList mutableCopy];
        }
    }
    return self;
}
@end
