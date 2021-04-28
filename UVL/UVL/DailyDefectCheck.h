//
//  DailyDefectCheck.h
//  UVL
//
//  Created by cellzone on 2/28/21.
//  Copyright © 2021 TxLabz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DailyDefectCheck : NSObject


-(id)initWithDailyDefect:(NSDictionary*)DailyDefectData;
@property (strong, nonatomic) NSString *defectKey;
@property (strong, nonatomic) NSString *defectName;
@property (strong, nonatomic) NSString *defectValue;

@end

NS_ASSUME_NONNULL_END
