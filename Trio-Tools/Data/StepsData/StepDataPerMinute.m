//
//  StepDataPerMinute.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/25/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "StepDataPerMinute.h"

@implementation StepDataPerMinute

@synthesize minutesRaw;
@synthesize minuteNumber;
@synthesize steps;
@synthesize calories;
@synthesize distance;


-(id)init
{
    self = [super init];
    if(self)
    {
        self.minutesRaw = [[NSString alloc] init];
        
    }
    return self;
}


@end
