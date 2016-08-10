//
//  CompanySettings.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/19/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

@interface CompanySettings : NSObject

@property(assign)int tenacityGoalSteps;

@property(assign)int intensityGoalSteps;
@property(assign)int intensityGoalTime;
@property(assign)int intensityMinutesThreshold;
@property(assign)int intensityRestMinutesAllowed;
@property(assign)int intensityCycle;

@property(assign)int frequencyGoalSteps;
@property(assign)int frequencyCycleTime;
@property(assign)int frequencyCycle;
@property(assign)int frequencyCycleInterval;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;

-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;
-(void)parseCompanySettingsRaw:(NSString*)rawData;

@end
