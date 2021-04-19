//
//  VehicleOptionViewController.h
//  UVL
//
//  Created by Osama on 27/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VehicleDetails.h"
#import "MKDropdownMenu.h"

@class VehicleOptionViewController;
@protocol VehicleOptionViewControllerDelegate <NSObject>
-(void) breakSwitchDelegate: (VehicleOptionViewController *)sender;
-(void) poaSwitchDelegate: (VehicleOptionViewController *)sender;
@end

@interface VehicleOptionViewController : UIViewController{
    VehicleDetails *details;
}
@property (nonatomic, weak) id <VehicleOptionViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tblview;
@property (strong, nonatomic) NSString *jobId;
@property (strong, nonatomic) NSString *vehicleId;
@property (assign) BOOL isFromCollection;
@property ( nonatomic) long selectedIndex;

@property (strong, nonatomic) NSString *journeyType;
@property (assign) BOOL isCallSuccessful;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) UIImage *sigImage;

@property (assign) BOOL isLastCar;
@property (assign) int isCOCOrCOD;
@property (strong, nonatomic) NSString *jPrice;
@end
