//
//  ExerciseSettings.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/19/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "ExerciseSettings.h"
#import "Field.h"
#import "Definitions.h"

#define READ_COMMAND_SIZE           2
#define EXERCISE_SETTINGS_COMMAND_SIZE_2 4
#define EXERCISE_SETTINGS_COMMAND_SIZE_1 3

#define DATA_SYNC_OFF_35 0x01
#define FREQUENCY_ALARM_OFF_35 0x02
#define MULTIPLE_INTENSITY_OFF_35 0x04

#define DATA_SYNC_OFF_34 0x10
#define FREQUENCY_ALARM_OFF_34 0x20
#define MULTIPLE_INTENSITY_OFF_34 0x40

@implementation ExerciseSettings

@synthesize syncTimeInterval;
@synthesize autoSyncSettings;
@synthesize frequencyAlarmSettings;
@synthesize multipleIntensitySettings;

@synthesize commandAction;
@synthesize commandPrefix;
@synthesize writeCommandID;
@synthesize readCommandID;

@synthesize deviceInfo;
@synthesize commandFields;

@synthesize expectedResponseSize;

-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action
{
    self = [super init];
    if(self)
    {
        self.commandAction = action;
        self.deviceInfo = devInfo;
        self.commandFields = cmdFields;
        [self initializeFields];
    }
    return self;
}


-(void)initializeFields
{
    self.commandPrefix = self.commandFields.commandPrefix;
    self.writeCommandID = self.commandFields.writeCommandID;
    self.readCommandID = self.commandFields.readCommandID;
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Sync Time Interval (min):"])
        {
            self.syncTimeInterval = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Auto Sync:"])
        {
            self.autoSyncSettings = !field.value;
        }
        else if([field.fieldname isEqualToString:@"Frequency Alarm:"])
        {
            self.frequencyAlarmSettings = !field.value;
        }
        else if([field.fieldname isEqualToString:@"Multiple Intensity:"])
        {
            self.multipleIntensitySettings = !field.value;
        }
    }
}

-(NSData*)getCommands
{
    int commandLen = 0;
    unsigned char * buffer = nil;
    
    unsigned char flag = 0x00;
    if(self.commandAction==0)
    {
        commandLen = READ_COMMAND_SIZE;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.readCommandID;
    }
    else
    {
        if(self.deviceInfo.model == PE932)
        {
            if(self.deviceInfo.firmwareVersion > 3.4f)
            {
                commandLen = EXERCISE_SETTINGS_COMMAND_SIZE_2;
                //rawData.exerciseSyncTimeInterval = 3;
                flag |= self.autoSyncSettings ? DATA_SYNC_OFF_35:0x00;
                flag |= self.frequencyAlarmSettings ? FREQUENCY_ALARM_OFF_35:0x00;
                flag |= self.multipleIntensitySettings ? MULTIPLE_INTENSITY_OFF_35:0x00;
            }
            else
            {
                commandLen = EXERCISE_SETTINGS_COMMAND_SIZE_1;
                // if FW ver <= 3.4 and exercise sync time interval is greater than 15
                // then exercise sync time interval should be set to 1hr as default.
                self.syncTimeInterval = self.syncTimeInterval>15?1:self.syncTimeInterval;
                flag |= self.syncTimeInterval;
                flag |= self.autoSyncSettings ? DATA_SYNC_OFF_34:0x00;
                flag |= self.frequencyAlarmSettings ? DATA_SYNC_OFF_34:0x00;
                flag |= self.multipleIntensitySettings ? MULTIPLE_INTENSITY_OFF_34:0x00;
            }
        }
        else if(self.deviceInfo.model == FT900)
        {
            
        }
        else
        {
            commandLen = EXERCISE_SETTINGS_COMMAND_SIZE_2;
            //rawData.exerciseSyncTimeInterval = 3;
            flag |= self.autoSyncSettings ? DATA_SYNC_OFF_35:0x00;
            flag |= self.frequencyAlarmSettings ? FREQUENCY_ALARM_OFF_35:0x00;
            flag |= self.multipleIntensitySettings ? MULTIPLE_INTENSITY_OFF_35:0x00;
        }
        
        buffer =(unsigned char*) calloc(commandLen,sizeof(unsigned char));
        
        if(self.deviceInfo.model == 900)
        {
            buffer[0] = 0x03; //Command size
        }
        else
        {
            buffer[0] = 0x1B; //Command Signature
        }

        buffer[1] = 0x1A; //command code
        
        if(commandLen==EXERCISE_SETTINGS_COMMAND_SIZE_2)
        {
            // if FW ver > 3.4 and exercise sync time interval is less than 5
            // then exercise sync time interval should be set to 60 mins as default.
            self.syncTimeInterval = self.syncTimeInterval<5?60:self.syncTimeInterval;
            buffer[2] = self.syncTimeInterval;
            buffer[3] = flag;
        }
        else
        {
            buffer[2] = flag;
        }
    }
    NSLog(@"[2] %.2X",buffer[2]);
    NSLog(@"[3] %.2X",buffer[3]);
    NSLog(@"[4] %.2X",buffer[4]);
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}

-(void)parseExerciseSettingsRaw:(NSString*)rawData
{
    int synctime =0;
    int syncEnableDisable=0;
    int frequencyAlarmEnableDisable=0;
    int multipleIntensity = 0;
    if ([rawData length] > 6)
    {
        synctime = [ExerciseSettings getIntValue:rawData startIndex:4 length:2];
        syncEnableDisable = [ExerciseSettings getIntValue:rawData startIndex:7 length:1] & 0x01;
        frequencyAlarmEnableDisable = [ExerciseSettings getIntValue:rawData startIndex:7 length:1]>>1 & 0x01;
        multipleIntensity = [ExerciseSettings getIntValue:rawData startIndex:7 length:1]>>2 & 0x01;
    }
    else
    {
        synctime = [ExerciseSettings getIntValue:rawData startIndex:5 length:1];
        syncEnableDisable = [ExerciseSettings getIntValue:rawData startIndex:4 length:1] & 0x01;
        frequencyAlarmEnableDisable = [ExerciseSettings getIntValue:rawData startIndex:4 length:1]>>1 & 0x01;
    }
    [self setSyncTimeInterval:synctime];
    [self setAutoSyncSettings:syncEnableDisable];
    [self setFrequencyAlarmSettings:frequencyAlarmEnableDisable];
    [self setMultipleIntensitySettings:multipleIntensity];
    [self updateCommandFieds];
}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Sync Time Interval (min):"])
        {
            field.value = self.syncTimeInterval;
        }
        else if([field.fieldname isEqualToString:@"Auto Sync:"])
        {
            field.value = !self.autoSyncSettings;
        }
        else if([field.fieldname isEqualToString:@"Frequency Alarm:"])
        {
            field.value = !self.frequencyAlarmSettings;
        }
        else if([field.fieldname isEqualToString:@"Multiple Intensity:"])
        {
            field.value = !self.multipleIntensitySettings;
        }
    }
}

+(int) getIntValue:(NSString *) data startIndex:(int) startIndex length:(int) length
{
    unsigned int value;
    
    NSScanner *toDecimal = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(startIndex, length)]];
    [toDecimal scanHexInt:&value];
    return value;
}

@end
