//
//  StepData.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/25/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

#import "StepDataDaily.h"
#import "StepDataHourly.h"
#import "StepDataPerMinute.h"

#import "StepTable.h"

@interface StepData : NSObject


@property (strong, nonatomic)StepDataDaily *stepsData;


//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;

-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;

-(void)parseStepsData:(NSString*)rawData;

-(void)parseFT900StepsData:(NSString*)rawData tableInfo:(StepTable*)tableData;
@end
