//
//  ProfileSettings.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/27/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "ProfileSettings.h"
#import "Field.h"
#import "Definitions.h"

#define READ_COMMAND_SIZE               2
#define PROFILE_COMMAND_SIZE            14

@implementation ProfileSettings

@synthesize samplingTime;
@synthesize samplingBuffer;
@synthesize samplingFrequency;
@synthesize samplingThreshold;
@synthesize samplingRecordingPerDay;
@synthesize samplingMinutesThreshold;
@synthesize samplingInterval;
@synthesize samplingTotalBlocks;

@synthesize commandAction;
@synthesize commandPrefix;
@synthesize writeCommandID;
@synthesize readCommandID;

@synthesize deviceInfo;
@synthesize commandFields;

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
        if([field.fieldname isEqualToString:@"Sampling Time:"])
        {
            self.samplingTime =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Sampling Buffer:"])
        {
            self.samplingBuffer =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Sampling Frequency:"])
        {
            self.samplingFrequency =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Sampling Threshold:"])
        {
            self.samplingThreshold =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Sampling Recording per Day::"])
        {
            self.samplingRecordingPerDay =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Sampling Minutes Threshold:"])
        {
            self.samplingMinutesThreshold =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Sampling Interval:"])
        {
            self.samplingInterval =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Max Steps in Frame:"])
        {
            self.maxStepsInFrame =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Max Time in Frame:"])
        {
            self.totalTimeInFrame =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Sampling Total Blocks:"])
        {
            self.samplingTotalBlocks =(int) field.value;
        }
    }
}


-(NSData*)getCommands
{
    int commandLen = 0;
    unsigned char * buffer = nil;
    if(self.commandAction==0)
    {
        commandLen = READ_COMMAND_SIZE;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.readCommandID;
    }
    else
    {
        commandLen = PROFILE_COMMAND_SIZE;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.writeCommandID;
        buffer[2] = (self.samplingTime >> 8) & 0xFF;
        buffer[3] = self.samplingTime & 0xFF;
        buffer[4] = self.samplingBuffer;
        buffer[5] = self.samplingFrequency;
        buffer[6] = self.samplingThreshold;
        buffer[7] = self.samplingRecordingPerDay;
        buffer[8] = self.samplingMinutesThreshold;
        buffer[9] = (self.samplingInterval >> 8 ) & 0xFF;
        buffer[10] = self.samplingInterval & 0xFF;
        buffer[11] = self.maxStepsInFrame;
        buffer[12] = self.totalTimeInFrame;
        buffer[13] = self.samplingTotalBlocks;
    }
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}
-(void)parseProfileSettingsRaw:(NSString*)rawData
{
    self.samplingTime = [ProfileSettings getIntValue:rawData startIndex:4 length:4];
    self.samplingBuffer = [ProfileSettings getIntValue:rawData startIndex:8 length:2];
    self.samplingFrequency = [ProfileSettings getIntValue:rawData startIndex:10 length:2];
    self.samplingThreshold = [ProfileSettings getIntValue:rawData startIndex:12 length:2];
    self.samplingRecordingPerDay = [ProfileSettings getIntValue:rawData startIndex:14 length:2];
    self.samplingMinutesThreshold = [ProfileSettings getIntValue:rawData startIndex:16 length:2];
    self.samplingInterval = [ProfileSettings getIntValue:rawData startIndex:18 length:4];
    
    if([rawData length] > 20)
    {
        self.maxStepsInFrame = [ProfileSettings getIntValue:rawData startIndex:22 length:2];
        self.totalTimeInFrame = [ProfileSettings getIntValue:rawData startIndex:24 length:2];
        self.samplingTotalBlocks = [ProfileSettings getIntValue:rawData startIndex:26 length:2];
    }
    [self updateCommandFieds];
}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Sampling Time:"])
        {
            field.value = self.samplingTime;
        }
        else if([field.fieldname isEqualToString:@"Sampling Buffer:"])
        {
            field.value = self.samplingBuffer;
        }
        else if([field.fieldname isEqualToString:@"Sampling Frequency:"])
        {
            field.value = self.samplingFrequency;
        }
        else if([field.fieldname isEqualToString:@"Sampling Threshold:"])
        {
            field.value = self.samplingThreshold;
        }
        else if([field.fieldname isEqualToString:@"Sampling Recording per Day::"])
        {
            field.value = self.samplingRecordingPerDay;
        }
        else if([field.fieldname isEqualToString:@"Sampling Minutes Threshold:"])
        {
            field.value = self.samplingMinutesThreshold;
        }
        else if([field.fieldname isEqualToString:@"Sampling Interval:"])
        {
            field.value = self.samplingInterval;
        }
        else if([field.fieldname isEqualToString:@"Max Steps in Frame:"])
        {
            field.value = self.maxStepsInFrame;
        }
        else if([field.fieldname isEqualToString:@"Max Time in Frame:"])
        {
            field.value = self.totalTimeInFrame;
        }
        else if([field.fieldname isEqualToString:@"Sampling Total Blocks:"])
        {
            field.value = self.samplingTotalBlocks;
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
