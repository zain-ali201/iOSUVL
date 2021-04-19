//
//  Utils.m
//  UVL
//
//  Created by Osama on 01/11/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "Utils.h"

@implementation Utils
+(NSString*)getTodayDateWithoutTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *dateString=[dateFormatter stringFromDate:[NSDate date]];
    return dateString;
}

+(UIColor*)getColorForStatus:(int)statusCode{
    return [UIColor colorWithRed:232.0/255.0f green:232.0/255.0f blue:232.0/255.0f alpha:1.0f];
}

+ (void)moveViewPosition:(CGFloat)yPostition onView:(UIView *)view completion:(Completion) completion;
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [view setFrame:CGRectMake(view.frame.origin.x, yPostition, view.frame.size.width, view.frame.size.height)];
    [UIView commitAnimations];
    completion(YES);
    
}

+(BOOL)isBehindtheCurrDate:(NSString *)validTill{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSLocale *gbLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    [dateFormatter setLocale:gbLocale];
    NSDate *yourDate = [dateFormatter dateFromString:validTill];

    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/London"]];
     formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *resultString = [formatter stringFromDate: now];
    NSDate *NowNew = [dateFormatter dateFromString:resultString];
    NSLog(@"time %@",resultString);
    NSComparisonResult result = [NowNew compare:yourDate];
    if(result==NSOrderedAscending){
        //  NSLog(@"Date1 is in the future");
        return YES;
    }
    else if(result==NSOrderedDescending){
        return NO;
    }
    else{
        return NO;
    }
    return  NO;
}

+(NSString *)jobStartHour:(NSString *)dateS{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSLocale *gbLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    [dateFormatter setLocale:gbLocale];
    NSDate *yourDate = [dateFormatter dateFromString:dateS];
    
    [dateFormatter setDateFormat:@"hh:mm a"];
    return [dateFormatter stringFromDate: yourDate];
}
+(BOOL)hasCachedImage:(UIImage *)image{
    CGImageRef cgref = [image CGImage];
    CIImage *cim = [image CIImage];
    if (cim == nil && cgref == NULL)
    {
        NSLog(@"no underlying data");
        return NO;
    }
    else{
        return YES;
    }
}
@end
