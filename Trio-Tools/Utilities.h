//
//  Utilities.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/25/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+(int)getMonthIntValue:(NSString*)monthDescription;
+(NSString*)getMonthDescription:(int)monthNumber;
+(void)Log:(NSString*)filename info:(NSString*)data;

+(NSString *)ConvertStringToHexString:(NSString*)inputString;
+(NSData*)convertHexStringToNSData:(NSString*)hextString;
+(int)computeCheckSum32:(NSData*)data;

@end
