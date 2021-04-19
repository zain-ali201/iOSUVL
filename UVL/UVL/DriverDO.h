//
//  DriverDO.h
//  UVL
//
//  Created by Osama on 31/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriverDO : NSObject
@property (strong, nonatomic) NSString *dapiKey;
@property (strong, nonatomic) NSString *demail;
@property (strong, nonatomic) NSString *dId;
@property (strong, nonatomic) NSString *dName;
@property (strong, nonatomic) NSString *dStatus;
-(id)initWithDictionary:(NSDictionary *)_dictionary;
@end
