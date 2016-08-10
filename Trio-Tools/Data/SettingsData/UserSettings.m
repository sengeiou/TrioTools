//
//  UserSettings.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/18/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "UserSettings.h"
#import "Field.h"
#import "Definitions.h"




@implementation UserSettings

@synthesize userRMR;
@synthesize userDeviceUnitOfMeasure;
@synthesize userStride;
@synthesize userWeightWhole;
@synthesize userWeightDecimal;

@synthesize userDOBmonth;
@synthesize userDOBday;
@synthesize userDOByear;
@synthesize userAge;

@synthesize screenInvertSettings;

@synthesize userAutoRotateSettings;
@synthesize userScreenOrientation;
@synthesize userWristPreference;

@synthesize commandAction;
@synthesize commandPrefix;
@synthesize writeCommandID;
@synthesize readCommandID;

@synthesize deviceInfo;
@synthesize commandFields;

@synthesize expectedResponseSize;


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
        if([field.fieldname isEqualToString:@"Member RMR:"])
        {
            self.userRMR =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Stride:"])
        {
            self.userStride =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Unit of Measure:"])
        {
            self.userDeviceUnitOfMeasure = field.value;
        }
        else if([field.fieldname isEqualToString:@"Weight Whole:"])
        {
            self.userWeightWhole =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Weight Decimal:"])
        {
            self.userWeightDecimal =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Year of Birth:"])
        {
            self.userDOByear =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Month of Birth:"])
        {
            self.userDOBmonth =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Day of Birth:"])
        {
            self.userDOBday =(int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Screen Invert Setting:"])
        {
            self.screenInvertSettings =(int) field.value;
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
        if(self.deviceInfo.model == FT900 || self.deviceInfo.model == FT969 || self.deviceInfo.model == FT905)
        {
            commandLen =FT900_COMMAND_LEN;
            buffer = (unsigned char*) calloc(FT900_COMMAND_LEN,sizeof(unsigned char));
            buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
            buffer[1] = 0x18; //command code
            buffer[2] = self.userStride;
            buffer[3] = (self.userWeightWhole >> 8) & 0xFF;
            buffer[4] = self.userWeightWhole & 0xFF;
            buffer[5] = self.userWeightDecimal;
            buffer[6] = (self.userRMR >> 8) & 0xFF;
            buffer[7] = self.userRMR & 0xFF;
            buffer[8] = self.userDeviceUnitOfMeasure & 0x01;
            buffer[9] = self.userDOByear;
            buffer[10] = self.userDOBmonth;
            buffer[11] = self.userDOBday;
        }
        else if(self.deviceInfo.model == 961)
        {
            if(self.deviceInfo.firmwareVersion < 1.4f)
            {
                commandLen =PE961_COMMAND_LEN1;
                buffer = (unsigned char*) calloc(PE961_COMMAND_LEN1,sizeof(unsigned char));
                buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
                buffer[1] = 0x18; //command code
                buffer[2] = self.userStride;
                buffer[3] = (self.userWeightWhole >> 8) & 0xFF;
                buffer[4] = self.userWeightWhole & 0xFF;
                buffer[5] = self.userWeightDecimal;
                buffer[6] = (self.userRMR >> 8) & 0xFF;
                buffer[7] = self.userRMR & 0xFF;
                buffer[8] = self.userDeviceUnitOfMeasure & 0x01;
                buffer[9] = self.userDOByear;
                buffer[10] = self.userDOBmonth;
                buffer[11] = self.userDOBday;
                buffer[12] = self.userAge;
            }
            else
            {
                commandLen =PE961_COMMAND_LEN2;
                buffer = (unsigned char*) calloc(PE961_COMMAND_LEN2,sizeof(unsigned char));
                buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
                buffer[1] = 0x18; //command code
                buffer[2] = self.userStride;
                buffer[3] = (self.userWeightWhole >> 8) & 0xFF;
                buffer[4] = self.userWeightWhole & 0xFF;
                buffer[5] = self.userWeightDecimal;
                buffer[6] = (self.userRMR >> 8) & 0xFF;
                buffer[7] = self.userRMR & 0xFF;
                buffer[8] = self.userDeviceUnitOfMeasure & 0x01;
                buffer[9] = self.userDOByear;
                buffer[10] = self.userDOBmonth;
                buffer[11] = self.userDOBday;
                buffer[12] = self.userAge;
                
                int orientationByte = 0x00;
                orientationByte |= self.userAutoRotateSettings;
                orientationByte |= self.userScreenOrientation?0x02:0x00;
                orientationByte |= self.userWristPreference?0x04:0x00;
                buffer[13] = orientationByte;
            }
        }
        else if(self.deviceInfo.model == FT965)
        {
            commandLen =PE961_COMMAND_LEN2;
            buffer = (unsigned char*) calloc(PE961_COMMAND_LEN2,sizeof(unsigned char));
            buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
            buffer[1] = 0x18; //command code
            buffer[2] = self.userStride;
            buffer[3] = (self.userWeightWhole >> 8) & 0xFF;
            buffer[4] = self.userWeightWhole & 0xFF;
            buffer[5] = self.userWeightDecimal;
            buffer[6] = (self.userRMR >> 8) & 0xFF;
            buffer[7] = self.userRMR & 0xFF;
            buffer[8] = self.userDeviceUnitOfMeasure & 0x01;
            buffer[9] = self.userDOByear;
            buffer[10] = self.userDOBmonth;
            buffer[11] = self.userDOBday;
            
            int orientationByte = 0x00;
            orientationByte |= self.userAutoRotateSettings;
            orientationByte |= self.userScreenOrientation?0x02:0x00;
            orientationByte |= self.userWristPreference?0x04:0x00;
            buffer[12] = orientationByte;
            
        }
        else if(self.deviceInfo.model == FT962)
        {
            commandLen =PE961_COMMAND_LEN1;
            buffer = (unsigned char*) calloc(PE961_COMMAND_LEN1,sizeof(unsigned char));
            buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
            buffer[1] = 0x18; //command code
            buffer[2] = self.userStride;
            buffer[3] = (self.userWeightWhole >> 8) & 0xFF;
            buffer[4] = self.userWeightWhole & 0xFF;
            buffer[5] = self.userWeightDecimal;
            buffer[6] = (self.userRMR >> 8) & 0xFF;
            buffer[7] = self.userRMR & 0xFF;
            buffer[8] = self.userDeviceUnitOfMeasure & 0x01;
            buffer[9] = self.userDOByear;
            buffer[10] = self.userDOBmonth;
            buffer[11] = self.userDOBday;
            
            int orientationByte = 0x00;
            orientationByte |= self.userAutoRotateSettings;
            orientationByte |= self.userScreenOrientation?0x02:0x00;
            orientationByte |= self.userWristPreference?0x04:0x00;
            orientationByte |= (self.screenInvertSettings << 3);
            buffer[12] = orientationByte;

        }
        else
        {
            commandLen =USER_SETTINGS_COMMAND_LEN;
            buffer = (unsigned char*) calloc(USER_SETTINGS_COMMAND_LEN,sizeof(unsigned char));
            buffer[0] = 0x1B; //Command Signature
            buffer[1] = 0x18; //command code
            
            buffer[2] = self.userStride;
            buffer[3] = (self.userWeightWhole >> 8) & 0xFF;
            buffer[4] = self.userWeightWhole & 0xFF;
            buffer[5] = self.userWeightDecimal;
            buffer[6] = (self.userRMR >> 8) & 0xFF;
            buffer[7] = self.userRMR & 0xFF;
            buffer[8] = self.userDeviceUnitOfMeasure & 0x01;
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
        NSLog(@"[9] %X",buffer[9]);
        NSLog(@"[10] %X",buffer[10]);
        NSLog(@"[11] %X",buffer[11]);
        NSLog(@"[12] %X",buffer[12]);
        NSLog(@"[13] %X",buffer[13]);
    }
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    return command;
}

-(void)parseUserSettingsRaw:(NSString*)rawData
{
    self.userStride = [UserSettings getIntValue:rawData startIndex:4 length:2];
    self.userWeightWhole =[UserSettings getIntValue:rawData startIndex:6 length:4];
    self.userWeightDecimal = [UserSettings getIntValue:rawData startIndex:10 length:2];
    self.userRMR = [UserSettings getIntValue:rawData startIndex:12 length:4];
    self.userDeviceUnitOfMeasure = [UserSettings getIntValue:rawData startIndex:16 length:2];
    if(self.deviceInfo.model == 961 || self.deviceInfo.model == 900 || self.deviceInfo.model == FT905 || self.deviceInfo.model == FT969 || self.deviceInfo.model == FT962 || self.deviceInfo.model == FT965)
    {
        self.userDOByear = [UserSettings getIntValue:rawData startIndex:18 length:2];
        self.userDOBmonth = [UserSettings getIntValue:rawData startIndex:20 length:2];
        self.userDOBday = [UserSettings getIntValue:rawData startIndex:22 length:2];
        if(self.deviceInfo.model == 961 && self.deviceInfo.firmwareVersion < 5.0f)
        {
            self.userAge = [UserSettings getIntValue:rawData startIndex:24 length:2];
            if(self.deviceInfo.firmwareVersion >= 1.4f)
            {
                int orientation = [UserSettings getIntValue:rawData startIndex:26 length:2];
                self.userAutoRotateSettings = orientation & 0x01;
                self.userScreenOrientation = ((orientation >> 1) & 0x01);
                self.userWristPreference = (orientation >> 2) & 0x01;
            }
        }
        
        if(self.deviceInfo.model == FT962)
        {
            int orientation = [UserSettings getIntValue:rawData startIndex:24 length:2];
            self.userAutoRotateSettings = orientation & 0x01;
            self.userScreenOrientation = ((orientation >> 1) & 0x01);
            self.userWristPreference = (orientation >> 2) & 0x01;
            self.screenInvertSettings = (orientation >> 3) & 0x03;
        }
    }
    
    [self updateCommandFieds];
}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Member RMR:"])
        {
            field.value = self.userRMR;
        }
        else if([field.fieldname isEqualToString:@"Stride:"])
        {
            field.value = self.userStride;
        }
        else if([field.fieldname isEqualToString:@"Unit of Measure:"])
        {
            field.value = self.userDeviceUnitOfMeasure;
        }
        else if([field.fieldname isEqualToString:@"Weight Whole:"])
        {
            field.value = self.userWeightWhole;
        }
        else if([field.fieldname isEqualToString:@"Weight Decimal:"])
        {
            field.value = self.userWeightDecimal;
        }
        else if([field.fieldname isEqualToString:@"Year of Birth:"])
        {
            field.value = self.userDOByear;
        }
        else if([field.fieldname isEqualToString:@"Month of Birth:"])
        {
            field.value = self.userDOBmonth;
        }
        else if([field.fieldname isEqualToString:@"Day of Birth:"])
        {
            field.value = self.userDOBday;
        }
        else if([field.fieldname isEqualToString:@"Screen Invert Setting:"])
        {
            field.value = self.screenInvertSettings;
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
