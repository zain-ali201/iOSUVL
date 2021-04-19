//
//  ShiftsViewController.h
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZTimerLabel.h"
@class CTCheckbox;

@interface ShiftsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>{
    MZTimerLabel *timerLabel;
}
@property (weak, nonatomic) IBOutlet CTCheckbox *checkbox1;
@property (weak, nonatomic) IBOutlet CTCheckbox *checkbox2;
@property (weak, nonatomic) IBOutlet CTCheckbox *checkbox3;
@property (weak, nonatomic) IBOutlet CTCheckbox *checkbox4;
@property (weak, nonatomic) IBOutlet CTCheckbox *checkbox5;
@property (weak, nonatomic) IBOutlet CTCheckbox *checkbox6;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScroll;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UITableView *SecondTblView;
@property (weak, nonatomic) IBOutlet UILabel *noJobs;
@property (weak, nonatomic) IBOutlet UILabel *shiftTime;
@property (weak, nonatomic) IBOutlet UITextView *noJobsTxtView;
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (assign, nonatomic) CGFloat labelSize;
@property (strong, nonatomic) NSString *textToDisplay;
@property (strong, nonatomic) NSMutableArray *datasource;
@property (strong, nonatomic) NSDictionary *tempDict;
@property (strong, nonatomic) NSArray *jobDetails;;
@property (strong, nonatomic) NSArray *vehicleList;
@property (strong, nonatomic) NSMutableArray *sizesArray;
@property (weak, nonatomic) IBOutlet UILabel *noJobsLbl;
@property (weak, nonatomic) IBOutlet UILabel *noShiftLbl;
@property (strong, nonatomic) NSString *driver_notes;
@property (assign, nonatomic) BOOL isHideKeyboard;
@end
