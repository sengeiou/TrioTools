//
//  ChargingHistoryCommand.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/12/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import "ChargingHistoryCommand.h"
#import "Field.h"
#import "Definitions.h"

@implementation ChargingHistoryCommand


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
-(void)parseChargingHistoryDataRaw:(NSString*)rawData
{
    NSLog(@"Raw Data lenght:%lu",(unsigned long)[rawData length]);
    int len = (int) [rawData length]== 34?(int) [rawData length]-2:(int) [rawData length];
    for(int i=0; i<len;)
    {
        Field *field = [[Field alloc] init];
        field.uiControlType = 3;
        
        NSMutableDictionary *chargingHistory = [[NSMutableDictionary alloc] init];
        
        [chargingHistory setObject:[NSNumber numberWithInt:[ChargingHistoryCommand getIntValue:rawData startIndex:i length:2] & 0x3F] forKey:@"year"];
        [chargingHistory setObject:[NSNumber numberWithInt:[ChargingHistoryCommand getIntValue:rawData startIndex:i+2 length:2] & 0x3F] forKey:@"month"];
        [chargingHistory setObject:[NSNumber numberWithInt:[ChargingHistoryCommand getIntValue:rawData startIndex:i+4 length:2] & 0x3F] forKey:@"day"];
        [chargingHistory setObject:[NSNumber numberWithInt:[ChargingHistoryCommand getIntValue:rawData startIndex:i+6 length:2] & 0x3F] forKey:@"hour"];
        [chargingHistory setObject:[NSNumber numberWithInt:[ChargingHistoryCommand getIntValue:rawData startIndex:i+8 length:2]] forKey:@"min"];
        [chargingHistory setObject:[NSNumber numberWithInt:[ChargingHistoryCommand getIntValue:rawData startIndex:i+10 length:2]] forKey:@"batLevelPlug"];
        [chargingHistory setObject:[NSNumber numberWithInt:[ChargingHistoryCommand getIntValue:rawData startIndex:i+12 length:2]] forKey:@"duration"];
        [chargingHistory setObject:[NSNumber numberWithInt:[ChargingHistoryCommand getIntValue:rawData startIndex:i+14 length:2]] forKey:@"batLevelUnPlug"];
        
        field.objectValue = chargingHistory;
        
        [self.commandFields.fields addObject:field];
        
        i+=16;
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
