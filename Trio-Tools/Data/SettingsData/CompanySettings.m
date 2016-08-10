//
//  CompanySettings.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/19/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "CompanySettings.h"
#import "Field.h"
#import "Definitions.h"

#define READ_COMMAND_SIZE           2
#define COMPANY_SETTINGS_COMMAND_SIZE_1 14
#define COMPANY_SETTINGS_COMMAND_SIZE_2 15
#define COMPANY_SETTINGS_COMMAND_SIZE_FT900 19

@implementation CompanySettings

@synthesize tenacityGoalSteps;

@synthesize intensityGoalSteps;
@synthesize intensityGoalTime;
@synthesize intensityMinutesThreshold;
@synthesize intensityRestMinutesAllowed;
@synthesize intensityCycle;

@synthesize frequencyGoalSteps;
@synthesize frequencyCycleTime;
@synthesize frequencyCycle;
@synthesize frequencyCycleInterval;

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
        if([field.fieldname isEqualToString:@"Tenacity Steps:"])
        {
            self.tenacityGoalSteps =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Intensity Steps:"])
        {
            self.intensityGoalSteps =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Intensity time (min):"])
        {
            self.intensityGoalTime =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Intensity Threshold(steps/min):"])
        {
            self.intensityMinutesThreshold =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Intensity Rest Allowed (min):"])
        {
            self.intensityRestMinutesAllowed =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Frequency Steps:"])
        {
            self.frequencyGoalSteps =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Frequency Time (min):"])
        {
            self.frequencyCycleTime =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Frequency Time Interval(min):"])
        {
            self.frequencyCycleInterval =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Frequency Time Interval(hour):"])
        {
            self.frequencyCycleInterval =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Frequency Cycle:"])
        {
            self.frequencyCycle =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Intensity Cycle:"])
        {
            self.intensityCycle =(int) field.value;
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
        
        if(self.deviceInfo.model == 961 || self.deviceInfo.model == 939 || self.deviceInfo.model == 932 ||
           self.deviceInfo.model == 936 || self.deviceInfo.model == 661 || self.deviceInfo.model == 969 ||
           self.deviceInfo.model == 905 || self.deviceInfo.model == 962)
        {
            commandLen = COMPANY_SETTINGS_COMMAND_SIZE_1;
            if(self.deviceInfo.model == 961 || self.deviceInfo.model == 939 || self.deviceInfo.model == 661
               || self.deviceInfo.model == 969 || self.deviceInfo.model == 962 || self.deviceInfo.model == 905)
            {
                commandLen = COMPANY_SETTINGS_COMMAND_SIZE_2;
            }
            
            buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
            buffer[0] = 0x1B; //Command Signature
            buffer[1] = 0x1D; //command code
            buffer[2] = (self.tenacityGoalSteps >> 16) & 0xFF;
            buffer[3] = (self.tenacityGoalSteps >> 8) & 0xFF;
            buffer[4] = self.tenacityGoalSteps & 0xFF;
            buffer[5] = (self.intensityGoalSteps >> 8) & 0xFF;
            buffer[6] = self.intensityGoalSteps & 0xFF;
            buffer[7] = self.intensityGoalTime;
            buffer[8] = self.intensityMinutesThreshold;
            buffer[9] = self.intensityRestMinutesAllowed;
            buffer[10] = (self.frequencyGoalSteps >> 8) & 0xFF;
            buffer[11] = self.frequencyGoalSteps & 0xFF;
            buffer[12] = self.frequencyCycleTime;
            buffer[13] = self.frequencyCycleInterval | (self.frequencyCycle <<4);
            buffer[14] = self.intensityCycle;
        }
        else
        {
            commandLen = COMPANY_SETTINGS_COMMAND_SIZE_FT900;
            
            buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
            
            buffer[0] = 0x13; //Command Signature
            buffer[1] = 0x3A; //command code
            //buffer[2] = [NSUtilities getIntValue:param_data startIndex:4 length:2];
            //buffer[3] = [NSUtilities getIntValue:param_data startIndex:6 length:2];
            //buffer[4] = [NSUtilities getIntValue:param_data startIndex:8 length:2];
            //buffer[5] = [NSUtilities getIntValue:param_data startIndex:10 length:2];
            //buffer[6] = [NSUtilities getIntValue:param_data startIndex:12 length:2];
            //buffer[7] = [NSUtilities getIntValue:param_data startIndex:14 length:2];
            //buffer[8] = [NSUtilities getIntValue:param_data startIndex:16 length:2];
            //buffer[9] = [NSUtilities getIntValue:param_data startIndex:18 length:2];
            //buffer[10] = [NSUtilities getIntValue:param_data startIndex:20 length:2];
            //buffer[11] = [NSUtilities getIntValue:param_data startIndex:22 length:2];
            //buffer[12] = [NSUtilities getIntValue:param_data startIndex:24 length:2];
            //buffer[13] = [NSUtilities getIntValue:param_data startIndex:26 length:2];
            //buffer[14] = [NSUtilities getIntValue:param_data startIndex:28 length:2];
            //buffer[15] = [NSUtilities getIntValue:param_data startIndex:30 length:2];
            //buffer[16] = [NSUtilities getIntValue:param_data startIndex:32 length:2];
            //buffer[17] = [NSUtilities getIntValue:param_data startIndex:34 length:2];
            //buffer[18] = [NSUtilities getIntValue:param_data startIndex:36 length:2];
            //buffer[19] = [NSUtilities getIntValue:param_data startIndex:38 length:2];
        }
        
        NSLog(@"[0] %X",buffer[0]);
        NSLog(@"[1] %X",buffer[1]);
        NSLog(@"[2] %X",buffer[2]);
        NSLog(@"[3] %X",buffer[3]);
        NSLog(@"[4] %X",buffer[4]);
        NSLog(@"[5] %X",buffer[5]);
        NSLog(@"[6] %X",buffer[6]);
        NSLog(@"[7] %X",buffer[7]);
        NSLog(@"[8] %X",buffer[8]);
        NSLog(@"[9] %X",buffer[9]);
        NSLog(@"[10] %X",buffer[10]);
        NSLog(@"[11] %X",buffer[11]);
        NSLog(@"[12] %X",buffer[12]);
        NSLog(@"[13] %X",buffer[13]);
        NSLog(@"[14] %X",buffer[14]);
    }
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}

-(void)parseCompanySettingsRaw:(NSString*)rawData
{
    self.tenacityGoalSteps = [CompanySettings getIntValue:rawData startIndex:4 length:6];
    self.intensityGoalSteps = [CompanySettings getIntValue:rawData startIndex:10 length:4];
    self.intensityGoalTime = [CompanySettings getIntValue:rawData startIndex:14 length:2];
    self.intensityMinutesThreshold = [CompanySettings getIntValue:rawData startIndex:16 length:2];
    self.intensityRestMinutesAllowed = [CompanySettings getIntValue:rawData startIndex:18 length:2];
    self.frequencyGoalSteps = [CompanySettings getIntValue:rawData startIndex:20 length:4];
    self.frequencyCycleTime = [CompanySettings getIntValue:rawData startIndex:24 length:2];
    self.frequencyCycleInterval = [CompanySettings getIntValue:rawData startIndex:27 length:1];
    self.frequencyCycle = [CompanySettings getIntValue:rawData startIndex:26 length:1];
    

    if(self.deviceInfo.model == 961 || self.deviceInfo.model == 939)
    {
        if([rawData length] >=30)
        {
            self.intensityCycle = [CompanySettings getIntValue:rawData startIndex:28 length:2];
        }
    }
    else if(self.deviceInfo.model == FT969 || self.deviceInfo.model == FT905)
    {
        self.intensityCycle = [CompanySettings getIntValue:rawData startIndex:28 length:2];;
    }
    
    [self updateCommandFieds];
}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Tenacity Steps:"])
        {
            field.value = self.tenacityGoalSteps;
        }
        else if([field.fieldname isEqualToString:@"Intensity Steps:"])
        {
            field.value = self.intensityGoalSteps;
        }
        else if([field.fieldname isEqualToString:@"Intensity time (min):"])
        {
            field.value = self.intensityGoalTime;
        }
        else if([field.fieldname isEqualToString:@"Intensity Threshold(steps/min):"])
        {
            field.value = self.intensityMinutesThreshold;
        }
        else if([field.fieldname isEqualToString:@"Intensity Rest Allowed (min):"])
        {
            field.value = self.intensityRestMinutesAllowed;
        }
        else if([field.fieldname isEqualToString:@"Frequency Steps:"])
        {
            field.value = self.frequencyGoalSteps;
        }
        else if([field.fieldname isEqualToString:@"Frequency Time (min):"])
        {
            field.value = self.frequencyCycleTime;
        }
        else if([field.fieldname isEqualToString:@"Frequency Time Interval(hour):"])
        {
            field.value = self.frequencyCycleInterval;
        }
        else if([field.fieldname isEqualToString:@"Frequency Time Interval(min):"])
        {
            field.value = self.frequencyCycleInterval;
        }
        else if([field.fieldname isEqualToString:@"Frequency Cycle:"])
        {
            field.value = self.frequencyCycle;
        }
        else if([field.fieldname isEqualToString:@"Intensity Cycle:"])
        {
            field.value = self.intensityCycle;
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
