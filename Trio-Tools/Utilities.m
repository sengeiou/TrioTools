//
//  Utilities.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/25/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "Utilities.h"



@implementation Utilities

+(int)getMonthIntValue:(NSString*)monthDescription
{
    int monthVal = 0;
    if([[monthDescription lowercaseString] isEqualToString:@"jan"])
    {
        monthVal = 1;
    }
    else if([[monthDescription lowercaseString] isEqualToString:@"feb"])
    {
        monthVal = 2;
    }
    else if([[monthDescription lowercaseString] isEqualToString:@"mar"])
    {
        monthVal = 3;
    }
    else if([[monthDescription lowercaseString] isEqualToString:@"apr"])
    {
        monthVal = 4;
    }
    else if([[monthDescription lowercaseString] isEqualToString:@"may"])
    {
        monthVal = 5;
    }
    else if([[monthDescription lowercaseString] isEqualToString:@"june"])
    {
        monthVal = 6;
    }
    else if([[monthDescription lowercaseString] isEqualToString:@"july"])
    {
        monthVal = 7;
    }
    else if([[monthDescription lowercaseString] isEqualToString:@"aug"])
    {
        monthVal = 8;
    }
    else if([[monthDescription lowercaseString] isEqualToString:@"sep"])
    {
        monthVal = 9;
    }
    else if([[monthDescription lowercaseString] isEqualToString:@"oct"])
    {
        monthVal = 10;
    }
    else if([[monthDescription lowercaseString] isEqualToString:@"nov"])
    {
        monthVal = 11;
    }
    else if([[monthDescription lowercaseString] isEqualToString:@"dec"])
    {
        monthVal = 12;
    }
    else
    {
        monthVal = 0;
    }
    return monthVal;
}

+(NSString*)getMonthDescription:(int)monthNumber
{
    NSString *month = [[NSString alloc]init];
    switch (monthNumber) {
        case 1:
            month = @"Jan";
            break;
        case 2:
            month = @"Feb";
            break;
        case 3:
            month = @"Mar";
            break;
        case 4:
            month = @"Apr";
            break;
        case 5:
            month = @"May";
            break;
        case 6:
            month = @"June";
            break;
        case 7:
            month = @"July";
            break;
        case 8:
            month = @"Aug";
            break;
        case 9:
            month = @"Sep";
            break;
        case 10:
            month = @"Oct";
            break;
        case 11:
            month = @"Nov";
            break;
        case 12:
            month = @"Dec";
            break;
        default:
            month = @"(0)invalid";
            break;
    }
    return month;
}

+(void)Log:(NSString*)filename info:(NSString*)data
{
    NSDate *now = [NSDate date];
    NSString *filenameStr = filename;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
    NSString *csvFilename = [NSString stringWithFormat:@"%.2ld-%.2ld-%ld %.2ld-%.2ld-%.2ld %@", (long)[components month],(long)[components day], (long)[components year], (long)[components hour], (long)[components minute], (long)[components second],filenameStr];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:csvFilename];
    
    if(![data writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL])
    {
        NSLog(@"Failed to write to file.");
    }
    else
    {
        NSLog(@"Log successfully created.");
    }
}

+(NSData*)convertHexStringToNSData:(NSString*)hextString
{
    NSMutableData *data= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    for (int i = 0; i < ([hextString length] / 2); i++) {
        // NSLog(@"Hex string %c at index:%d",[hextString characterAtIndex:i*2],i*2);
        // NSLog(@"Hex string %c at index:%d",[hextString characterAtIndex:i*2+1],i*2+1);
        byte_chars[0] = [hextString characterAtIndex:i*2];
        byte_chars[1] = [hextString characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
        //NSLog(@"Data Bytes %x",whole_byte);
    }
    
    return data;
}

+(int)computeCheckSum32:(NSData*)data
{
    //byte[] byteToCalculate = Encoding.ASCII.GetBytes(dataToCalculate);
    NSUInteger len = [data length];
    Byte *reportData = (Byte*)malloc(len);
    memcpy(reportData, [data bytes], len);
    
    int checksum = 0;
    
    for (int i =0; i<len; i++)
    {
        //NSLog(@"index %d %x",i,reportData[i]);
        checksum += reportData[i];
    }
    checksum &= 0xffffffff;
    
    return checksum;
}

+(NSString *)ConvertStringToHexString:(NSString*)inputString
{
    NSString * hexStr = [NSString stringWithFormat:@"%@",
                         [NSData dataWithBytes:[inputString cStringUsingEncoding:NSUTF8StringEncoding]
                                        length:strlen([inputString cStringUsingEncoding:NSUTF8StringEncoding])]];
    
    for(NSString * toRemove in [NSArray arrayWithObjects:@"<", @">", @" ", nil])
        hexStr = [hexStr stringByReplacingOccurrencesOfString:toRemove withString:@""];
    
    return hexStr;
}

@end
