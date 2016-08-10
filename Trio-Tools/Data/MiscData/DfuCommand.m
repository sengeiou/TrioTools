//
//  DfuCommand.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/26/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "DfuCommand.h"
#import "Field.h"
#import "Definitions.h"

#define DFU_COMMAND_SIZE 6

@implementation DfuCommand

@synthesize firmwareVer;
@synthesize flashOverride;

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
        if([field.fieldname isEqualToString:@"Firmware version:"])
        {
            self.firmwareVer =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Flash Override:"])
        {
            self.flashOverride = field.value;
        }
    }
}

-(NSData*)getCommands
{
    int commandLen = 0;
    unsigned char * buffer = nil;

    commandLen = DFU_COMMAND_SIZE;
    buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
    buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
    buffer[1] = self.readCommandID;
    
    buffer[2] = self.deviceInfo.model >> 8 & 0xFF;
    buffer[3] = self.deviceInfo.model & 0xFF;
    
    buffer [4] = self.firmwareVer;
    buffer [5] = self.flashOverride?0x02:0x00;
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}
@end
