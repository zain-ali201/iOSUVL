//
//  SingleButtonCell.m
//  UVL
//
//  Created by Osama on 31/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "SingleButtonCell.h"

@implementation SingleButtonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.btn.layer.cornerRadius = 0;
    self.btn.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
