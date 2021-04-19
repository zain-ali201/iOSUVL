//
//  DailyDefectCheck.m
//  UVL
//
//  Created by cellzone on 2/28/21.
//  Copyright © 2021 TxLabz. All rights reserved.
//

#import "DailyDefectCheck.h"

@implementation DailyDefectCheck

-(id)initWithDailyDefect:(NSDictionary*)DailyDefectData
{
    if (self = [super init])
    {

        self.defectKey = DailyDefectData[@"defect_key"];
        self.defectName = DailyDefectData[@"defect_name"];
        
    }
    return self;
    
}

@end
