//
//  DefectViewController.h
//  UVL
//
//  Created by cellzone on 1/27/21.
//  Copyright © 2021 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QBImagePickerController/QBImagePickerController.h>
NS_ASSUME_NONNULL_BEGIN

@interface DefectViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIView *defectView;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UILabel *imageLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tblViewHeight;
@property (weak, nonatomic) IBOutlet UIView *tyreView;

@property (weak, nonatomic) IBOutlet UITableView *tyreTblView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tyreViewHeight;

@property  UILabel *lbl; 
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;


@property NSMutableArray* tyreArray1;
@property NSMutableArray* tyreArray2;
@property NSMutableArray* tyreArray3;
@property NSMutableArray *tyresData;
@property NSMutableArray *defectChecksArray;

 @property (nonatomic) BOOL isApiCreat;
@property (nonatomic) BOOL  isTyreSelect;

@property NSIndexPath* indexPathRow;

@property NSString *Tyre1;
@property NSString *Tyre2;
@property NSString *Tyre3;
@property NSString *Tyre4;
@property NSString *Tyre5;
@property NSString *Tyre6;
@property NSString *Tyre7;
@property NSString *Tyre8;
@property  UIImage *chosenImage;



@end

NS_ASSUME_NONNULL_END
