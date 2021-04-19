//
//  TruckInfoTableViewCell.h
//  UVL
//
//  Created by Osama on 31/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TruckInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *propertyLbl;
@property (weak, nonatomic) IBOutlet UILabel *details;
@property (weak, nonatomic) IBOutlet UITextField *Odometer;
@end
