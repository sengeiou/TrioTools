//
//  AlarmCommand.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/8/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "AlarmCommandData.h"
#import "Field.h"
#import "Definitions.h"

#define READ_COMMAND_SIZE           2
#define ALARM_COMMAND_SIZE          4

@implementation AlarmCommandData

@synthesize alarmDuration;
@synthesize beepType;

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
        if([field.fieldname isEqualToString:@"Alarm Duration(ms):"])
        {
            self.alarmDuration = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Beep Type:"])
        {
            self.beepType = field.value;
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
        commandLen = ALARM_COMMAND_SIZE;
        if(self.deviceInfo.model == PE961 && self.deviceInfo.firmwareVersion <= 4.3f)
        {
            
        }
        else if(self.deviceInfo.model == PE961 && self.deviceInfo.firmwareVersion >= 5.0f)
        {
            buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
            buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
            buffer[1] = self.writeCommandID;
            buffer[2] = self.alarmDuration;
            buffer[3] = self.beepType;
        }
        else
        {
            
            buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
            buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
            buffer[1] = self.writeCommandID;
            buffer[2] = self.alarmDuration;
            buffer[3] = self.beepType;
        }
    }
    NSLog(@"[2] %.2X",buffer[2]);
    NSLog(@"[3] %.2X",buffer[3]);
    NSLog(@"[4] %.2X",buffer[4]);
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}

-(void)parseAlarmDataRaw:(NSString*)rawData
{
    self.alarmDuration = [AlarmCommandData getIntValue:rawData startIndex:4 length:2];
    self.beepType =[AlarmCommandData getIntValue:rawData startIndex:6 length:2];

    [self updateCommandFieds];
}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Alarm Duration(ms):"])
        {
            field.value = self.alarmDuration;
        }
        else if([field.fieldname isEqualToString:@"Beep Type:"])
        {
            field.value = self.beepType;
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
