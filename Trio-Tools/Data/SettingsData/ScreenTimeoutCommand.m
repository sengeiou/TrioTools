//
//  ScreenTimeoutCommand.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/12/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import "ScreenTimeoutCommand.h"
#import "Field.h"
#import "Definitions.h"


@implementation ScreenTimeoutCommand


@synthesize timeoutValue;

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
        if([field.fieldname isEqualToString:@"Timeout Time(sec):"])
        {
            self.timeoutValue = (int) field.value;
        }
    }
    
}

-(NSData*)getCommands
{
    int commandLen = 0;
    unsigned char * buffer = nil;
    if(self.commandAction==0)
    {
        
        //commandLen = 0x08;
        commandLen = READ_COMMAND_SIZE;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.readCommandID;
    }
    else
    {
        commandLen = SCREEN_TIMEOUT_COMMAND_SIZE;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.writeCommandID;
        buffer[2] = (self.timeoutValue >> 8) & 0xFF;
        buffer[3] = self.timeoutValue & 0xFF;

    }
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
    
}
-(void)parseScreenTimeoutRaw:(NSString*)rawData
{
    self.timeoutValue = [ScreenTimeoutCommand getIntValue:rawData startIndex:0 length:4];
    
    [self updateCommandFieds];
    
}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Timeout Time(sec):"])
        {
            field.value = self.timeoutValue;
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
