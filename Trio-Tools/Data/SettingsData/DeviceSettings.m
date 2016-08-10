//
//  DeviceSettings.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/19/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "DeviceSettings.h"
#import "Field.h"
#import "Definitions.h"

#define READ_COMMAND_SIZE               2
#define DEVICE_SETTINGS_COMMAND_SIZE_1  9
#define DEVICE_SETTINGS_COMMAND_SIZE_2 11
#define DEVICE_SETTINGS_COMMAND_SIZE_3 15


@implementation DeviceSettings


@synthesize  deviceTimeHour;
@synthesize  deviceTimeMinutes;
@synthesize  deviceTimeSeconds;
@synthesize  deviceTimeAmPm;

@synthesize  deviceYear;
@synthesize  deviceMonth;
@synthesize  deviceDay;

@synthesize  shouldAddTimeOffset;
@synthesize  dstApplicable;
@synthesize  hourOffSet;
@synthesize  minuteOffSet;

@synthesize dstOffsetType;

@synthesize dstStarted;
@synthesize dstStartHour;
@synthesize dstStartMonth;
@synthesize dstStartDay;

@synthesize dstEnded;
@synthesize dstEndHour;
@synthesize dstEndMonth;
@synthesize dstEndDay;

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
        self.deviceInfo = [[DeviceInformation alloc] init];
        self.commandFields = [[CommandFields alloc] init];
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
        if([field.fieldname isEqualToString:@"Month:"])
        {
            self.deviceMonth = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Day:"])
        {
            self.deviceDay = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Year:"])
        {
            self.deviceYear = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Hour:"])
        {
            self.deviceTimeHour = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Minute:"])
        {
            self.deviceTimeMinutes = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Second:"])
        {
            self.deviceTimeSeconds = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"AM/PM:"])
        {
            self.deviceTimeAmPm = field.value;
        }
        else if([field.fieldname isEqualToString:@"24Hr/12Hr:"])
        {
            self.deviceTimeAmPm = field.value;
        }
        else if([field.fieldname isEqualToString:@"Offset Type:"])
        {
            self.shouldAddTimeOffset = field.value;
        }
        else if([field.fieldname isEqualToString:@"DST Applicable:"])
        {
            self.dstApplicable = field.value;
        }
        else if([field.fieldname isEqualToString:@"DST Offset Type:"])
        {
             self.dstOffsetType = field.value;
        }
        else if([field.fieldname isEqualToString:@"Hour Offset:"])
        {
            self.hourOffSet = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Minute Offset:"])
        {
            self.minuteOffSet = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"DST Started:"])
        {
            self.dstStarted =  field.value;
        }
        else if([field.fieldname isEqualToString:@"DST Start Month:"])
        {
            self.dstStartMonth = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"DST Start Day:"])
        {
            self.dstStartDay = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"DST Start Hour:"])
        {
            self.dstStartHour = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"DST Ended:"])
        {
             self.dstEnded =  field.value;
        }
        else if([field.fieldname isEqualToString:@"DST End Month:"])
        {
            self.dstEndMonth = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"DST End Day:"])
        {
            self.dstEndDay = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"DST End Hour:"])
        {
            self.dstEndHour = (int) field.value;
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
        if(self.deviceInfo.model == PE932 || self.deviceInfo.model == PE939 || self.deviceInfo.model == PE936 ||
            (self.deviceInfo.model == PE961 && self.deviceInfo.firmwareVersion  < 5.0f))
        {
            //This is the original Device settings command format
            commandLen = DEVICE_SETTINGS_COMMAND_SIZE_1;
            buffer = (unsigned char*) calloc(DEVICE_SETTINGS_COMMAND_SIZE_1,sizeof(unsigned char));
            buffer[0] = 0x1B; //Command Signature
            buffer[1] = 0x16; //command code
            buffer[2] = self.deviceTimeHour | 0xC0;
            buffer[3] = self.deviceTimeMinutes;
            buffer[4] = self.deviceTimeSeconds;
            buffer[5] = self.deviceTimeAmPm;
            buffer[6] = self.deviceYear | 0xC0;
            buffer[7] = self.deviceMonth | 0xC0;
            buffer[8] = self.deviceDay | 0xC0;
            NSLog(@"[2] %X",buffer[2]);
            NSLog(@"[3] %X",buffer[3]);
            NSLog(@"[4] %X",buffer[4]);
            NSLog(@"[5] %X",buffer[5]);
            NSLog(@"[6] %X",buffer[6]);
            NSLog(@"[7] %X",buffer[7]);
            NSLog(@"[8] %X",buffer[8]);
        }
        else if(self.deviceInfo.model == FT900 || self.deviceInfo.model == 969)
        {
            //Added offset time bytes
            commandLen = DEVICE_SETTINGS_COMMAND_SIZE_2;
            buffer = (unsigned char*) calloc(DEVICE_SETTINGS_COMMAND_SIZE_2,sizeof(unsigned char));
            int byte9 = 0x00;
            byte9 |= self.shouldAddTimeOffset?0x80:0x00;
            byte9 |= self.hourOffSet;
            
            buffer[0] = self.deviceInfo.model== FT969?0x1B:0x0A; //Command SIZE
            buffer[1] = 0x16; //command code
            buffer[2] = self.deviceTimeHour | 0xC0;
            buffer[3] = self.deviceTimeMinutes;
            buffer[4] = self.deviceTimeSeconds;
            buffer[5] = self.deviceTimeAmPm;
            buffer[6] = self.deviceYear | 0xC0;
            buffer[7] = self.deviceMonth | 0xC0;
            buffer[8] = self.deviceDay | 0xC0;
            buffer[9] = byte9;
            buffer[10] = self.minuteOffSet;
        }
        else
        {
            //New format in which we added
            //Added offset time bytes
            commandLen = DEVICE_SETTINGS_COMMAND_SIZE_3;
            buffer = (unsigned char*) calloc(DEVICE_SETTINGS_COMMAND_SIZE_3,sizeof(unsigned char));
            int byte9 = 0x00;
            byte9 |= self.shouldAddTimeOffset?0x80:0x00;
            byte9 |= self.dstOffsetType?0x20:0x00;
            byte9 |= self.dstApplicable?0x40:0x00;
            byte9 |= self.hourOffSet;
            
            int dstStartedValue = 0x00;
            dstStartedValue = dstStartedValue | self.dstStartHour;
            dstStartedValue = dstStartedValue | (self.dstStartDay << 5);
            dstStartedValue = dstStartedValue | (self.dstStartMonth << 10);
            dstStartedValue = dstStartedValue | (self.dstStarted << 14);
            
            int dstEndedValue = 0x00;
            dstEndedValue = dstEndedValue | self.dstEndHour;
            dstEndedValue = dstEndedValue | (self.dstEndDay << 5);
            dstEndedValue = dstEndedValue | (self.dstEndMonth << 10);
            dstEndedValue = dstEndedValue | (self.dstEnded << 14);
            
            
            buffer[0] = 0x1B; //Command ID
            buffer[1] = 0x16; //command code
            buffer[2] = self.deviceTimeHour | 0xC0;
            buffer[3] = self.deviceTimeMinutes;
            buffer[4] = self.deviceTimeSeconds;
            buffer[5] = self.deviceTimeAmPm;
            buffer[6] = self.deviceYear | 0xC0;
            buffer[7] = self.deviceMonth | 0xC0;
            buffer[8] = self.deviceDay | 0xC0;
            buffer[9] = byte9;
            buffer[10] = self.minuteOffSet;
            buffer[11] = (dstStartedValue >> 8) & 0xFF;
            buffer[12] = dstStartedValue & 0xFF;
            buffer[13] = (dstEndedValue >> 8) & 0xFF;;
            buffer[14] = dstEndedValue & 0xFF;;
        }
    }
         
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}
-(void)parseDeviceSettingsRaw:(NSString*)rawData
{
    self.deviceTimeHour = [DeviceSettings getIntValue:rawData startIndex:4 length:2] & 0x3F;
    self.deviceTimeMinutes = [DeviceSettings getIntValue:rawData startIndex:6 length:2];
    self.deviceTimeSeconds = [DeviceSettings getIntValue:rawData startIndex:8 length:2];
    self.deviceTimeAmPm = [DeviceSettings getIntValue:rawData startIndex:10 length:2];
    self.deviceYear = [DeviceSettings getIntValue:rawData startIndex:12 length:2] & 0x3F;
    self.deviceMonth = [DeviceSettings getIntValue:rawData startIndex:14 length:2] & 0x3F;
    self.deviceDay = [DeviceSettings getIntValue:rawData startIndex:16 length:2] & 0x3F;
    
    if([rawData length]==22)
    {
        if(self.deviceInfo.model == FT905 || self.deviceInfo.model == FT969)
        {
            self.shouldAddTimeOffset = ([DeviceSettings getIntValue:rawData startIndex:18 length:2] >> 7) & 0x01;
            self.dstApplicable = ([DeviceSettings getIntValue:rawData startIndex:18 length:2] >> 6) & 0x01;
            self.hourOffSet = [DeviceSettings getIntValue:rawData startIndex:18 length:2] & 0x3F;
            self.minuteOffSet = [DeviceSettings getIntValue:rawData startIndex:20 length:2];
        }
        else
        {
            self.shouldAddTimeOffset = [DeviceSettings getIntValue:rawData startIndex:18 length:2] >> 7;
            self.hourOffSet = [DeviceSettings getIntValue:rawData startIndex:18 length:2] & 0x7F;
            self.minuteOffSet = [DeviceSettings getIntValue:rawData startIndex:20 length:2];
        }
    }
    else if([rawData length] == 30)
    {
        self.shouldAddTimeOffset = ([DeviceSettings getIntValue:rawData startIndex:18 length:2] >> 7) & 0x01;
        self.dstApplicable = ([DeviceSettings getIntValue:rawData startIndex:18 length:2] >> 6) & 0x01;
        self.dstOffsetType = ([DeviceSettings getIntValue:rawData startIndex:18 length:2] >> 5) & 0x01;
        self.hourOffSet = [DeviceSettings getIntValue:rawData startIndex:18 length:2] & 0x1F;
        self.minuteOffSet = [DeviceSettings getIntValue:rawData startIndex:20 length:2];
        
        int dstStartedValue = [DeviceSettings getIntValue:rawData startIndex:22 length:4];
        
        self.dstStarted = (dstStartedValue >> 14 ) & 0x01;
        self.dstStartMonth = (dstStartedValue >> 10) & 0x0F; //([DeviceSettings getIntValue:rawData startIndex:22 length:2] >> 2) & 0x0F;
        self.dstStartDay = (dstStartedValue >> 5) & 0x1F;   //[DeviceSettings getIntValue:rawData startIndex:24 length:2] & 0x1F;
        self.dstStartHour = dstStartedValue & 0x1F;           //([DeviceSettings getIntValue:rawData startIndex:24 length:4] >> 5) & 0X1F;
        
        int dstEndedValue = [DeviceSettings getIntValue:rawData startIndex:26 length:4];
        
        self.dstEnded = (dstEndedValue >> 14 ) & 0x01;    //[DeviceSettings getIntValue:rawData startIndex:22 length:4];
        self.dstEndMonth = (dstEndedValue >> 10) & 0x0F;  //([DeviceSettings getIntValue:rawData startIndex:26 length:2] >> 2) & 0x0F;
        self.dstEndDay = (dstEndedValue >> 5) & 0x1F;    //[DeviceSettings getIntValue:rawData startIndex:28 length:2] & 0x1F;
        self.dstEndHour = dstEndedValue & 0x1F;            //([DeviceSettings getIntValue:rawData startIndex:28 length:4] >> 5) & 0x1F;
    }
    [self updateCommandFieds];
}


