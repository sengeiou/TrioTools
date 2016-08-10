//
//  ProfileTableHeader.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/8/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "ProfileTableHeader.h"
#import "Field.h"
#import "Definitions.h"

#define READ_COMMAND_SIZE           2
#define UPDATE_PROFILE_TABLE_DATA_SIZE      10

@implementation ProfileTableHeader

@synthesize selectedFieldIndex;

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
        if(!action)
        {//clear all fields when performing read table
            [self.commandFields.fields removeAllObjects];
        }
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
    if(self.commandAction==0)
    {
        commandLen = READ_COMMAND_SIZE;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.readCommandID;
    }
    else
    {
        commandLen = UPDATE_PROFILE_TABLE_DATA_SIZE;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.writeCommandID;
    }
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}

-(void)parseProfileBlocksFlagData:(NSString*)rawData
{
    //rawData = @"d4cbdec523000000000000000000000fff";
    
    for(int i=0; i<[rawData length]; )
    {
        Field *field = [[Field alloc] init];
        field.uiControlType = 2;
        
        ProfileTable *profileBlocksTable = [[ProfileTable alloc] init];
        
        NSString *profileTableStr = [rawData substringWithRange:NSMakeRange(i, 26)];
        
        profileBlocksTable.profileYear = [ProfileTableHeader getIntValue:profileTableStr startIndex:0 length:2] & 0x3f;
        profileBlocksTable.profileMonth = [ProfileTableHeader getIntValue:profileTableStr startIndex:2 length:2] & 0x3f;
        profileBlocksTable.profileDay = [ProfileTableHeader getIntValue:profileTableStr startIndex:4 length:2] & 0x3f;
        profileBlocksTable.profileHour = [ProfileTableHeader getIntValue:profileTableStr startIndex:6 length:2] & 0x3f;
        profileBlocksTable.profileMin = [ProfileTableHeader getIntValue:profileTableStr startIndex:8 length:2] & 0x3f;
        profileBlocksTable.profileDataBlocksFlagPerByteArray = [[NSMutableArray alloc] init];
        profileBlocksTable.profileDataBlocksFlagArray = [[NSMutableArray alloc] init];
        
        for (int i=10; i<26;)
        {
            int byteValue = [ProfileTableHeader getIntValue:profileTableStr startIndex:i length:2];
            [profileBlocksTable.profileDataBlocksFlagPerByteArray addObject:[NSString stringWithFormat:@"%d",byteValue]];
            i+=2;
        }
        
        for(int i = (int)[profileBlocksTable.profileDataBlocksFlagPerByteArray count]-1; i>=0; i--)
        {
            for(int j=1; j<=8; j++)
            {
                int byteData, flag;
                byteData =[[profileBlocksTable.profileDataBlocksFlagPerByteArray objectAtIndex:i] intValue];
                flag = (byteData >> (j-1)) & 1;
                [profileBlocksTable.profileDataBlocksFlagArray addObject:[NSString stringWithFormat:@"%d",flag]];
            }
        }
        i+=26;
        if((profileBlocksTable.profileYear == 63 && profileBlocksTable.profileMonth == 63 && profileBlocksTable.profileDay == 63 ) ||
           (profileBlocksTable.profileYear == 0 && profileBlocksTable.profileMonth == 0 && profileBlocksTable.profileDay ==0))
        {
            //set to nil if invalid dates
            profileBlocksTable = nil;
            
            continue;
        }

        
        if(profileBlocksTable)
        {
            field.fieldname = [NSString stringWithFormat:@"Date: %.2d-%.2d-20%.2d Time: %.2d:%.2d",profileBlocksTable.profileMonth,profileBlocksTable.profileDay,profileBlocksTable.profileYear,profileBlocksTable.profileHour,profileBlocksTable.profileMin];
            field.objectValue = profileBlocksTable;
            [self.commandFields.fields addObject:field];
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
