//
//  NotiDetailsViewController.h
//  UVL
//
//  Created by Osama on 17/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationsDO.h"
@interface NotiDetailsViewController : UIViewController
@property (nonatomic, weak)     IBOutlet UILabel *detaillbl;
@property (nonatomic, weak)    IBOutlet UIButton *acceptBtn;
@property (strong, nonatomic)   NotificationsDO *notiObject;
@end
