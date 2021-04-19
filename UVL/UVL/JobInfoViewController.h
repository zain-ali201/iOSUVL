//
//  JobInfoViewController.h
//  UVL
//
//  Created by Osama on 27/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JobDo.h"
@class CTCheckbox;

@interface JobInfoViewController : UIViewController
@property (weak, nonatomic) IBOutlet CTCheckbox *checkbox1;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScroll;
@property (weak, nonatomic) IBOutlet UITextView *declineReasontxtView;
@property (weak, nonatomic) IBOutlet UITextView *specialInstructionstxtView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstrains;
@property (weak, nonatomic) IBOutlet UILabel *noteslbl;

//
@property (weak, nonatomic) IBOutlet UILabel *address2;
@property (weak, nonatomic) IBOutlet UILabel *address1;
@property (weak, nonatomic) IBOutlet UILabel *customerName;
@property (weak, nonatomic) IBOutlet UILabel *postCode;
@property (weak, nonatomic) IBOutlet UILabel *town;
@property (weak, nonatomic) IBOutlet UILabel *companyName;
//
@property (weak, nonatomic) IBOutlet UILabel *daddress2;
@property (weak, nonatomic) IBOutlet UILabel *daddress1;
@property (weak, nonatomic) IBOutlet UILabel *dcustomerName;
@property (weak, nonatomic) IBOutlet UILabel *dpostCode;
@property (weak, nonatomic) IBOutlet UILabel *dtown;
@property (weak, nonatomic) IBOutlet UILabel *dcompanyName;

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *jobStatus;
@property (weak, nonatomic) IBOutlet UILabel *countlbl;
@property (weak, nonatomic) IBOutlet UILabel *pricelbl;

@property (weak, nonatomic) IBOutlet UILabel *noOfVehicles;
@property (strong,nonatomic) JobDo *jObj;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *positionOfView;

-(IBAction)acceptPressed:(id)sender;
-(IBAction)rejectedPressed:(id)sender;
@end
