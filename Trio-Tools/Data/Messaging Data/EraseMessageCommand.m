//
//  EraseMessageCommand.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/13/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import "EraseMessageCommand.h"
#import "Field.h"
#import "Definitions.h"

@implementation EraseMessageCommand

@synthesize slot1;
@synthesize slot2;
@synthesize slot3;
@synthesize slot4;
@synthesize slot5;
@synthesize slot6;
@synthesize slot7;
@synthesize slot8;
@synthesize slot9;
@synthesize slot10;
@synthesize slot11;
@synthesize slot12;
@synthesize slot13;
@synthesize slot14;
@synthesize slot15;
@synthesize slot16;
@synthesize slot17;

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
        if([field.fieldname isEqualToString:@"Slot1:"])
        {
            self.slot1 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot2:"])
        {
            self.slot2 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot3:"])
        {
            self.slot3 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot4:"])
        {
            self.slot4 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot5:"])
        {
            self.slot5 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot6:"])
        {
            self.slot6 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot7:"])
        {
            self.slot7 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot8:"])
        {
            self.slot8 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot9:"])
        {
            self.slot9 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot10:"])
        {
            self.slot10 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot11:"])
        {
            self.slot11 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot12:"])
        {
            self.slot12 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot13:"])
        {
            self.slot13 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot14:"])
        {
            self.slot14 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot15:"])
        {
            self.slot15 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot16:"])
        {
            self.slot16 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Slot17:"])
        {
            self.slot17 = (int) field.value;
        }
    }
}


-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Slot1:"])
        {
            field.value = self.slot1;
        }
        else if([field.fieldname isEqualToString:@"Slot2:"])
        {
            field.value = self.slot2;
        }
        else if([field.fieldname isEqualToString:@"Slot3:"])
        {
            field.value = self.slot3;
        }
        else if([field.fieldname isEqualToString:@"Slot4:"])
        {
            field.value = self.slot4;
        }
        else if([field.fieldname isEqualToString:@"Slot5:"])
        {
            field.value = self.slot5;
        }
        else if([field.fieldname isEqualToString:@"Slot6:"])
        {
            field.value = self.slot6;
        }
        else if([field.fieldname isEqualToString:@"Slot7:"])
        {
            field.value = self.slot7;
        }
        else if([field.fieldname isEqualToString:@"Slot8:"])
        {
            field.value = self.slot8;
        }
        else if([field.fieldname isEqualToString:@"Slot9:"])
        {
            field.value = self.slot9;
        }
        else if([field.fieldname isEqualToString:@"Slot10:"])
        {
            field.value = self.slot10;
        }
        else if([field.fieldname isEqualToString:@"Slot11:"])
        {
            field.value = self.slot11;
        }
        else if([field.fieldname isEqualToString:@"Slot12:"])
        {
            field.value = self.slot12;
        }
        else if([field.fieldname isEqualToString:@"Slot13:"])
        {
            field.value = self.slot13;
        }
        else if([field.fieldname isEqualToString:@"Slot14:"])
        {
            field.value = self.slot14;
        }
        else if([field.fieldname isEqualToString:@"Slot15:"])
        {
            field.value = self.slot15;
        }
        else if([field.fieldname isEqualToString:@"Slot16:"])
        {
            field.value = self.slot16;
        }
        else if([field.fieldname isEqualToString:@"Slot17:"])
        {
            field.value = self.slot17;
        }
    }
}

-(NSData*)getCommand
{
    int commandLen = 0;
    unsigned char * buffer = nil;
    
    commandLen = ERASE_MESSAGE_COMMAND_SIZE;
    buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
    buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
    buffer[1] = self.readCommandID;
    buffer[2] = 0x00;
    buffer[3] = self.slot1;
    buffer[4] = self.slot2;
    buffer[5] = self.slot3;
    buffer[6] = self.slot4;
    buffer[7] = self.slot5;
    buffer[8] = self.slot6;
    buffer[9] = self.slot7;
    buffer[10] = self.slot8;
    buffer[11] = self.slot9;
    buffer[12] = self.slot10;
    buffer[13] = self.slot11;
    buffer[14] = self.slot12;
    buffer[15] = self.slot13;
    buffer[16] = self.slot14;
    buffer[17] = self.slot15;
    buffer[18] = self.slot16;
    buffer[19] = self.slot17;
    
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}


@end
