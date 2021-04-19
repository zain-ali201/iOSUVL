//
//  VehicleDetails.m
//  UVL
//
//  Created by Osama on 04/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "VehicleDetails.h"

@implementation VehicleDetails
- (id)initWithDictionary:(NSDictionary *) responseData
{
    self = [super init];
    if (self) {
        self.vehicle_odometer = [responseData objectForKey:@"vehicle_odometer"];
        self.number_of_mats = [responseData objectForKey:@"number_of_mats"];
        self.number_of_keys = [responseData objectForKey:@"number_of_keys"];
        self.service_book = [responseData objectForKey:@"service_book"];
        self.locking_kit = [responseData objectForKey:@"locking_kit"];
        self.spare_wheel = [responseData objectForKey:@"spare_wheel"];
        self.vehicle_defects = [responseData objectForKey:@"vehicle_defects"];
        self.journey_type = [responseData objectForKey:@"journey_type"];
        self.signatureImageUrl = [responseData objectForKey:@"signature_image"];
        self.personName = [responseData objectForKey:@"name"];
        self.personEmail = [responseData objectForKey:@"email"];
        self.isCollectionData = [[responseData objectForKey:@"is_collection_data"] intValue];
        NSArray *inteniorPhotos = [responseData objectForKey:@"interior_photos"];
        self.interior_photos = [[NSMutableArray alloc] init];
        for(int i = 0; i < inteniorPhotos.count; i++){
            NSString *photoUrl = [inteniorPhotos objectAtIndex:i];
            [self.interior_photos addObject:photoUrl];
        }
        NSArray *glove_box_photos = [responseData objectForKey:@"glove_box_photos"];
        self.glove_box_photos = [[NSMutableArray alloc] init];
        for(int i = 0; i < glove_box_photos.count; i++){
            NSString *photoUrl = [glove_box_photos objectAtIndex:i];
            [self.glove_box_photos addObject:photoUrl];
        }
        NSArray *offside_photos = [responseData objectForKey:@"offside_photos"];
        self.offside_photos = [[NSMutableArray alloc] init];
        for(int i = 0; i < offside_photos.count; i++){
            NSString *photoUrl = [offside_photos objectAtIndex:i];
            [self.offside_photos addObject:photoUrl];
        }
        NSArray *front_photos = [responseData objectForKey:@"front_photos"];
        self.front_photos = [[NSMutableArray alloc] init];
        for(int i = 0; i < front_photos.count; i++){
            NSString *photoUrl = [front_photos objectAtIndex:i];
            [self.front_photos addObject:photoUrl];
        }
        NSArray *nearside_photos = [responseData objectForKey:@"nearside_photos"];
        self.nearside_photos = [[NSMutableArray alloc] init];
        for(int i = 0; i < nearside_photos.count; i++){
            NSString *photoUrl = [nearside_photos objectAtIndex:i];
            [self.front_photos addObject:photoUrl];
        }
        NSArray *rear_photos = [responseData objectForKey:@"rear_photos"];
        self.rear_photos = [[NSMutableArray alloc] init];
        for(int i = 0; i < rear_photos.count; i++){
            NSString *photoUrl = [rear_photos objectAtIndex:i];
            [self.front_photos addObject:photoUrl];
        }
        NSArray *boot_photos = [responseData objectForKey:@"boot_photos"];
        self.boot_photos = [[NSMutableArray alloc] init];
        for(int i = 0; i < boot_photos.count; i++){
            NSString *photoUrl = [boot_photos objectAtIndex:i];
            [self.boot_photos addObject:photoUrl];
        }
    }
    return self;
}
@end
