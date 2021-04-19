//
//  DataManager.h
//  LawNote
//
//  Created by Samreen Noor on 22/07/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject
@property (strong, nonatomic) NSMutableArray *photoIsUploadedArray;
@property (strong, nonatomic) NSMutableArray *cacheCollectionDataArray;
@property (strong, nonatomic) NSMutableArray *cacheDeliveryDataArray;
@property ( nonatomic) BOOL isUpdated;
@property ( nonatomic) BOOL isNotificationRejected;

@property (strong, nonatomic) NSString *updatedJobId;

+ (DataManager *) sharedManager;

@end
