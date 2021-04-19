//
//  CustomIconNav.m
//  UVL
//
//  Created by Osama on 17/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "CustomIconNav.h"

@implementation CustomIconNav
-(id)initWithTitle:(NSString *)title {
    if((self = [super initWithTitle:title])){
        NSLog(@"initWithTitle");
        //initializer code
        UIImageView *navigationImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 25)];
        navigationImage.image=[UIImage imageNamed:@"UVL-logo-header.png"];
        
        UIImageView *workaroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 25)];
        [workaroundImageView addSubview:navigationImage];
        self.titleView=workaroundImageView;

    }
    return self;
}
@end
