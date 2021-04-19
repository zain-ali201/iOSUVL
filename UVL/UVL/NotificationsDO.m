//
//  NotificationsDO.m
//  UVL
//
//  Created by Osama on 31/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "NotificationsDO.h"

@implementation NotificationsDO
- (id)initWithDictionary:(NSDictionary *) responseData
{
    self = [super init];
    if (self) {
        self.notificationId               = [responseData objectForKey:@"notification_id"];
        self.notificationDriverId         = [responseData objectForKey:@"notification_driver_id"];
        self.title          = [responseData objectForKey:@"notification_name"];
        self.message        = [responseData objectForKey:@"notification_message"];
        self.read        = [responseData objectForKey:@"notification_read"];
        self.dateCreated        = [responseData objectForKey:@"date_created"];
        self.isApprovalNeeded = [[responseData objectForKey:@"notification_approval"] boolValue];
    }
    return self;
}
@end
