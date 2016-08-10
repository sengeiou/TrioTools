//
//  StepData.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/25/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "StepData.h"

#import "Utilities.h"
#import "Field.h"
#import "Definitions.h"

#define READ_COMMAND_SIZE           3

@implementation StepData

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

        self.stepsData = [[StepDataDaily alloc] init];
   
        [self initializeFields];
    }
    return self;
}

-(void)initializeFields
{
    self.commandPrefix = self.commandFields.commandPrefix;
    self.writeCommandID = self.commandFields.writeCommandID;
    self.readCommandID = self.commandFields.readCommandID;
}

-(NSData*)getCommands
{
    int commandLen = 0;
    unsigned char * buffer = nil;
    if(self.commandFields.readCommandID == READ_STEPS_DATA_BY_HOUR_RANGE)
    {
        commandLen = READ_COMMAND_SIZE + 6;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.readCommandID;
        buffer[2] = ((Field*)[self.commandFields.fields objectAtIndex:2]).value | 0xC0;
        buffer[3] = ((Field*)[self.commandFields.fields objectAtIndex:0]).value | 0xC0;
        buffer[4] = ((Field*)[self.commandFields.fields objectAtIndex:1]).value | 0xC0;
        buffer[5] = ((Field*)[self.commandFields.fields objectAtIndex:3]).value;
        buffer[6] = ((Field*)[self.commandFields.fields objectAtIndex:4]).value;
        buffer[7] = ((Field*)[self.commandFields.fields objectAtIndex:5]).value;
        buffer[8] = ((Field*)[self.commandFields.fields objectAtIndex:6]).value;
    }
    else if(self.commandFields.readCommandID == READ_STEPS_DATA_CURRENT_HOUR)
    {
        commandLen = READ_COMMAND_SIZE;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.readCommandID;
        buffer[2] = ((Field*)[self.commandFields.fields objectAtIndex:0]).value;
    }
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    return command;
}


-(void)parseFT900StepsData:(NSString*)rawData tableInfo:(StepTable*)tableData
{
    StepDataDaily *dailyStepData = [[StepDataDaily alloc] init];
    
    int totalSteps = 0;
    NSMutableString *rawDataToLog = [[NSMutableString alloc] init];
    dailyStepData.yearNumber = [NSString stringWithFormat:@"%d",([StepData getIntValue:rawData startIndex:0 length:2] & 0x3F)];
    dailyStepData.monthNumber = [NSString stringWithFormat:@"%d",([StepData getIntValue:rawData startIndex:2 length:2] & 0x3F)];
    dailyStepData.dayNumber = [NSString stringWithFormat:@"%d",([StepData getIntValue:rawData startIndex:4 length:2] & 0x3F)];
    dailyStepData.frequencyUsed = [StepData getIntValue:rawData startIndex:6 length:2];
    dailyStepData.dailyRaw = [NSMutableString stringWithString:rawData];
    [rawDataToLog appendString:[NSString stringWithFormat:@"Step Date: %@ %@, 20%@\n",[Utilities getMonthDescription: [dailyStepData.monthNumber intValue]],dailyStepData.dayNumber, dailyStepData.yearNumber]];
    
    int startHourNumber = tableData.tableFlag;
    for (int i=8; i<=[rawData length]-13; )
    {
        NSString *minuteRawData = [rawData substringWithRange:NSMakeRange(i, 120)];
        
        NSMutableArray *minuteStepsData = [[NSMutableArray alloc] init];
        int hourlyTotalSteps = 0;
        for(int j=0; j< [minuteRawData length];)
        {
            StepDataPerMinute *minuteData = [[StepDataPerMinute alloc] init];
            minuteData.minutesRaw = [minuteRawData substringWithRange:NSMakeRange(j, 2)];
            minuteData.minuteNumber = j/2;
            minuteData.steps=[StepData getIntValue:minuteRawData startIndex:j length:2];
            totalSteps += minuteData.steps;
            hourlyTotalSteps += minuteData.steps;
            [minuteStepsData addObject:minuteData];
            j+=2;
        }
        //NSLog(@"Hour number:%d", (i/120)+1);
        StepDataHourly *hourlyData = [[StepDataHourly alloc] init];
        hourlyData.hourNumber = [NSString stringWithFormat:@"%.2d", startHourNumber++];
        hourlyData.hourlyRaw = minuteRawData;
        hourlyData.totalHourlySteps = hourlyTotalSteps;
        hourlyData.minuteData = [NSArray arrayWithArray:minuteStepsData];
        [dailyStepData.hourlyData addObject:hourlyData];
        
        [rawDataToLog appendString:[NSString stringWithFormat:@"Hour#%@-> %@\n",hourlyData.hourNumber, minuteRawData]];
        i+=120;
    }
    dailyStepData.totalSteps = totalSteps;
    //return dailyStepData;
}

