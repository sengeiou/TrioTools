//
//  StepTable.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/24/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "StepTable.h"

@implementation StepTable

@synthesize tableYear;
@synthesize tableMonth;
@synthesize tableDay;

@synthesize tableCurrentHour;
@synthesize tableHourFlag;

@synthesize tableSentHourFlag;
@synthesize tableSignatureFlag;


@synthesize tableTotalHoursFlagged;

@synthesize tableFlag;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.tableSentHourFlag = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
