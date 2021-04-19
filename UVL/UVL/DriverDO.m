//
//  DriverDO.m
//  UVL
//
//  Created by Osama on 31/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "DriverDO.h"

@implementation DriverDO
- (id)initWithDictionary:(NSDictionary *) responseData
{
    self = [super init];
    if (self) {
        self.dId            = [responseData objectForKey:@"driver_id"];
        self.demail         = [responseData objectForKey:@"driver_email"];
        self.dName          = [responseData objectForKey:@"driver_name"];
        self.dapiKey        = [responseData objectForKey:@"driver_api_key"];
        self.dStatus        = [responseData objectForKey:@"driver_status"];
    }
    return self;
}
@end
