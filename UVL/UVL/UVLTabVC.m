//
//  UVLTabVC.m
//  UVL
//
//  Created by Osama on 06/05/2017.
//  Copyright © 2017 TxLabz. All rights reserved.
//

#import "UVLTabVC.h"

@interface UVLTabVC ()

@end

@implementation UVLTabVC

- (void)viewDidLoad {
    [super viewDidLoad];
    for(UINavigationController * viewController in self.viewControllers){
        [[viewController.viewControllers firstObject] view];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
