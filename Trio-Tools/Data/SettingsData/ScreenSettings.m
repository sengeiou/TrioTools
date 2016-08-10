//
//  ScreenSettings.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/25/15.
//  Copyright © 2015 Fortify Technologies. All rights reserved.
//

#import "ScreenSettings.h"

#import "Field.h"
#import "Definitions.h"

#define READ_COMMAND_SIZE               2
#define SCREEN_COMMAND_SIZE            10
#define SCREEN_COMMAND_SIZE2           13

@implementation ScreenSettings

@synthesize numberOfScreens;

@synthesize scr1;
@synthesize scr2;
@synthesize scr3;
@synthesize scr4;
@synthesize scr5;
@synthesize scr6;
@synthesize scr7;
@synthesize scr8;
@synthesize scr9;
@synthesize scr10;
@synthesize scr12;
@synthesize scr13;
@synthesize scr14;
@synthesize scr15;

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
        if([field.fieldname isEqualToString:@"No of Screens:"])
        {
            self.numberOfScreens =(int) field.value;
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
        commandLen = ((self.deviceInfo.model==PE961 && self.deviceInfo.firmwareVersion >=5.0f)|| self.deviceInfo.model == FT962)?SCREEN_COMMAND_SIZE2:SCREEN_COMMAND_SIZE;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.writeCommandID;
        
        int index = 2;
        int value = 0;
        for (int i=1; i<[self.commandFields.fields count]; i++)
        {
            BOOL willIncrementIndex = YES;
            if(i%2!=0)
            {
                value = 0;
                willIncrementIndex = NO;
            }
            Field *field = (Field*) [self.commandFields.fields objectAtIndex:i];
            
            if(willIncrementIndex)
            {
                value |= ((int)field.value << 4);
                
                buffer[index++] = value;
            }
            else
            {
                value = (int)field.value;
                
                if(i == [self.commandFields.fields count]-1)
                {
                    
                    buffer[index++] = value;
                }
            }
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
        
    }
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    return command;
}
-(void)parseScreenSettingsRaw:(NSString*)rawData
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (int i=1; i < [self.commandFields.fields count]; i++)
    {
        [indexSet addIndex:i];
    }
    [self.commandFields.fields removeObjectsAtIndexes:indexSet];
    
    NSString *screenSettings = [rawData substringFromIndex:4];
    for(int i=0; i< [screenSettings length];)//iterate through screen no. arrays [1,2,3,4,5,6,7]
    {
        int screenNumber1 = [[screenSettings substringWithRange:NSMakeRange(i+1, 1)] intValue];
        int screenNumber2 = [[screenSettings substringWithRange:NSMakeRange(i, 1)] intValue];
        
        if(screenNumber1 == 0)
        {
            break;
        }
        
        Field *field = [[Field alloc] init];
        field.uiControlType = 0;
        field.textfieldKeyboardType = 50;
        field.value = screenNumber1;
        field.fieldname = [self getScreenName:i+1];
        [self.commandFields.fields addObject:field];
        

        field = [[Field alloc] init];
        field.uiControlType = 0;
        field.textfieldKeyboardType = 50;
        field.value = screenNumber2;
        field.fieldname = [self getScreenName:i+2];
        [self.commandFields.fields addObject:field];
        
        if(screenNumber2 == 0)
        {
            break;
        }
        
        i+=2;
    }
    
    Field *field = (Field*)[self.commandFields.fields objectAtIndex:0];
    
    field.value = [self.commandFields.fields count]-1;
    
    [self.commandFields.fields replaceObjectAtIndex:0 withObject:field];

    [self updateCommandFieds];
}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Sampling Time:"])
        {
            field.value = self.numberOfScreens;
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


-(NSString*)getScreenName:(int)value
{
    NSString *name = [[NSString alloc] init];
    switch (value)
    {
        case 1:
            name = @"First Screen:";
            break;
        case 2:
            name = @"Second Screen:";
            break;
        case 3:
            name = @"Third Screen:";
            break;
        case 4:
            name = @"Fourth Screen:";
            break;
        case 5:
            name = @"Fifth Screen:";
            break;
        case 6:
            name = @"Sixth Screen:";
            break;
        case 7:
            name = @"Seventh Screen:";
            break;
        case 8:
            name = @"Eight Screen:";
            break;
        case 9:
            name = @"Ninth Screen:";
            break;
        case 10:
            name = @"Tenth Screen:";
            break;
        case 11:
            name = @"Eleventh Screen:";
            break;
        case 12:
            name = @"Twelfth Screen:";
            break;
        case 13:
            name = @"Thirteenth Screen:";
            break;
        case 14:
            name = @"Fourteenth Screen:";
            break;
        case 15:
            name = @"Fifteenth Screen:";
            break;
        default:
            break;
    }
    
    return name;
}


@end
