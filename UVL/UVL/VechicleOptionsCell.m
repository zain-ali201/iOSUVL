//
//  VechicleOptionsCell.m
//  UVL
//
//  Created by Osama on 28/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "VechicleOptionsCell.h"

@implementation VechicleOptionsCell
@synthesize propertyLbl,propertyField;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [[self.txtView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [[self.txtView layer] setBorderWidth:1.0];
    [[self.txtView layer] setCornerRadius:0];
    self.txtView.textContainerInset = UIEdgeInsetsMake(0,0,0,0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
