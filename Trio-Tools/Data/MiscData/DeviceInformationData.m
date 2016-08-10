//
//  DeviceInformation.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/2/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "DeviceInformationData.h"
#import "Field.h"
#import "Definitions.h"

@implementation DeviceInformationData

@synthesize serialNo;
@synthesize firmwareVersion;
@synthesize modelNumber;
@synthesize broadcastType;
@synthesize hardwareVersion;
@synthesize batteryLevel;
@synthesize bootLoaderVersion;
@synthesize betaVersionNumber;
@synthesize deviceSensitivity;


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
        if([field.fieldname isEqualToString:@"Serial Number:"])
        {
            self.serialNo = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Model Number:"])
        {
            self.modelNumber = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Firmware Version:"])
        {
            self.firmwareVersion = field.floatValue;
        }
        else if([field.fieldname isEqualToString:@"Broadcast Type:"])
        {
            self.broadcastType = field.value;
        }
        else if([field.fieldname isEqualToString:@"Hardware Version:"])
        {
            self.hardwareVersion = field.floatValue;
        }
        else if([field.fieldname isEqualToString:@"Battery Level:"])
        {
            self.batteryLevel = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Boot Loader Version:"])
        {
            self.bootLoaderVersion = field.floatValue;
        }
        else if([field.fieldname isEqualToString:@"Beta Number:"])
        {
            self.betaVersionNumber = (int) field.value;
        }
    }
}

-(NSData*)getCommands
{
    int commandLen = 0;
    unsigned char * buffer = nil;
    //commandLen = 0x08;
    commandLen = READ_COMMAND_SIZE;
    buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
    buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
    buffer[1] = self.readCommandID;
    
    /*
    buffer[1] = 0xFD;
    buffer[2] = 0x01;
    buffer[3] = 0x10;//self.readCommandID;
    buffer[4] = 0x00;//self.readCommandID;
    buffer[5] = 0x00;//self.readCommandID;
    buffer[6] = 0x01;//self.readCommandID;
    buffer[7] = 0x00;//self.readCommandID;
    */
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}

-(void)parseDeviceInfoRaw:(NSString*)rawData
{
    self.serialNo = [[DeviceInformationData ConvertHexStringToString:[rawData substringWithRange:NSMakeRange(4, 20)]] longLongValue];
    self.modelNumber = [DeviceInformationData getIntValue:rawData startIndex:24 length:4];
    self.firmwareVersion = [[NSString stringWithFormat:@"%d.%d",[DeviceInformationData getIntValue:rawData startIndex:28 length:1],[DeviceInformationData getIntValue:rawData startIndex:29 length:1]] floatValue];
    self.broadcastType = [DeviceInformationData getIntValue:rawData startIndex:30 length:2];
    
    if(self.modelNumber == PE961)
    {
        if(self.firmwareVersion >= 2.0f)
        {
            self.hardwareVersion = [[NSString stringWithFormat:@"%d.%d",[DeviceInformationData getIntValue:rawData startIndex:32 length:1],[DeviceInformationData getIntValue:rawData startIndex:33 length:1]] floatValue];
        }
        if(self.firmwareVersion >= 3.5f)
        {
            self.batteryLevel = [DeviceInformationData getIntValue:rawData startIndex:34 length:2];
            self.bootLoaderVersion = [[NSString stringWithFormat:@"%d.%d",[DeviceInformationData getIntValue:rawData startIndex:36 length:1],[DeviceInformationData getIntValue:rawData startIndex:37 length:1]] floatValue];
        }
        if(self.firmwareVersion >=5.0f)
        {
            if([rawData length] > 38)
            {
                self.betaVersionNumber = [DeviceInformationData getIntValue:rawData startIndex:38 length:2];
            }
        }
    }
    else if(self.deviceInfo.model == FT962)
    {
        self.hardwareVersion = [[NSString stringWithFormat:@"%d.%d",[DeviceInformationData getIntValue:rawData startIndex:32 length:1],[DeviceInformationData getIntValue:rawData startIndex:33 length:1]] floatValue];
        self.batteryLevel = [DeviceInformationData getIntValue:rawData startIndex:34 length:2];
        self.bootLoaderVersion = [[NSString stringWithFormat:@"%d.%d",[DeviceInformationData getIntValue:rawData startIndex:36 length:1],[DeviceInformationData getIntValue:rawData startIndex:37 length:1]] floatValue];
        self.betaVersionNumber = [DeviceInformationData getIntValue:rawData startIndex:38 length:2];
    }
    else if(self.modelNumber == FT905 || self.modelNumber == FT969)
    {
        self.hardwareVersion = [[NSString stringWithFormat:@"%d.%d",[DeviceInformationData getIntValue:rawData startIndex:32 length:1],[DeviceInformationData getIntValue:rawData startIndex:33 length:1]] floatValue];
        self.batteryLevel = [DeviceInformationData getIntValue:rawData startIndex:34 length:2];
        self.bootLoaderVersion = [[NSString stringWithFormat:@"%d.%d",[DeviceInformationData getIntValue:rawData startIndex:36 length:1],[DeviceInformationData getIntValue:rawData startIndex:37 length:1]] floatValue];
        if([rawData length] > 38)
        {
            self.betaVersionNumber = [DeviceInformationData getIntValue:rawData startIndex:38 length:2];
        }
    }
    else if(self.modelNumber == FT900)
    {
        self.hardwareVersion = [[NSString stringWithFormat:@"%d.%d",[DeviceInformationData getIntValue:rawData startIndex:32 length:1],[DeviceInformationData getIntValue:rawData startIndex:33 length:1]] floatValue];
        if([rawData length] >=40)
        {
            self.batteryLevel = [DeviceInformationData getIntValue:rawData startIndex:34 length:2];
            self.bootLoaderVersion = [[NSString stringWithFormat:@"%d.%d",[DeviceInformationData getIntValue:rawData startIndex:36 length:1],[DeviceInformationData getIntValue:rawData startIndex:37 length:1]] floatValue];
            self.betaVersionNumber = [DeviceInformationData getIntValue:rawData startIndex:38 length:2];
        }
        else
        {
            self.betaVersionNumber = [DeviceInformationData getIntValue:rawData startIndex:34 length:2];
        }
    }
    
    [self updateCommandFieds];
}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Serial Number:"])
        {
            field.value = self.serialNo;
        }
        else if([field.fieldname isEqualToString:@"Model Number:"])
        {
            field.value = self.modelNumber ;
        }
        else if([field.fieldname isEqualToString:@"Firmware Version:"])
        {
            field.floatValue = self.firmwareVersion;
        }
        else if([field.fieldname isEqualToString:@"Broadcast Type:"])
        {
            field.value = self.broadcastType;
        }
        else if([field.fieldname isEqualToString:@"Hardware Version:"])
        {
            field.floatValue = self.hardwareVersion;
        }
        else if([field.fieldname isEqualToString:@"Battery Level:"])
        {
            field.value = self.batteryLevel;
        }
        else if([field.fieldname isEqualToString:@"Boot Loader Version:"])
        {
            field.floatValue = self.bootLoaderVersion;
        }
        else if([field.fieldname isEqualToString:@"Beta Number:"])
        {
            field.value = self.betaVersionNumber;
        }
    }
}

+(unsigned long long) getLongValue:(NSString *) data startIndex:(int) startIndex length:(int) length
{
    unsigned long long value;
    NSString *dataStr = [data substringWithRange:NSMakeRange(startIndex, length)];
    NSLog(@"serial str len: %lu",(unsigned long)[dataStr length]);
    NSScanner *toDecimal = [NSScanner scannerWithString:dataStr];
    [toDecimal scanHexLongLong:&value];
    return value;
}

+(int) getIntValue:(NSString *) data startIndex:(int) startIndex length:(int) length
{
    unsigned int value;
    
    NSScanner *toDecimal = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(startIndex, length)]];
    [toDecimal scanHexInt:&value];
    return value;
}

+(NSString *)ConvertHexStringToString:(NSString*)hexString
{
    NSMutableString * newString = [[NSMutableString alloc] init];
    int i = 0;
    while (i < [hexString length])
    {
        NSString * hexChar = [hexString substringWithRange: NSMakeRange(i, 2)];
        int value = 0;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [newString appendFormat:@"%c", (char)value];
        i+=2;
    }
    return newString;
}


@end
