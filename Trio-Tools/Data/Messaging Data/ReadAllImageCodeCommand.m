//
//  ReadAllImageCodeCommand.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/13/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import "ReadAllImageCodeCommand.h"
#import "Field.h"
#import "Definitions.h"


@implementation ReadAllImageCodeCommand

@synthesize trademark;

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
        if([field.fieldname isEqualToString:@"Trademark:"])
        {
            self.trademark = (int) field.value;
        }
    }
}

-(void)parseAllImageCodeDataRaw:(NSString*)rawData
{
    self.trademark = [ReadAllImageCodeCommand getIntValue:rawData startIndex:0 length:4];
    
    [self updateCommandFieds];
}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Trademark:"])
        {
            field.value = self.trademark;
        }
    }
}

-(NSData*)getCommand
{
    int commandLen = 0;
    unsigned char * buffer = nil;
    
    commandLen = READ_COMMAND_SIZE;
    buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
    buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
    buffer[1] = self.readCommandID;

    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}

+(int) getIntValue:(NSString *) data startIndex:(int) startIndex length:(int) length
{
    unsigned int value;
    
    NSScanner *toDecimal = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(startIndex, length)]];
    [toDecimal scanHexInt:&value];
    return value;
}


@end
