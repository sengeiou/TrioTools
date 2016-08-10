//
//  DeviceSettings.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/19/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

@interface DeviceSettings : NSObject

@property(assign)int  deviceTimeHour;
@property(assign)int  deviceTimeMinutes;
@property(assign)int  deviceTimeSeconds;
@property(assign)BOOL deviceTimeAmPm;

@property(assign)int  deviceYear;
@property(assign)int  deviceMonth;
@property(assign)int  deviceDay;

@property(assign)BOOL shouldAddTimeOffset;
@property(assign)BOOL dstApplicable;
@property(assign)int  hourOffSet;
@property(assign)int  minuteOffSet;

@property(assign)BOOL dstOffsetType;

@property(assign)BOOL  dstStarted;
@property(assign)int  dstStartMonth;
@property(assign)int  dstStartDay;
@property(assign)int  dstStartHour;

@property(assign)BOOL dstEnded;
@property(assign)int dstEndMonth;
@property(assign)int dstEndDay;
@property(assign)int dstEndHour;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;

-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;
-(void)parseDeviceSettingsRaw:(NSString*)rawData;

@end
