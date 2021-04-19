//
//  JobTableViewCell.h
//  UVL
//
//  Created by Osama on 27/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JobTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UICollectionView *carsCollection;
@property (weak, nonatomic) IBOutlet UILabel *countlbl;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *vehicleNo;
@property (weak, nonatomic) IBOutlet UILabel *jobStatus;
@property (weak, nonatomic) IBOutlet UILabel *collectionAddress;
@property (weak, nonatomic) IBOutlet UILabel *deliveryAddress;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@end
