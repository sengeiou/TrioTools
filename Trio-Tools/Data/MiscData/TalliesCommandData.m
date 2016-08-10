//
//  TalliesCommandData.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/6/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import "TalliesCommandData.h"
#import "Field.h"
#import "Definitions.h"

@implementation TalliesCommandData

@synthesize hoursUsed;
@synthesize beaconConnected;
@synthesize beaconFailed;
@synthesize onDemandConnected;
@synthesize onDemandFailed;
@synthesize numberOfCharge;
@synthesize numberOfHardReset;
@synthesize numberOfVibration;

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
        if([field.fieldname isEqualToString:@"Hours Used:"])
        {
            self.hoursUsed = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Beacon Connected:"])
        {
            self.beaconConnected = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Beacon Failed:"])
        {
            self.beaconFailed = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"On-Demand Connected:"])
        {
            self.onDemandConnected =  (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"On-Demand Failed:"])
        {
            self.onDemandFailed = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Number of Charge:"])
        {
            self.numberOfCharge = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Hard Reset:"])
        {
            self.numberOfHardReset = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Vibration Count:"])
        {
            self.numberOfVibration = (int) field.value;
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
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;

}
-(void)parseTalliesDataRaw:(NSString*)rawData
{
    self.hoursUsed = [TalliesCommandData getIntValue:rawData startIndex:0 length:4];
    self.beaconConnected = [TalliesCommandData getIntValue:rawData startIndex:4 length:6];
    self.beaconFailed = [TalliesCommandData getIntValue:rawData startIndex:10 length:6];
    self.onDemandConnected = [TalliesCommandData getIntValue:rawData startIndex:16 length:4];
    self.onDemandFailed = [TalliesCommandData getIntValue:rawData startIndex:20 length:4];
    self.numberOfCharge = [TalliesCommandData getIntValue:rawData startIndex:24 length:4];
    self.numberOfHardReset = [TalliesCommandData getIntValue:rawData startIndex:28 length:4];
    self.numberOfVibration = [TalliesCommandData getIntValue:rawData startIndex:48 length:4];

    
    [self updateCommandFieds];

}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Hours Used:"])
        {
            field.value = self.hoursUsed;
        }
        else if([field.fieldname isEqualToString:@"Beacon Connected:"])
        {
            field.value = self.beaconConnected ;
        }
        else if([field.fieldname isEqualToString:@"Beacon Failed:"])
        {
            field.floatValue = self.beaconFailed;
        }
        else if([field.fieldname isEqualToString:@"On-Demand Connected:"])
        {
            field.value = self.onDemandConnected;
        }
        else if([field.fieldname isEqualToString:@"On-Demand Failed:"])
        {
            field.value = self.onDemandFailed;
        }
        else if([field.fieldname isEqualToString:@"Number of Charge:"])
        {
            field.value = self.numberOfCharge;
        }
        else if([field.fieldname isEqualToString:@"Hard Reset:"])
        {
            field.value = self.numberOfHardReset;
        }
        else if([field.fieldname isEqualToString:@"Vibration Count:"])
        {
            field.value = self.numberOfVibration;
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
