//
//  VehicleDo.m
//  UVL
//
//  Created by Osama on 02/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "VehicleDo.h"

@implementation VehicleDo
- (id)initWithDictionary:(NSDictionary *) responseData
{
    self = [super init];
    if (self) {
        self.vehicleId    = [responseData objectForKey:@"vehicle_id"];
        self.vehicleMake = [responseData objectForKey:@"vehicle_make"];
        self.vehicleModel = [responseData objectForKey:@"vehicle_model"];
        self.vrnNo = [responseData objectForKey:@"vehicle_vrn"];
    }
    return self;
}
@end
