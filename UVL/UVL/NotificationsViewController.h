//
//  NotificationsViewController.h
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tblview;
@property (strong, nonatomic) NSMutableArray *notificationsArray;
@end
