//
//  Utils.h
//  UVL
//
//  Created by Osama on 01/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void(^Completion)(BOOL finished);
@interface Utils : NSObject
+(NSString*)getTodayDateWithoutTime;
+(UIColor *)getColorForStatus:(int)statusCode;
+(BOOL)isBehindtheCurrDate:(NSString *)validTill;
+(NSString *)jobStartHour:(NSString *)dateS;
+(BOOL)hasCachedImage:(UIImage *)image;
+ (void)moveViewPosition:(CGFloat)yPostition onView:(UIView *)view completion:(Completion) completion;
@end
