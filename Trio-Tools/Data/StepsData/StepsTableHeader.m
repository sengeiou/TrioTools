//
//  StepsTableHeader.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/21/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "StepsTableHeader.h"
#import "Field.h"
#import "Definitions.h"




#define READ_COMMAND_SIZE           3
#define UPDATE_TABLE_DATA_SIZE      8


@implementation StepsTableHeader

@synthesize selectedFieldIndex;
@synthesize tableType;

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
        if([field.fieldname isEqualToString:@"Table Type:"])
        {
            self.tableType =(int) field.value;
        }

    }
}

-(NSData*)getCommands
{
    int commandLen = 0;
    unsigned char * buffer = nil;
    if(self.commandAction==0)
    {
        Field *field = [self.commandFields.fields objectAtIndex:0];
        commandLen = READ_COMMAND_SIZE;
        
        if((self.deviceInfo.model == 961 && self.deviceInfo.firmwareVersion > 4.3f) || self.deviceInfo.model == 962)
        {
            commandLen++;
        }
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.readCommandID;
        buffer[2] = field.value;
        buffer[3] = self.tableType;
    }
    else
    {
        Field *field = [self.commandFields.fields objectAtIndex:self.selectedFieldIndex];
        
        StepTable *table = (StepTable*)field.objectValue;
        if(self.deviceInfo.model != FT900)
        {
            commandLen = UPDATE_TABLE_DATA_SIZE;
            if((self.deviceInfo.model == 961 && self.deviceInfo.firmwareVersion > 4.3f) || self.deviceInfo.model == 962)
            {
                commandLen++;
            }
            buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
            buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
            buffer[1] = self.writeCommandID;
            buffer[2] = table.tableYear | 0xC0;
            buffer[3] = table.tableMonth | 0xC0;
            buffer[4] = table.tableDay | 0xC0;
            buffer[5] = (table.tableHourFlag >> (8*2)) & 0xFF;
            buffer[6] = (table.tableHourFlag >> (8*1)) & 0xFF;
            buffer[7] = (table.tableHourFlag >> (8*0)) & 0xFF;
            buffer[8] = self.tableType;

        }
        
        NSLog(@"[0] %X",buffer[0]);
        NSLog(@"[1] %X",buffer[1]);
        NSLog(@"[2] %X",buffer[2]);
        NSLog(@"[3] %X",buffer[3]);
        NSLog(@"[4] %X",buffer[4]);
        NSLog(@"[5] %X",buffer[5]);
        NSLog(@"[6] %X",buffer[6]);
        NSLog(@"[7] %X",buffer[7]);
        NSLog(@"[8] %X",buffer[8]);
    }
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    return command;
}

-(void)parseStepsTableHeaderRaw:(NSString*)rawData
{
    int len = (int) [rawData length] / 16;
    for(int i=0; i<len; i++)
    {
        Field *field = [[Field alloc] init];
        field.uiControlType = 2;
        
        StepTable *stepTable = [[StepTable alloc] init];
        
        NSString *stepTableStr = [rawData substringWithRange:NSMakeRange(i*16, 16)];
        stepTable.tableYear = [StepsTableHeader getIntValue:stepTableStr startIndex:0 length:2] & 0x3f;
        stepTable.tableMonth = [StepsTableHeader getIntValue:stepTableStr startIndex:2 length:2] & 0x3f;
        stepTable.tableDay = [StepsTableHeader getIntValue:stepTableStr startIndex:4 length:2] & 0x3f;
        stepTable.tableCurrentHour = [StepsTableHeader getIntValue:stepTableStr startIndex:6 length:2] & 0x3f;
        stepTable.tableHourFlag = [StepsTableHeader getIntValue:stepTableStr startIndex:8 length:6];
        stepTable.tableSentHourFlag = [self parsedSentHourFlag:[StepsTableHeader getIntValue:stepTableStr startIndex:8 length:6]];

        stepTable.tableSignatureFlag = [StepsTableHeader getIntValue:stepTableStr startIndex:14 length:2];
        stepTable.tableTotalHoursFlagged = [self totalHoursFlag:stepTable.tableHourFlag];

        if((stepTable.tableYear == 63 && stepTable.tableMonth == 63 && stepTable.tableDay == 63 ) || (stepTable.tableYear == 0 && stepTable.tableMonth == 0 && stepTable.tableDay ==0))
        {
            field.fieldname = @"Unused slot";
        }
        else
        {
            field.fieldname = [NSString stringWithFormat:@"Date:%.2d-%.2d-20%.2d | Hour#%.2d | Hours flagged:%d",stepTable.tableMonth,stepTable.tableDay,stepTable.tableYear,stepTable.tableCurrentHour,stepTable.tableTotalHoursFlagged];
        }
        field.objectValue = stepTable;
        
        [self.commandFields.fields addObject:field];
    }

}

-(int)totalHoursFlag:(int)flagData
{
    int hoursFlagged = 0;
    for (int i=0; i<24; i++)
    {
        int flag = flagData >> i & 0x01;
        if(flag)
        {
            hoursFlagged++;
        }
    }
    return hoursFlagged;
}

-(NSMutableArray*)parsedSentHourFlag:(int)flagData
{
    NSMutableArray *hourFlags = [[NSMutableArray alloc] init];
    
    for (int i=0; i<24; i++)
    {
        int flag = flagData >> i & 0x01;
        [hourFlags addObject:[NSString stringWithFormat:@"%d",flag ]];
    }
    return hourFlags;
}

+(int) getIntValue:(NSString *) data startIndex:(int) startIndex length:(int) length
{
    unsigned int value;
    
    NSScanner *toDecimal = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(startIndex, length)]];
    [toDecimal scanHexInt:&value];
    return value;
}

@end
