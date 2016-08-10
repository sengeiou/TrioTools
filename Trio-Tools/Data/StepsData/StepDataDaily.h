//
//  StepDataDaily.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/26/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StepDataDaily : NSObject

@property(strong, nonatomic) NSMutableString *dailyRaw;

@property(strong, nonatomic) NSString *yearNumber;
@property(strong, nonatomic) NSString *monthNumber;
@property(strong, nonatomic) NSString *dayNumber;
@property(strong,nonatomic) NSMutableArray *hourlyData;
@property(assign)int frequencyUsed;

@property(assign)int totalSteps;
@property(assign)int totalKcal;

-(id)init;

@end
