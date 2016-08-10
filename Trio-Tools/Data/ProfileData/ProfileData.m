//
//  ProfileData.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/8/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "ProfileData.h"

#import "Utilities.h"
#import "Field.h"
#import "Definitions.h"

#define READ_PROFILE_DATA_COMMAND_SIZE 10

@implementation ProfileData

@synthesize  startBlock;
@synthesize  endBlock;

@synthesize  profileYear;
@synthesize  profileMonth;
@synthesize  profileDay;
@synthesize  profileHour;
@synthesize  profileMin;

@synthesize profileSamplingFrequency;
@synthesize profileSamplingTime;

@synthesize x_Axis;
@synthesize y_Axis;
@synthesize z_Axis;

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
    
    self.x_Axis = [[NSMutableArray alloc] init];
    self.y_Axis = [[NSMutableArray alloc] init];
    self.z_Axis = [[NSMutableArray alloc] init];
    
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Start Block:"])
        {
            self.startBlock = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"End Block:"])
        {
            self.endBlock = (int) field.value;
        }
    }
}

-(NSData*)getCommands
{
    int commandLen = 0;
    unsigned char * buffer = nil;
    NSDate * selectedDate = (NSDate*) ((Field*)[self.commandFields.fields objectAtIndex:0]).objectValue;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:selectedDate];

    commandLen = READ_PROFILE_DATA_COMMAND_SIZE;
    buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
    buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
    buffer[1] = self.readCommandID;
    buffer[2] = (dateComponents.year - 2000) | 0xC0;
    buffer[3] = dateComponents.month | 0xC0;
    buffer[4] = dateComponents.day | 0xC0;
    buffer[5] = dateComponents.hour | 0xC0;
    buffer[6] = dateComponents.minute;
    buffer[7] = ((Field*)[self.commandFields.fields objectAtIndex:1]).value;
    buffer[8] = ((Field*)[self.commandFields.fields objectAtIndex:2]).value;
    buffer[9] = ((Field*)[self.commandFields.fields objectAtIndex:3]).value;
    
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
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    return command;
}

-(void)parseProfileData:(NSString*)rawData
{
    self.startBlock = [ProfileData getIntValue:rawData startIndex:6 length:2];
    self.endBlock = [ProfileData getIntValue:rawData startIndex:8 length:2];
    self.profileYear = [ProfileData getIntValue:rawData startIndex:10 length:2] & 0x3F;
    self.profileMonth = [ProfileData getIntValue:rawData startIndex:12 length:2] & 0x3F;
    self.profileDay = [ProfileData getIntValue:rawData startIndex:14 length:2] & 0x3F;
    self.profileHour = [ProfileData getIntValue:rawData startIndex:16 length:2] & 0x3F;
    self.profileMin = [ProfileData getIntValue:rawData startIndex:18 length:2];
    self.profileSamplingFrequency = [ProfileData getIntValue:rawData startIndex:20 length:2];
    self.profileSamplingTime = [ProfileData getIntValue:rawData startIndex:22 length:4];
    
    //int axisLen = ((int)[rawData length] - 26) /6;
    int dataLen = ((self.profileSamplingTime * self.profileSamplingFrequency * 3 * self.endBlock) / 64)  * 2;   //axisLen * 6;
    int signatureLen = 6;
    NSString *signatureRaw = [rawData substringWithRange:NSMakeRange(26, dataLen)];
    Field *field = [[Field alloc] init];
    field.uiControlType = 5;
    for(int i=0; (i+signatureLen) <= [signatureRaw length];)
    {
        /*
        if(i==0)
        {
            field.fieldname = @"Profile data Header";
            field.objectValue = @"   X-Axis \t\t\t Y-Axis \t\t\t Z-Axis";
            [self.commandFields.fields addObject:field];
            field = [[Field alloc] init];
            field.uiControlType = 2;
        }*/
        [self.x_Axis addObject:[NSString stringWithFormat:@"%d", [ProfileData getIntValue:signatureRaw startIndex:i length:2]]];
        [self.y_Axis addObject:[NSString stringWithFormat:@"%d", [ProfileData getIntValue:signatureRaw startIndex:i+2 length:2]]];
        [self.z_Axis addObject:[NSString stringWithFormat:@"%d", [ProfileData getIntValue:signatureRaw startIndex:i+4 length:2]]];
        field.objectValue = [NSString stringWithFormat:@"\t%d \t\t\t   %d \t\t\t   %d",[ProfileData getIntValue:signatureRaw startIndex:i length:2],[ProfileData getIntValue:signatureRaw startIndex:i+2 length:2],[ProfileData getIntValue:signatureRaw startIndex:i+4 length:2]];
        
        i+=signatureLen;
    }
    NSDictionary *axisData = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.x_Axis,self.y_Axis,self.z_Axis,nil] forKeys:[NSArray arrayWithObjects:@"xaxis",@"yaxis",@"zaxis",nil]];
    
    field.objectValue = axisData;
    [self.commandFields.fields addObject:field];
    
    [self LogParsedSignatureData];
    
     [self updateCommandFieds];
}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Profile Date/Time:"])
        {
            NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
            
            outputFormatter.dateFormat = @"MM-dd-yyyy   HH:mm";
            NSString *dateStr = [NSString stringWithFormat:@"%.2d-%.2d-%.4d    %.2d:%.2d",self.profileMonth,self.profileDay,self.profileYear,self.profileHour,self.profileMin];
            NSDate *readDate = [outputFormatter dateFromString:dateStr];
            field.objectValue = readDate;
        }
        else if([field.fieldname isEqualToString:@"Start Block:"])
        {
            field.value = self.startBlock;
        }
        else if([field.fieldname isEqualToString:@"End Block:"])
        {
            field.value = self.endBlock;
        }
    }
}

