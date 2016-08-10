//
//  DeviceModeCommand.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/27/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "DeviceModeCommand.h"
#import "Field.h"
#import "Definitions.h"

#define DEVICE_MODE_COMMAND_SIZE 3
#define READ_COMMAND_SIZE        2

@implementation DeviceModeCommand

@synthesize bootUpFlag;
@synthesize deviceMode;

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
        if([field.fieldname isEqualToString:@"Boot Up Flag:"])
        {
            self.bootUpFlag = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Device Mode:"])
        {
            self.deviceMode = (int) field.value;
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
        commandLen = DEVICE_MODE_COMMAND_SIZE;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.writeCommandID;
        
        int deviceModeByte = 0x00;
        int bootUpBit = self.bootUpFlag;
        
        deviceModeByte |=  (bootUpBit << 7);
        deviceModeByte |= self.deviceMode;
        
        buffer[2] = deviceModeByte;
    }
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}

-(void)parseDeviceModeRaw:(NSString*)rawData
{
    self.bootUpFlag =[DeviceModeCommand getIntValue:rawData startIndex:4 length:2] >> 7 & 0x01;
    self.deviceMode = [DeviceModeCommand getIntValue:rawData startIndex:4 length:2] & 0x7F;

    [self updateCommandFieds];
}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Boot Up Flag:"])
        {
            field.value = self.bootUpFlag;
        }
        else if([field.fieldname isEqualToString:@"Device Mode:"])
        {
            field.value = self.deviceMode;
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
