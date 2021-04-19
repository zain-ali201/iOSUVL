//
//  UVLAppglobals.h
//  UVL
//
//  Created by Osama on 25/10/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface UVLAppglobals : NSObject
+ (UVLAppglobals *)sharedAppGlobals;
- (void)loadLoginStoryboard;
- (void)loadDashboard;
@property (strong, nonatomic) UIImage *signatureImage;
@property (copy, nonatomic)   NSString *shiftId;
@property (nonatomic) BOOL    isON;
@property (nonatomic) BOOL    isClockedIn;
@property (nonatomic) BOOL isOnBreakRequest;
@property (nonatomic) BOOL homeRefreshCall;
@property (nonatomic) BOOL shiftRefreshCall;
@property (nonatomic) int justGoneForBreak;
@property (nonatomic) int swictchToChange;
@property (strong, nonatomic) NSString *currentDriverLocation;
@property (assign, nonatomic) int notficationsCountTobeAp;
@end
