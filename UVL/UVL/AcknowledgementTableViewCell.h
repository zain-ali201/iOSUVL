//
//  AcknowledgementTableViewCell.h
//  UVL
//
//  Created by Osama on 28/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "CTCheckbox.h"

@interface AcknowledgementTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AsyncImageView *signatureImg;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet CTCheckbox *checkbox1;
@end
