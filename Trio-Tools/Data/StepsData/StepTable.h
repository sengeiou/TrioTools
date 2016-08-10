//
//  StepTable.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/24/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StepTable : NSObject

@property(assign)int tableYear;
@property(assign)int tableMonth;
@property(assign)int tableDay;

@property(assign)int tableCurrentHour;
@property(assign)int tableHourFlag;

@property(strong, nonatomic)NSMutableArray * tableSentHourFlag;
@property(assign)int tableSignatureFlag;



@property(assign)int tableTotalHoursFlagged;

@property(assign)int tableFlag;


@end
