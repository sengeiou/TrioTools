//
//  Definitions.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 7/10/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface Definitions : NSObject


//For iOS version checking
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

typedef enum trioModel
{
    PE932 = 932,
    PE936 = 936,
    PE939 = 939,
    PE961 = 961,
    FT900 = 900,
    FT969 = 969,
    FT905 = 905,
    FT962 = 962,
    FT965 = 965,
}supportedTrioModel;

typedef enum commandPrefix
{
    COMMAND_ID = 0,
    COMMAND_SIZE = 1,
}supportedCommandPrefix;


typedef enum streamingType
{
    STEPS_DATA =0,
    PROFILE_DATA =1,
    SEIZURE_DATA =2,
}dataStreamingType;

typedef enum controlType
{
    TextField = 0,
    Switch = 1,
    TableView = 2,
    Label = 3,
    DatePicker = 4,
    Button = 5,
    
}supportedControlType;

typedef enum commandAction
{
    READ = 0,
    WRITE = 1,
}supportedCommandAction;

typedef enum commandIDs
{
    UNSUPPORTED_COMMAND = 0xFF,
    WRITE_DEVICE_STATUS = 0x12,
    GET_DEVICE_STATUS = 0x13,
    WRITE_DEVICE_SETTINGS = 0x16,
    READ_DEVICE_SETTINGS = 0x17,
    WRITE_USER_SETTINGS = 0x18,
    READ_USER_SETTINGS = 0x19,
    WRITE_EXERCISE_SETTINGS = 0x1A,
    READ_EXERCISE_SETTINGS = 0x1C,
    WRITE_COMPANY_SETTINGS = 0x1D,
    READ_COMPANY_SETTINGS = 0x1E,
    WRITE_PROFILE_SETTINGS = 0x5F,
    READ_PROFILE_SETTINGS = 0x60,
    WRITE_SENSITIVITY_SETTINGS = 0x58,
    READ_SENSITIVITY_SETTINGS = 0x59,
    READ_STEPS_TABLE_DATA = 0x22,
    WRITE_STEPS_TABLE_DATA = 0x25,
    READ_STEPS_DATA_BY_HOUR_RANGE = 0x24,
    READ_STEPS_DATA_CURRENT_HOUR = 0x27,
    DFU_COMMAND = 0X41,
    EEPROM_COMMAND = 0x28,
    READ_DEVICE_MODE_COMMAND = 0x64,
    SET_DEVICE_MODE_COMMAND = 0x29,
    DEVICE_INFO_COMMAND = 0x40,
    SET_ALARM_COMMAND = 0x2A,
    READ_ALARM_COMMAND = 0x2B,
    START_PROFILE_RECORDING_COMMAND = 0x39,
    READ_TALLIES_DATA_COMMAND = 0x5D,
    READ_CHARGING_HISTORY_DATA_COMMAND = 0x5E,
    READ_PROFILE_TABLE_DATA_COMMAND = 0x62,
    WRITE_PROFILE_TABLE_DATA_COMMAND = 0x61,
    READ_SCREEN_SETTINGS = 0x2F,
    WRITE_SCREEN_SETTINGS = 0x30,
    READ_PROFILE_DATA_COMMAND = 0X63,
    ACK_COMMAND = 0x68,
    SET_SCREEN_TIMEOUT_COMMAND = 0X5B,
    READ_SCREEN_TIMEOUT_COMMAND = 0x5C,
    ERASE_MESSAGES_COMMAND = 0x66,
    SET_MESSAGE_COMMAND = 0x4B,
    DISPLAY_ON_SCREEN_COMMAND = 0x54,
    SHOW_WRITTEN_MESSAGE_COMMAND = 0X5A,
    SET_MESSAGE_SCHEDULE_COMMAND = 0x67,
    GET_MESSAGE_SCHEDULE_COMMAND = 0x69,
}supportedCommandIDs;


@end