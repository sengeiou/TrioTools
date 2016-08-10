//
//  MessageSchedule.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/18/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import "MessageSchedule.h"
#import "Field.h"
#import "Definitions.h"

@implementation MessageSchedule

@synthesize scheduleID;
@synthesize  displayTriggerType;
@synthesize  displayType;
@synthesize  skipButtonNumber;
@synthesize  sensor1;
@synthesize  sensor2;
@synthesize  sensor3;
@synthesize  schedYear;
@synthesize  schedMonth;
@synthesize  schedDay;
@synthesize  startTimeHour;
@synthesize  endTimeHour;
@synthesize  intervalType;
@synthesize  intervalValue;
@synthesize  numberOfOccurences;
@synthesize  visibilityTime;
@synthesize  scheduleIconType;
@synthesize  saveUserResponse;
@synthesize  vibrationSetting;
@synthesize  messageImageSlotNumber1;
@synthesize  messageImageSlotNumber2;
@synthesize  messageImageSlotNumber3;
@synthesize  messageImageSlotNumber4;
@synthesize  messageImageSlotNumber5;
@synthesize  messageImageSlotNumber6;

@synthesize  dataTypeOrAnswer1;
@synthesize  dataTypeOrAnswer2;
@synthesize  dataTypeOrAnswer3;
@synthesize  dataTypeOrAnswer4;
@synthesize  dataTypeOrAnswer5;
@synthesize  dataTypeOrAnswer6;


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
        if([field.fieldname isEqualToString:@"Schedule ID:"])
        {
            self.scheduleID = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Display Trigger Type:"])
        {
            self.displayTriggerType = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Display Type:"])
        {
            self.displayType = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Skip Button No:"])
        {
            self.skipButtonNumber = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Sensor1:"])
        {
            self.sensor1 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Sensor2:"])
        {
            self.sensor2 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Sensor3:"])
        {
            self.sensor3 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Schedule Year:"])
        {
            self.schedYear = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Schedule Month:"])
        {
            self.schedMonth = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Schedule Day:"])
        {
            self.schedDay = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Start Time(hr):"])
        {
            self.startTimeHour = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"End Time(hr):"])
        {
            self.endTimeHour = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Interval Type:"])
        {
            self.intervalType = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Interval Value:"])
        {
            self.intervalValue = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Occurences (0=infinite):"])
        {
            self.numberOfOccurences = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Visible Time(sec):"])
        {
            self.visibilityTime = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Image slot(Icon):"])
        {
            self.scheduleIconType = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Save User Response:"])
        {
            self.saveUserResponse = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Vibration Setting:"])
        {
            self.vibrationSetting = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"DataType/Answer1:"])
        {
            self.dataTypeOrAnswer1 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Message Slot#1:"])
        {
            self.messageImageSlotNumber1 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"DataType/Answer2:"])
        {
            self.dataTypeOrAnswer2 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Message Slot#2:"])
        {
            self.messageImageSlotNumber2 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"DataType/Answer3:"])
        {
            self.dataTypeOrAnswer3 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Message Slot#3:"])
        {
            self.messageImageSlotNumber3 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Data/Answer4:"])
        {
            self.dataTypeOrAnswer4 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Message Slot#4:"])
        {
            self.messageImageSlotNumber4 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"DataType/Answer5:"])
        {
            self.dataTypeOrAnswer5 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Message Slot#5:"])
        {
            self.messageImageSlotNumber5 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"DataType/Answer6:"])
        {
            self.dataTypeOrAnswer6 = (int) field.value;
        }
        else if([field.fieldname isEqualToString:@"Message Slot#6:"])
        {
            self.messageImageSlotNumber6 = (int) field.value;
        }
    }
}


-(void)parseMesageScheduleDataRaw:(NSString*)rawData
{
    self.scheduleID =  [MessageSchedule getIntValue:rawData startIndex:0 length:2];
    int temp = [MessageSchedule getIntValue:rawData startIndex:2 length:2];
    self.displayTriggerType = (temp >> 7) & 0x01;
    self.displayType = (temp >> 5) & 0x03;
    self.skipButtonNumber = (temp >> 3) & 0x03;
    self.sensor3 = (temp >>1) & 0x01;
    self.sensor2 = (temp >>2) & 0x01;
    self.sensor1 = temp & 0x01;
    self.schedYear = [MessageSchedule getIntValue:rawData startIndex:4 length:2];
    self.schedMonth = [MessageSchedule getIntValue:rawData startIndex:6 length:2];
    self.schedDay = [MessageSchedule getIntValue:rawData startIndex:8 length:2];
    self.startTimeHour = [MessageSchedule getIntValue:rawData startIndex:10 length:2];
    self.endTimeHour = [MessageSchedule getIntValue:rawData startIndex:12 length:2];
    temp = [MessageSchedule getIntValue:rawData startIndex:14 length:2];
    self.intervalType = (temp >> 7) & 0x01;
    self.intervalValue = temp & 0x7F;
    self.numberOfOccurences = [MessageSchedule getIntValue:rawData startIndex:16 length:2];
    self.visibilityTime = [MessageSchedule getIntValue:rawData startIndex:18 length:2];
    temp = [MessageSchedule getIntValue:rawData startIndex:20 length:2];
    self.scheduleIconType = (temp >> 2) & 0x3F;
    self.saveUserResponse = (temp >> 1) & 0x01;
    self.vibrationSetting = temp & 0x01;
    temp = [MessageSchedule getIntValue:rawData startIndex:22 length:2];
    self.dataTypeOrAnswer1 = (temp >> 6) & 0x03;
    self.messageImageSlotNumber1 = temp & 0x3F;
    temp = [MessageSchedule getIntValue:rawData startIndex:24 length:2];
    self.dataTypeOrAnswer2 = (temp >> 6) & 0x03;
    self.messageImageSlotNumber2 = temp & 0x3F;
    temp = [MessageSchedule getIntValue:rawData startIndex:26 length:2];
    self.dataTypeOrAnswer3 = (temp >> 6) & 0x03;
    self.messageImageSlotNumber3 = temp & 0x3F;
    temp = [MessageSchedule getIntValue:rawData startIndex:28 length:2];
    self.dataTypeOrAnswer4 = (temp >> 6) & 0x03;
    self.messageImageSlotNumber4 = temp & 0x3F;
    temp = [MessageSchedule getIntValue:rawData startIndex:30 length:2];
    self.dataTypeOrAnswer5 = (temp >> 6) & 0x03;
    self.messageImageSlotNumber5 = temp & 0x3F;
    temp = [MessageSchedule getIntValue:rawData startIndex:32 length:2];
    self.dataTypeOrAnswer6 = (temp >> 6) & 0x03;
    self.messageImageSlotNumber6 = temp & 0x3F;
    
    [self updateCommandFieds];

}

-(void)updateCommandFieds
{
    for(Field *field in self.commandFields.fields)
    {
        if([field.fieldname isEqualToString:@"Schedule ID:"])
        {
            field.value = self.scheduleID;
        }
        else if([field.fieldname isEqualToString:@"Display Trigger Type:"])
        {
            field.value = self.displayTriggerType;
        }
        else if([field.fieldname isEqualToString:@"Display Type:"])
        {
            field.value = self.displayType;
        }
        else if([field.fieldname isEqualToString:@"Skip Button No:"])
        {
            field.value = self.skipButtonNumber;
        }
        else if([field.fieldname isEqualToString:@"Sensor1:"])
        {
            field.value = self.sensor1;
        }
        else if([field.fieldname isEqualToString:@"Sensor2:"])
        {
            field.value = self.sensor2;
        }
        else if([field.fieldname isEqualToString:@"Sensor3:"])
        {
            field.value = self.sensor3;
        }
        else if([field.fieldname isEqualToString:@"Schedule Year:"])
        {
            field.value = self.schedYear;
        }
        else if([field.fieldname isEqualToString:@"Schedule Month:"])
        {
            field.value = self.schedMonth;
        }
        else if([field.fieldname isEqualToString:@"Schedule Day:"])
        {
            field.value = self.schedDay;
        }
        else if([field.fieldname isEqualToString:@"Start Time(hr):"])
        {
            field.value = self.startTimeHour;
        }
        else if([field.fieldname isEqualToString:@"End Time(hr):"])
        {
            field.value = self.endTimeHour;
        }
        else if([field.fieldname isEqualToString:@"Interval Type:"])
        {
            field.value = self.intervalType;
        }
        else if([field.fieldname isEqualToString:@"Interval Value:"])
        {
            field.value = self.intervalValue;
        }
        else if([field.fieldname isEqualToString:@"Occurences (0=infinite):"])
        {
            field.value = self.numberOfOccurences;
        }
        else if([field.fieldname isEqualToString:@"Visible Time(sec):"])
        {
            field.value = self.visibilityTime;
        }
        else if([field.fieldname isEqualToString:@"Image slot(Icon):"])
        {
            field.value = self.scheduleIconType;
        }
        else if([field.fieldname isEqualToString:@"Save User Response:"])
        {
            field.value = self.saveUserResponse;
        }
        else if([field.fieldname isEqualToString:@"Vibration Setting:"])
        {
            field.value = self.vibrationSetting;
        }
        else if([field.fieldname isEqualToString:@"DataType/Answer1:"])
        {
            field.value = self.dataTypeOrAnswer1;
        }
        else if([field.fieldname isEqualToString:@"Message Slot#1:"])
        {
            field.value = self.messageImageSlotNumber1;
        }
        else if([field.fieldname isEqualToString:@"DataType/Answer2:"])
        {
            field.value = self.dataTypeOrAnswer2;
        }
        else if([field.fieldname isEqualToString:@"Message Slot#2:"])
        {
            field.value = self.messageImageSlotNumber2;
        }
        else if([field.fieldname isEqualToString:@"DataType/Answer3:"])
        {
            field.value = self.dataTypeOrAnswer3;
        }
        else if([field.fieldname isEqualToString:@"Message Slot#3:"])
        {
            field.value = self.messageImageSlotNumber3;
        }
        else if([field.fieldname isEqualToString:@"DataType/Answer4:"])
        {
            field.value = self.dataTypeOrAnswer4;
        }
        else if([field.fieldname isEqualToString:@"Message Slot#4:"])
        {
            field.value = self.messageImageSlotNumber4;
        }
        else if([field.fieldname isEqualToString:@"DataType/Answer5:"])
        {
            field.value = self.dataTypeOrAnswer5;
        }
        else if([field.fieldname isEqualToString:@"Message Slot#5:"])
        {
            field.value = self.messageImageSlotNumber5;
        }
        else if([field.fieldname isEqualToString:@"DataType/Answer6:"])
        {
            field.value = self.dataTypeOrAnswer6;
        }
        else if([field.fieldname isEqualToString:@"Message Slot#6:"])
        {
            field.value = self.messageImageSlotNumber6;
        }
    }
}

-(NSData*)getCommands
{
    int commandLen = 0;
    unsigned char * buffer = nil;
    if(self.commandAction==0)
    {
        commandLen = 3;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.readCommandID;
        buffer[2] = self.scheduleID;
    }
    else
    {
        commandLen = MESSAGE_SCHEDULE_COMMAND_SIZE;
        buffer = (unsigned char*) calloc(commandLen,sizeof(unsigned char));
        buffer[0] = self.commandPrefix == COMMAND_ID?0x1B:commandLen-1;
        buffer[1] = self.writeCommandID;
        buffer[2] = self.scheduleID;
        
        int fourthByte = 0x00;
        fourthByte |= (self.displayTriggerType << 7);
        fourthByte |= (self.displayType << 5);
        fourthByte |= (self.skipButtonNumber << 3);
        fourthByte |= self.sensor3?0x04:0x00;
        fourthByte |= self.sensor2?0x02:0x00;
        fourthByte |= self.sensor1?0x01:0x00;
        
        buffer[3] = fourthByte;
        
        
        
        buffer[4] = self.schedYear;
        buffer[5] = self.schedMonth;
        buffer[6] = self.schedDay;
        buffer[7] = self.startTimeHour;
        buffer[8] = self.endTimeHour;
        
        int tenthByte = 0x00;
        tenthByte |= (self.intervalType << 7);
        tenthByte |= self.intervalValue;
        
        buffer[9] = tenthByte;
        
        buffer[10] = self.numberOfOccurences;
        buffer[11] = self.visibilityTime;
        
        int thirteenthByte = 0x00;
        thirteenthByte |= (self.scheduleIconType << 2);
        thirteenthByte |= (self.saveUserResponse << 1);
        thirteenthByte |= self.vibrationSetting;
        
        buffer[12] = thirteenthByte;
        
        int fourteenthByte = 0x00;
        fourteenthByte |= (self.dataTypeOrAnswer1 << 7);
        fourteenthByte |= self.messageImageSlotNumber1;

        int fifteenthByte = 0x00;
        fifteenthByte |= (self.dataTypeOrAnswer2 << 7);
        fifteenthByte |= self.messageImageSlotNumber2;
        
        int sixteenthByte = 0x00;
        sixteenthByte |= (self.dataTypeOrAnswer3 << 7);
        sixteenthByte |= self.messageImageSlotNumber3;
        
        int seventeenthByte = 0x00;
        seventeenthByte |= (self.dataTypeOrAnswer4 << 7);
        seventeenthByte |= self.messageImageSlotNumber4;
        
        int eighteenthByte = 0x00;
        eighteenthByte |= (self.dataTypeOrAnswer5 << 7);
        eighteenthByte |= self.messageImageSlotNumber5;
        
        int ninteenthByte = 0x00;
        ninteenthByte |= (self.dataTypeOrAnswer6 << 7);
        ninteenthByte |= self.messageImageSlotNumber6;
        
        buffer[13] = fourteenthByte;
        buffer[14] = fifteenthByte;
        buffer[15] = sixteenthByte;
        buffer[16] = seventeenthByte;
        buffer[17] = eighteenthByte;
        buffer[18] = ninteenthByte;

    }
    
    
    NSData *command = [NSData dataWithBytes:buffer length:commandLen];
    
    return command;
}

+(int) getIntValue:(NSString *) data startIndex:(int) startIndex length:(int) length
{
    unsigned int value;
    
    NSScanner *toDecimal = [NSScanner scannerWithString:[data substringWithRange:NSMakeRange(startIndex, length)]];
    [toDecimal scanHexInt:&value];
    return value;
}

@end
