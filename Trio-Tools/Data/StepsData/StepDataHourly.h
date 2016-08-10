//
//  StepDataHourly.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/25/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StepDataHourly : NSObject

@property(strong, nonatomic) NSString *hourlyRaw;
@property(strong, nonatomic) NSString *hourNumber;
@property(strong, nonatomic) NSArray *minuteData;
@property(assign)int totalHourlySteps;
@property(assign)int totalHourlyCal;


-(id)init;

@end
