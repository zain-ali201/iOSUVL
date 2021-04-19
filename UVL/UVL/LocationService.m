//
//  LocationService.m
//  UVL
//
//  Created by Osama on 17/01/2017.
//  Copyright © 2017 TxLabz. All rights reserved.
//

#import "LocationService.h"
#import "UVLAppglobals.h"

@implementation LocationService
+(LocationService *) sharedInstance
{
    static LocationService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter  = kCLDistanceFilterNone;
        [self.locationManager requestWhenInUseAuthorization];
        self.locationManager.delegate = self;
    }
    return self;
}

- (void)startUpdatingLocation
{
    NSLog(@"Starting location updates");
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
    NSLog(@"Stopping location updates");
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Location service failed with error %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray*)locations
{
    CLLocation *location = [locations lastObject];
    NSLog(@"Latitude %+.6f, Longitude %+.6f\n",
          location.coordinate.latitude,
          location.coordinate.longitude);
    if(location != nil)
    {
        NSLog(@"%@",location);
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
    // Turn off the location manager to save power.
//    [self getAddress];
}

-(void)getAddress
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    
    [geocoder reverseGeocodeLocation: self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             [self.locationManager stopUpdatingLocation];
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             NSString *Address = [[NSString alloc]initWithString:locatedAt];
             NSString *Country = [[NSString alloc]initWithString:placemark.country];
             self.currentLocationStr = [NSString stringWithFormat:@"%@, %@",Address,Country];
             [UVLAppglobals sharedAppGlobals].currentDriverLocation = self.currentLocationStr;
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
             //return;
         }
         /*---- For more results
          placemark.region);
          placemark.country);
          placemark.locality);
          placemark.name);
          placemark.ocean);
          placemark.postalCode);
          placemark.subLocality);
          placemark.location);
          ------*/
     }];
}

@end
