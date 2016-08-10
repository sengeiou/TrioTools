//
//  MessageSchedule.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/18/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

#define MESSAGE_SCHEDULE_COMMAND_SIZE 19

@interface MessageSchedule : NSObject

@property(assign)int scheduleID;
@property(assign)int displayTriggerType;
@property(assign)int displayType;
@property(assign)int skipButtonNumber;
@property(assign)int sensor1;
@property(assign)int sensor2;
@property(assign)int sensor3;
@property(assign)int schedYear;
@property(assign)int schedMonth;
@property(assign)int schedDay;
@property(assign)int startTimeHour;
@property(assign)int endTimeHour;
@property(assign)int intervalType;
@property(assign)int intervalValue;
@property(assign)int numberOfOccurences;
@property(assign)int visibilityTime;
@property(assign)int scheduleIconType;
@property(assign)int saveUserResponse;
@property(assign)int vibrationSetting;
@property(assign)int messageImageSlotNumber1;
@property(assign)int messageImageSlotNumber2;
@property(assign)int messageImageSlotNumber3;
@property(assign)int messageImageSlotNumber4;
@property(assign)int messageImageSlotNumber5;
@property(assign)int messageImageSlotNumber6;

@property(assign)int dataTypeOrAnswer1;
@property(assign)int dataTypeOrAnswer2;
@property(assign)int dataTypeOrAnswer3;
@property(assign)int dataTypeOrAnswer4;
@property(assign)int dataTypeOrAnswer5;
@property(assign)int dataTypeOrAnswer6;


//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;


-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(void)parseMesageScheduleDataRaw:(NSString*)rawData;

-(NSData*)getCommands;

@end
