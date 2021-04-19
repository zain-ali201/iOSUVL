//
//  MoreViewController.h
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VehicleOptionViewController.h"

@interface MoreViewController : UIViewController<VehicleOptionViewControllerDelegate>{
    VehicleOptionViewController *voptions;
}

typedef enum BreakTimeSlot : NSUInteger {
    kBreakTimeSlot15 = 15,
    kBreakTimeSlot30 = 30,
    kBreakTimeSlot45 = 45
} BreakTimeSlot;

@property (weak, nonatomic) IBOutlet UISwitch *breakSwrich;
@property (weak, nonatomic) IBOutlet UISwitch *availableSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *otherWorkSwitch;

- (IBAction)brekedAction:(id)sender;
- (IBAction)availableAction:(id)sender;

- (void)breakOn;
- (void)poaOn;
- (void)otherWorkOn;
- (void)turnTheSwitchesoff;
- (void)timerCallturnTheSwitchesoff;

@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSString *jobIdForBreakOrPOA;
@property (strong, nonatomic) NSString *isNormal;
@property (nonatomic) BreakTimeSlot selectedBreakTimeSlot;
@property (assign, nonatomic) BOOL justOnce;
@end
