//
//  EEPROMCommand.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/26/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "EEPROMCommand.h"
#import "Field.h"
#import "Definitions.h"

#define EEPROM_COMMAND_SIZE 3

@implementation EEPROMCommand

@synthesize setDefault;
@synthesize clearEE;
@synthesize clearProfile;
@synthesize clearMessaging;
@synthesize clearTallies;
@synthesize cleearFwUpdateFlag;

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
        if([field.fieldname isEqualToString:@"Clear Steps:"])
        {
            self.clearEE = field.value;
        }
        else if([field.fieldname isEqualToString:@"Set Default:"])
        {
            self.setDefault = field.value;
        }
        else if([field.fieldname isEqualToString:@"Clear Profile:"])
        {
            self.clearProfile = field.value;
        }
        else if([field.fieldname isEqualToString:@"Clear Messaging:"])
        {
            self.clearMessaging = field.value;
        }
        else if([field.fieldname isEqualToString:@"Clear Tallies n Charge History:"])
        {
            self.clearTallies = field.value;
        }
        else if([field.fieldname isEqualToString:@"Clear FW Update Flag:"])
        {
            self.cleearFwUpdateFlag = field.value;
        }
    }
}

-(NSData*)getCommands
{
    int commandLen = 0;
    unsigned char * buffer = nil;
    
    commandLen = EEPROM_COMMAND_SIZE;
    buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
    buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
    buffer[1] = self.readCommandID;
    
    int eepromData = 0x00;
    eepromData |= self.clearEE?0x01:0x00;
    eepromData |= self.setDefault?0x02:0x00;
    eepromData |= self.clearProfile?0x04:0x00;
    eepromData |= self.clearMessaging?0x08:0x00;
    eepromData |= self.clearTallies?0x10:00;
    eepromData |= self.cleearFwUpdateFlag?0x20:00;

    buffer[2] = eepromData;

    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}

@end
