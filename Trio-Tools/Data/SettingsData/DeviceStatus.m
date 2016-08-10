//
//  DeviceStatus.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/15/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import "DeviceStatus.h"
#import "Field.h"
#import "Definitions.h"

@implementation DeviceStatus

@synthesize intensityGoalStatus;
@synthesize frequencyGoalStatus;
@synthesize tenacityGoalStatus;
@synthesize pairingStatus;

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
        if([field.fieldname isEqualToString:@"Intensity Goal Achieve:"])
        {
            self.intensityGoalStatus = field.value;
        }
        else if([field.fieldname isEqualToString:@"Frequency Goal Achieve:"])
        {
            self.frequencyGoalStatus = field.value;
        }
        else if([field.fieldname isEqualToString:@"Tenacity Goal Achieve:"])
        {
            self.tenacityGoalStatus = field.value;
        }
        else if([field.fieldname isEqualToString:@"Pairing Status:"])
        {
            self.pairingStatus = (int) field.value;
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
        commandLen = DEVICE_STATUS_COMMAND_SIZE;
        
        
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.writeCommandID;
        buffer[2] = self.pairingStatus;
    }
    NSLog(@"[0] %.2X",buffer[0]);
    NSLog(@"[1] %.2X",buffer[1]);
    NSLog(@"[2] %.2X",buffer[2]);
    
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}


-(void)parseDeviceStatusRaw:(NSString*)rawData
{
    int deviceStatus = [DeviceStatus getIntValue:rawData startIndex:4 length:2];
    
    self.intensityGoalStatus = (deviceStatus > 7) & 0x01;
    self.frequencyGoalStatus = (deviceStatus > 6) & 0x01;
    self.tenacityGoalStatus = (deviceStatus > 5) & 0x01;
    self.pairingStatus = deviceStatus & 0x3;
    
    [self updateCommandFieds];
}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Intensity Goal Achieve:"])
        {
            field.value = self.intensityGoalStatus;
        }
        else if([field.fieldname isEqualToString:@"Frequency Goal Achieve:"])
        {
            field.value = self.frequencyGoalStatus;
        }
        else if([field.fieldname isEqualToString:@"Tenacity Goal Achieve:"])
        {
            field.value = self.tenacityGoalStatus;
        }
        else if([field.fieldname isEqualToString:@"Pairing Status:"])
        {
            field.value = self.pairingStatus;
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
