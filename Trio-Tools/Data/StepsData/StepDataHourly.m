//
//  StepDataHourly.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/25/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "StepDataHourly.h"

@implementation StepDataHourly

@synthesize hourlyRaw;
@synthesize hourNumber;
@synthesize minuteData;
@synthesize totalHourlySteps;
@synthesize totalHourlyCal;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.minuteData = [[NSMutableArray alloc] init];
        self.hourNumber = [[NSString alloc] init];
        self.hourlyRaw = [[NSString alloc] init];

    }
    return self;
}

@end