-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Month:"])
        {
            field.value = self.deviceMonth;
        }
        else if([field.fieldname isEqualToString:@"Day:"])
        {
            field.value = self.deviceDay;
        }
        else if([field.fieldname isEqualToString:@"Year:"])
        {
            field.value = self.deviceYear;
        }
        else if([field.fieldname isEqualToString:@"Hour:"])
        {
            field.value = self.deviceTimeHour;
        }
        else if([field.fieldname isEqualToString:@"Minute:"])
        {
            field.value = self.deviceTimeMinutes;
        }
        else if([field.fieldname isEqualToString:@"Second:"])
        {
            field.value = self.deviceTimeSeconds;
        }
        else if([field.fieldname isEqualToString:@"AM/PM:"])
        {
            field.value = self.deviceTimeAmPm;
        }
        else if([field.fieldname isEqualToString:@"24Hr/12Hr:"])
        {
            field.value = self.deviceTimeAmPm;
        }
        else if([field.fieldname isEqualToString:@"Offset Type:"])
        {
            field.value = self.shouldAddTimeOffset;
        }
        else if([field.fieldname isEqualToString:@"DST Applicable:"])
        {
            field.value = self.dstApplicable;
        }
        else if([field.fieldname isEqualToString:@"DST Offset Type:"])
        {
            field.value = self.dstOffsetType;
        }
        else if([field.fieldname isEqualToString:@"Hour Offset:"])
        {
            field.value = self.hourOffSet;
        }
        else if([field.fieldname isEqualToString:@"Minute Offset:"])
        {
            field.value = self.minuteOffSet;
        }
        else if([field.fieldname isEqualToString:@"DST Started:"])
        {
            field.value = self.dstStarted;
        }
        else if([field.fieldname isEqualToString:@"DST Start Month:"])
        {
            field.value = self.dstStartMonth;
        }
        else if([field.fieldname isEqualToString:@"DST Start Day:"])
        {
            field.value = self.dstStartDay;
        }
        else if([field.fieldname isEqualToString:@"DST Start Hour:"])
        {
            field.value = self.dstStartHour;
        }
        else if([field.fieldname isEqualToString:@"DST Ended:"])
        {
            field.value = self.dstEnded;
        }
        else if([field.fieldname isEqualToString:@"DST End Month:"])
        {
            field.value = self.dstEndMonth;
        }
        else if([field.fieldname isEqualToString:@"DST End Day:"])
        {
            field.value = self.dstEndDay;
        }
        else if([field.fieldname isEqualToString:@"DST End Hour:"])
        {
            field.value = self.dstEndHour;
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
