//
//  SensitivitySettings.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/24/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "SensitivitySettings.h"
#import "Field.h"
#import "Definitions.h"

#define READ_COMMAND_SIZE           2
#define WRITE_SENSITIVITY_COMMAND_LEN 6

@implementation SensitivitySettings

@synthesize sensitivityLevel;
@synthesize sensitivityThreshold;
@synthesize sleepThreshold;

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
        if([field.fieldname isEqualToString:@"Relative Limit:"])
        {
            self.sensitivityLevel =(int) field.value;
            
        }
        else if([field.fieldname isEqualToString:@"Sensitivity Threshold:"])
        {
            self.sensitivityThreshold =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Sleep Threshold:"])
        {
            self.sleepThreshold =(int) field.value;
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
        commandLen = WRITE_SENSITIVITY_COMMAND_LEN;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.writeCommandID;
        buffer[2] = self.sensitivityLevel;
        buffer[3] = (self.sensitivityThreshold >> 8) & 0xFF;
        buffer[4] = self.sensitivityThreshold & 0xff;
        buffer[5] = self.sleepThreshold;
    }
    NSLog(@"[0] %.2X",buffer[0]);
    NSLog(@"[1] %.2X",buffer[1]);
    NSLog(@"[2] %.2X",buffer[2]);
    NSLog(@"[3] %.2X",buffer[3]);
    NSLog(@"[4] %.2X",buffer[4]);
    NSLog(@"[5] %.2X",buffer[5]);
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}

-(void)parseSensitivitySettingsRaw:(NSString*)rawData
{
    self.sensitivityLevel = [SensitivitySettings getIntValue:rawData startIndex:4 length:2];
    self.sensitivityThreshold = [SensitivitySettings getIntValue:rawData startIndex:6 length:4];
    self.sleepThreshold = [SensitivitySettings getIntValue:rawData startIndex:10 length:2];
    
    [self updateCommandFieds];
}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Relative Limit:"])
        {
            field.value = self.sensitivityLevel;
        }
        else if([field.fieldname isEqualToString:@"Relative Sensitivity:"])
        {
            field.value = self.sensitivityThreshold;
        }
        else if([field.fieldname isEqualToString:@"Sleep Threshold:"])
        {
            field.value = self.sleepThreshold;
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
