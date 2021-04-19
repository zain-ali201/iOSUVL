//
//  DefectDataTableCell.h
//  UVL
//
//  Created by cellzone on 1/27/21.
//  Copyright © 2021 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DefectDataTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *defectDataLbl;
@property (weak, nonatomic) IBOutlet UISwitch *switcher;

@end

NS_ASSUME_NONNULL_END
