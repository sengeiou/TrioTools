//
//  StepDataDaily.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/26/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "StepDataDaily.h"

@implementation StepDataDaily

@synthesize dailyRaw;

@synthesize yearNumber;
@synthesize monthNumber;
@synthesize dayNumber;
@synthesize hourlyData;
@synthesize frequencyUsed;

@synthesize totalSteps;
@synthesize totalKcal;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.hourlyData = [[NSMutableArray alloc] init];
        self.yearNumber = [[NSString alloc] init];
        self.monthNumber = [[NSString alloc] init];
        self.dayNumber = [[NSString alloc] init];
        self.dailyRaw = [[NSMutableString alloc] init];
    }
    return self;
}

@end
