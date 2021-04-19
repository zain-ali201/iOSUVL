//
//  VechicleOptionsCell.h
//  UVL
//
//  Created by Osama on 28/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKDropdownMenu.h"
@interface VechicleOptionsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *propertyLbl;
@property (weak, nonatomic) IBOutlet UITextField *propertyField;
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UISwitch *yesOrNo;
@property (weak, nonatomic) IBOutlet UIImageView *aview;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImg;
@property (weak, nonatomic) IBOutlet MKDropdownMenu *dropDown;
@end
