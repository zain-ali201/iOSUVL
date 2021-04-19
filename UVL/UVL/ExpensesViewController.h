//
//  ExpensesViewController.h
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpensesViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *expenseType;

@property (weak, nonatomic) IBOutlet UIView *FuelView;
@property (weak, nonatomic) IBOutlet UIView *tollView;
@property (weak, nonatomic) IBOutlet UIView *otherView;

@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UITextField *fuelAmount;
@property (weak, nonatomic) IBOutlet UITextField *fuelOdometer;
@property (weak, nonatomic) IBOutlet UITextField *tollAmount;

@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (strong, nonatomic) UIImage *receiptImage;
@property (strong, nonatomic) UIImage *odometerImage;

-(IBAction)expensetypeTapped:(id)sender;
-(IBAction)submitPressed:(id)sender;
-(IBAction)photoBtnPressed:(id)sender;

//next Images
@property (weak, nonatomic) IBOutlet UIImageView *otherNext;
@property (weak, nonatomic) IBOutlet UIImageView *FuelNext;
@property (weak, nonatomic) IBOutlet UIImageView *tollNext;
@end
