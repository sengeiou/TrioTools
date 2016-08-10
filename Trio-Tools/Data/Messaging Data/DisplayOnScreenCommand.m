//
//  SetMessageCommand.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/14/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import "DisplayOnScreenCommand.h"
#import "Field.h"
#import "Utilities.h"
#import "Definitions.h"

@implementation DisplayOnScreenCommand

@synthesize message;
@synthesize scrollingDelay;
@synthesize messageType;
@synthesize scrollSettings;
@synthesize fontStyle;
@synthesize textColor;
@synthesize xCoor;
@synthesize yCoor;
@synthesize bgColor;

@synthesize setMessageCommandsArray;

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
        
        self.setMessageCommandsArray = [self getCommandData];
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
        if([field.fieldname isEqualToString:@"Message:"])
        {
            self.message =  field.stringValue;
        }
        else if([field.fieldname isEqualToString:@"Scrolling Delay (1= 10ms):"])
        {
            self.scrollingDelay = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Message Type:"])
        {
            self.messageType = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Scrolling (OFF/ON):"])
        {
            self.scrollSettings = field.value;
        }
        else if([field.fieldname isEqualToString:@"Font Style:"])
        {
            self.fontStyle = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Text Color:"])
        {
            self.textColor = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"X Coordinates:"])
        {
            self.xCoor = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Y Coordinates:"])
        {
            self.yCoor = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Background Color:"])
        {
            self.bgColor = (int) field.value;
        }
    }
}


-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Message:"])
        {
            field.stringValue = self.message;
        }
        else if([field.fieldname isEqualToString:@"Scrolling Delay (1= 10ms):"])
        {
            field.value = self.scrollingDelay;
        }
        else if([field.fieldname isEqualToString:@"Message Type:"])
        {
            field.value = self.messageType;
        }
        else if([field.fieldname isEqualToString:@"Scrolling (OFF/ON):"])
        {
            field.value = self.scrollSettings;
        }
        else if([field.fieldname isEqualToString:@"Font Style:"])
        {
            field.value = self.fontStyle;
        }
        else if([field.fieldname isEqualToString:@"Text Color:"])
        {
            field.value = self.textColor;
        }
        else if([field.fieldname isEqualToString:@"X Coordinates:"])
        {
            field.value = self.xCoor;
        }
        else if([field.fieldname isEqualToString:@"Y Coordinates:"])
        {
            field.value = self.yCoor;
        }
        else if([field.fieldname isEqualToString:@"Background Color:"])
        {
            field.value = self.bgColor;
        }
    }
}

-(NSData*)getCommand
{
    int commandLen = 20;
    unsigned char * buffer = nil;
    
//    commandLen = ERASE_MESSAGE_COMMAND_SIZE;
    buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
    buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
    buffer[1] = self.writeCommandID;
    
    NSString *data = [self.setMessageCommandsArray objectAtIndex:0];
    int length = (int) [data length]/2;
    
    int start = 0;
    for(int i=0; i<length; i++)
    {
        buffer[i+2] = [DisplayOnScreenCommand getIntValue:data startIndex:start length:2];
        start+=2;
    }
    
    NSData *command = [NSData dataWithBytes:buffer length:length+2];
    
    return command;
}


-(NSMutableArray*)getCommandData
{
    NSMutableArray *commandData = [[NSMutableArray alloc] init];
    
    NSString *temp = [[NSString alloc] init];
    temp = [temp stringByAppendingString:[NSString stringWithFormat: @"%.2X",(unsigned short)self.scrollingDelay]];
    
    int messageProperty = 0x00;
    messageProperty |= self.messageType << 13;
    messageProperty |= self.scrollSettings << 6;
    messageProperty |= self.fontStyle << 3;
    messageProperty |= self.textColor;
    
    temp = [temp stringByAppendingString:[NSString stringWithFormat: @"%.4X",(unsigned short)messageProperty]];
    temp = [temp stringByAppendingString:[NSString stringWithFormat: @"%.2X",(unsigned short)self.xCoor]];
    temp = [temp stringByAppendingString:[NSString stringWithFormat: @"%.2X",(unsigned short)self.yCoor]];
    temp = [temp stringByAppendingString:[NSString stringWithFormat: @"%.4X",(unsigned short)self.bgColor]];
    
    NSString *hexStringMessageData = [Utilities ConvertStringToHexString:self.message];
    temp = [temp stringByAppendingString:[NSString stringWithFormat: @"%@00FF",hexStringMessageData]];

    NSData* data = [Utilities convertHexStringToNSData:temp];
    int checkSum = [Utilities computeCheckSum32:data];
    int totalBytes = (int) [temp length]/2 + 2;

    temp = [NSString stringWithFormat:@"%.6X%.4X%@",totalBytes,checkSum,temp];
    
    int totalPackets = (int) [temp length]/32;
    totalPackets = [temp length] % 32?totalPackets+1:totalPackets;
    
    for(int index =0; index < [temp length];)
    {
        //Adding packet number as prefix. Starts with highest packet index
        if(index+32 >= [temp length])
        {
            NSString *cmdStr = [NSString stringWithFormat:@"%.4X%@",totalPackets-1,[temp substringFromIndex:index]];
            [commandData addObject:cmdStr];
        }
        else
        {
            NSString *cmdStr = [NSString stringWithFormat:@"%.4X%@",totalPackets-1,[temp substringWithRange:NSMakeRange(index, 32)]];
            [commandData addObject:cmdStr];
        }
        
        index +=32;
        totalPackets--;
    }
    
    return commandData;
}

+(int) getIntValue:(NSString *) data startIndex:(int) startIndex length:(int) length
{
    unsigned int value;
    
    NSScanner *toDecimal = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(startIndex, length)]];
    [toDecimal scanHexInt:&value];
    return value;
}

@end
