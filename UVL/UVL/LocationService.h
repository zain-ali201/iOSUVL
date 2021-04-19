//
//  LocationService.h
//  UVL
//
//  Created by Osama on 17/01/2017.
//  Copyright © 2017 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface LocationService : NSObject<CLLocationManagerDelegate>
+(LocationService *) sharedInstance;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSString *currentLocationStr;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
@end