-(void)LogParsedSignatureData
{
    NSMutableString *parsedData = [[NSMutableString alloc] init];
    NSString *ampm = self.profileHour>12?@"PM":@"AM";
    int hourNo = self.profileHour>12?self.profileHour-12:self.profileHour;
    [parsedData appendString:[NSString stringWithFormat: @"Profile Sampling Frquency: %d",self.profileSamplingFrequency]];
    [parsedData appendString:[NSString stringWithFormat: @"\nDate: %@ %.2d, %.2d",[Utilities getMonthDescription:self.profileMonth],self.profileDay, self.profileYear +2000]];
    [parsedData appendString:[NSString stringWithFormat: @"\nTime: %.2d:%.2d %@",hourNo, self.profileMin, ampm]];
    [parsedData appendString:@"\nX-Axis,Y-Axis,Z-Axis,Magnitude\n"];
    for(int i=0; i<[self.x_Axis count]; i++)
    {
        int x = [[self.x_Axis objectAtIndex:i] intValue];
        int y = [[self.y_Axis objectAtIndex:i] intValue];
        int z = [[self.z_Axis objectAtIndex:i] intValue];
        int magnitude = (x*x) + (y*y) + (z*z);
        [parsedData appendString:[NSString stringWithFormat:@"%@,",[self.x_Axis objectAtIndex:i]]];
        [parsedData appendString:[NSString stringWithFormat:@"%@,",[self.y_Axis objectAtIndex:i]]];
        [parsedData appendString:[NSString stringWithFormat:@"%@,",[self.z_Axis objectAtIndex:i]]];
        [parsedData appendString:[NSString stringWithFormat:@"%d\n", magnitude]];
        
    }
    
    NSString *profilePrefixFilename = @"PROFILE.csv";
    
    [Utilities Log:profilePrefixFilename info:parsedData];
}


+(int) getIntValue:(NSString *) data startIndex:(int) startIndex length:(int) length
{
    unsigned int value;
    
    NSScanner *toDecimal = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(startIndex, length)]];
    [toDecimal scanHexInt:&value];
    return value;
}


@end