-(void)parseStepsData:(NSString*)rawData
{
    int hourlyDataLength = 128;
    if(self.deviceInfo.model == PE932 || self.deviceInfo.model == PE936 || self.deviceInfo.model == PE939 || (self.deviceInfo.model == PE961 && self.deviceInfo.firmwareVersion <5.0f))
    {
        hourlyDataLength = 248;
    }
    
    int hourNumber,dayNum,monthNum,yearNum;
    hourNumber = dayNum = monthNum = yearNum = 0;
    
    int tSteps, tKcal;
    tSteps = tKcal = 0;
    int hourCount = 1;
    int hourlySteps = 0;
    int hourlyCal = 0;

    for(int i=0; i< [rawData length];)
    {
        hourlySteps = 0;
        hourlyCal = 0;
        //check remaining data length if greater or equal to hourly length
        hourlyDataLength = ((int)[rawData length]) - i >= hourlyDataLength?hourlyDataLength:((int)[rawData length] - i)-1;
        
        if((hourlyDataLength%248) == 0 || (hourlyDataLength%128)==0)
        {
            NSString *hourlyRaw = [rawData substringWithRange:NSMakeRange(i, hourlyDataLength)];
            //NSLog(@"Hourly length: %d", (int)[hourlyRaw length]);
            
            //First byte is the year Number
            NSString * yearNumberDataRaw = [[hourlyRaw substringWithRange:NSMakeRange(0, 2)] uppercaseString];
            yearNum = ([StepData getYearNumber:yearNumberDataRaw]  & 0x3F);
            
            //2nd byte is the Month Number
            NSString *monthNumberDataRaw = [[hourlyRaw substringWithRange:NSMakeRange(2, 2)] uppercaseString];
            monthNum = ([StepData getMonthNumber:monthNumberDataRaw]  & 0x3F);
            
            //3rd byte is the Day Number
            NSString *dayNumberDataRaw = [[hourlyRaw substringWithRange:NSMakeRange(4, 2)] uppercaseString];
            dayNum = ([StepData getDayNumber:dayNumberDataRaw]  & 0x3F);
            
            if(i!=0)
            {
                if(yearNum != [self.stepsData.yearNumber intValue] || monthNum != [self.stepsData.monthNumber intValue] || dayNum != [self.stepsData.dayNumber intValue])
                {
                    self.stepsData.totalKcal = tKcal;
                    self.stepsData.totalSteps = tSteps;

                    tSteps = tKcal = 0;
                    hourCount = 1;
                }
            }
            
            //4th byte is the Hour Number
            NSString *hourNumberDataRAw = [[hourlyRaw substringWithRange:NSMakeRange(6, 2)] uppercaseString];
            hourNumber = ([StepData getHourNumber:hourNumberDataRAw]  & 0x3F);
            
            //Set Minutes data(s)
            NSString *minutesRaw = [[hourlyRaw substringWithRange:NSMakeRange(8, [hourlyRaw length]-8)] uppercaseString];
            
            //NSLog(@"Minute length: %d", (int)[minutesRaw length]);
            NSArray *minutesData =  [[NSArray alloc] init];
            if(self.deviceInfo.model == PE932 || self.deviceInfo.model == PE936 || self.deviceInfo.model == PE939 || (self.deviceInfo.model == PE961 && self.deviceInfo.firmwareVersion <5.0f))
            {
                minutesData = [StepData getMinutesDataWithKCal:minutesRaw];
            }
            else
            {
                minutesData = [StepData getMinutesDataWithoutKCal:minutesRaw];
            }
            for(StepDataPerMinute *minutes in minutesData)
            {
                tSteps += [minutes steps];
                tKcal += [minutes calories];
                hourlySteps +=[minutes steps];
                hourlyCal += [minutes calories];
            }
            //Set Hourly data(s)
            StepDataHourly *hourly = [[StepDataHourly alloc] init];
            hourly.hourlyRaw = hourlyRaw;
            [hourly setHourNumber:[NSString stringWithFormat:@"%d",hourNumber]];
            [hourly setMinuteData:minutesData];
            [hourly setTotalHourlySteps:hourlySteps];
            [hourly setTotalHourlyCal:hourlyCal];
            
            //set daily steps Data
            self.stepsData.dayNumber = [NSString stringWithFormat:@"%d",dayNum];
            self.stepsData.monthNumber = [NSString stringWithFormat:@"%d",monthNum];
            self.stepsData.yearNumber = [NSString stringWithFormat:@"%d",yearNum];
            [self.stepsData.dailyRaw appendString:hourlyRaw];
            [self.stepsData.hourlyData addObject:hourly];
            
            Field *hourlyField = [[Field alloc] init];
            hourlyField.objectValue = hourly;
            hourlyField.uiControlType = 3;
            
            [self.commandFields.fields addObject:hourlyField];
            
            hourCount++;
            i+=hourlyDataLength;
        }
        else
        {
            //break, no more data
            break;
        }
    }
}


