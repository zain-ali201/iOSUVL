//
//  LabelTableViewCell.h
//  UVL
//
//  Created by Ahmed Sadiq on 21/08/2017.
//  Copyright © 2017 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LabelTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UICollectionView *carsCollection;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *vehicleNo;
@property (weak, nonatomic) IBOutlet UILabel *jobStatus;
@property (weak, nonatomic) IBOutlet UILabel *collectionAddress;
@property (weak, nonatomic) IBOutlet UILabel *deliveryAddress;
@property (weak, nonatomic) IBOutlet UILabel *vehicleName;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;

@end
