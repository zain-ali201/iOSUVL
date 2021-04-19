//
//  CollectionDeliveryVC.h
//  UVL
//
//  Created by Osama on 27/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JobDo.h"
#import <CallKit/CXCallObserver.h>
#import <CallKit/CallKit.h>
@interface CollectionDeliveryVC : UIViewController<CXCallObserverDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblview;
@property (strong, nonatomic) NSMutableArray *collectionArray;
@property (strong, nonatomic) NSMutableArray *deliveryArray;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScroll;
@property (strong,nonatomic) JobDo *jObj;


@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *jobStatus;
@property (weak, nonatomic) IBOutlet UILabel *countlbl;
@property (weak, nonatomic) IBOutlet UILabel *pricelbl;
@property (weak, nonatomic) IBOutlet UILabel *noteslbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstrains;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *positionOfView;
@property (strong, nonatomic) CXCallObserver *callObserver;
@property (strong, nonatomic) NSString *phNo;
@property (assign ,nonatomic) BOOL reloadCheck;

@end
