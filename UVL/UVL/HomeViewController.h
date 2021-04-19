//
//  HomeViewController.h
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UITableView *tblview;
@property (strong, nonatomic) NSMutableArray *datasource;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *noJobs;
@property (assign, nonatomic) BOOL nojobCheck;
@property (assign, nonatomic) BOOL refreshCheck;

-(void)updateJobs;
@end
