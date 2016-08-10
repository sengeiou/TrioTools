//
//  ProfileSettings.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/27/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

@interface ProfileSettings : NSObject

@property(assign)int samplingTime;
@property(assign)int samplingBuffer;
@property(assign)int samplingFrequency;
@property(assign)int samplingThreshold;
@property(assign)int samplingRecordingPerDay;
@property(assign)int samplingMinutesThreshold;
@property(assign)int samplingInterval;
@property(assign)int maxStepsInFrame;
@property(assign)int totalTimeInFrame;
@property(assign)int samplingTotalBlocks;


//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;

-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;
-(void)parseProfileSettingsRaw:(NSString*)rawData;

@end
