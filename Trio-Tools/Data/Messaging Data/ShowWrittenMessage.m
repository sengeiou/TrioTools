//
//  ShowWrittenMessage.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/18/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import "ShowWrittenMessage.h"
#import "Field.h"
#import "Definitions.h"

@implementation ShowWrittenMessage

@synthesize slotNumber;

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
        if([field.fieldname isEqualToString:@"Slot Number:"])
        {
            self.slotNumber = (int) field.value;
        }
    }
}


-(NSData*)getCommand
{
    int commandLen = 4;
    unsigned char * buffer = nil;

    buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
    buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
    buffer[1] = self.readCommandID;
    buffer[2] = 0x00;
    buffer[3] = self.slotNumber;
    
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}
@end
