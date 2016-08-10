//
//  ExerciseSettings.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/19/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

@interface ExerciseSettings : NSObject

@property(assign)int  syncTimeInterval;
@property(assign)BOOL autoSyncSettings;
@property(assign)BOOL frequencyAlarmSettings;
@property(assign)BOOL multipleIntensitySettings;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (assign)int expectedResponseSize;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;


-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;
-(void)parseExerciseSettingsRaw:(NSString*)rawData;

@end
