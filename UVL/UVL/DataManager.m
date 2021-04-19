//
//  DataManager.m
//  LawNote
//
//  Created by Samreen Noor on 22/07/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager
static DataManager *sharedManager;

+ (DataManager *) sharedManager
{
    if(sharedManager == nil)
    {
        sharedManager = [[DataManager alloc] init];
        NSArray *temp  = @[@"0",@"0",@"0",@"0",@"0",@"0",@"0"];
        sharedManager.cacheDeliveryDataArray = [[NSMutableArray alloc]init];
        sharedManager.cacheCollectionDataArray = [[NSMutableArray alloc]init];
        sharedManager.photoIsUploadedArray = [[NSMutableArray alloc]initWithArray:temp];
    }
    return sharedManager;
}


@end