+(int)getYearNumber:(NSString*)yearRawData
{
    unsigned int yearNumber;
    NSScanner *toDecimal = [NSScanner scannerWithString:yearRawData];
    [toDecimal scanHexInt:&yearNumber];
    
    return yearNumber;
}

+(int)getMonthNumber:(NSString*)monthRawData
{
    unsigned int monthNumber;
    NSScanner *toDecimal = [NSScanner scannerWithString:monthRawData];
    [toDecimal scanHexInt:&monthNumber];
    
    return monthNumber;
}

+(int)getDayNumber:(NSString*)dayRawData
{
    unsigned int dayNumber;
    NSScanner *toDecimal = [NSScanner scannerWithString:dayRawData];
    [toDecimal scanHexInt:&dayNumber];
    
    return dayNumber;
}

+(int)getHourNumber:(NSString*)hourRawData
{
    unsigned int hourNumber;
    NSScanner *toDecimal = [NSScanner scannerWithString:hourRawData];
    [toDecimal scanHexInt:&hourNumber];
    
    return hourNumber;
}

+(NSArray*)getMinutesDataWithoutKCal:(NSString*)hourlyRawData
{
    NSScanner *toDecimal = nil;
    NSMutableArray *minutesDataArray =[[NSMutableArray alloc] init];
    unsigned int steps, calories;
    steps = calories = 0;
    int minutesDataLength = 2;
    int minuteNumber = 0;
    for(int i=0; i<[hourlyRawData length];)
    {
        StepDataPerMinute *minuteData = [[StepDataPerMinute alloc] init];
        NSString *stepsRaw = [[hourlyRawData substringWithRange:NSMakeRange(i, 2)] uppercaseString];
        toDecimal = [NSScanner scannerWithString:stepsRaw];
        [toDecimal scanHexInt:&steps];
        
        
        minuteData.minutesRaw = [[hourlyRawData substringWithRange:NSMakeRange(i, 2)] uppercaseString];
        minuteData.minuteNumber = minuteNumber;
        minuteData.steps = steps;
        minuteData.calories = calories;
        
        [minutesDataArray addObject:minuteData];
        
        minuteNumber++;
        i+=minutesDataLength;
    }
    
    return minutesDataArray;
}

+(NSArray*)getMinutesDataWithKCal:(NSString*)hourlyRawData
{
    NSScanner *toDecimal = nil;
    NSMutableArray *minutesDataArray =[[NSMutableArray alloc] init];
    unsigned int steps, calories;
    steps = calories = 0;
    int minutesDataLength = 4;
    int minuteNumber = 0;
    for(int i=0; i<[hourlyRawData length];)
    {
        StepDataPerMinute *minuteData = [[StepDataPerMinute alloc] init];
        NSString *stepsRaw = [[hourlyRawData substringWithRange:NSMakeRange(i, 2)] uppercaseString];
        toDecimal = [NSScanner scannerWithString:stepsRaw];
        [toDecimal scanHexInt:&steps];
        
        NSString *caloriesRaw = [[hourlyRawData substringWithRange:NSMakeRange(i+2, 2)] uppercaseString];
        toDecimal = [NSScanner scannerWithString:caloriesRaw];
        [toDecimal scanHexInt:&calories];
        
        minuteData.minutesRaw = [[hourlyRawData substringWithRange:NSMakeRange(i, 4)] uppercaseString];
        minuteData.minuteNumber = minuteNumber;
        minuteData.steps = steps;
        minuteData.calories = calories;
        
        [minutesDataArray addObject:minuteData];
        
        minuteNumber++;
        i+=minutesDataLength;
    }
    
    return minutesDataArray;
}

+(int) getIntValue:(NSString *) data startIndex:(int) startIndex length:(int) length
{
    unsigned int value;
    
    NSScanner *toDecimal = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(startIndex, length)]];
    [toDecimal scanHexInt:&value];
    return value;
}

@end
