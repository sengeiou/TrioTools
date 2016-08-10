//
//  StepDataPerMinute.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/25/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StepDataPerMinute : NSObject


@property(strong, nonatomic) NSString *minutesRaw;
@property(assign) int minuteNumber;
@property(assign) int steps;
@property(assign) int calories;
@property(assign) float distance;


-(id)init;

@end
