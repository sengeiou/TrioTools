//
//  UserSettings.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/18/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

#define READ_COMMAND_SIZE           2
#define FT900_COMMAND_LEN           12
#define PE961_COMMAND_LEN1          13
#define PE961_COMMAND_LEN2          14
#define USER_SETTINGS_COMMAND_LEN   9

@interface UserSettings : NSObject

@property (assign)int  userWeightWhole;
@property (assign)int  userWeightDecimal;
@property (assign)int  userStride;
@property (assign)int  userRMR;
@property (assign)BOOL userDeviceUnitOfMeasure;

@property (assign)int userDOByear;
@property (assign)int userDOBmonth;
@property (assign)int userDOBday;
@property (assign)int userAge;

@property (assign)int screenInvertSettings;

//Screen settings
@property (assign)BOOL userAutoRotateSettings;
@property (assign)BOOL userScreenOrientation;
@property (assign)BOOL userWristPreference;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (assign)int expectedResponseSize;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;


-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;
-(void)parseUserSettingsRaw:(NSString*)rawData;



@end
