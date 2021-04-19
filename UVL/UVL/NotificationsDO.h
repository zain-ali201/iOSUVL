//
//  NotificationsDO.h
//  UVL
//
//  Created by Osama on 31/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationsDO : NSObject
@property (strong, nonatomic) NSString *notificationId;
@property (strong, nonatomic) NSString *notificationDriverId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *read;
@property (strong, nonatomic) NSString *dateCreated;
@property (assign, nonatomic) BOOL isApprovalNeeded;
-(id)initWithDictionary:(NSDictionary *)_dictionary;
@end
