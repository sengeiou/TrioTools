//
//  StartProfileRecordingCommand.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/8/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "StartProfileRecordingCommand.h"
#import "Field.h"
#import "Definitions.h"

#define START_PROFILE_RECORDING_COMMAND_SIZE 2

@implementation StartProfileRecordingCommand

@synthesize recordDuration;

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

}

-(NSData*)getCommands
{
    int commandLen = 0;
    unsigned char * buffer = nil;
    
    commandLen = START_PROFILE_RECORDING_COMMAND_SIZE;
    buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
    buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
    buffer[1] = self.readCommandID;
    

    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}

-(void)parseRecordDuration:(NSString*)rawData
{
    self.recordDuration =  [StartProfileRecordingCommand getIntValue:rawData startIndex:4 length:4];
}


+(int) getIntValue:(NSString *) data startIndex:(int) startIndex length:(int) length
{
    unsigned int value;
    
    NSScanner *toDecimal = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(startIndex, length)]];
    [toDecimal scanHexInt:&value];
    return value;
}

@end
