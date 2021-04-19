//
//  VehicleDo.h
//  UVL
//
//  Created by Osama on 02/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VehicleDo : NSObject
@property (strong, nonatomic) NSString *vehicleId;
@property (strong, nonatomic) NSString *vehicleMake;
@property (strong, nonatomic) NSString *vehicleModel;
@property (strong, nonatomic) NSString *vrnNo;
-(id)initWithDictionary:(NSDictionary *)_dictionary;
@end
