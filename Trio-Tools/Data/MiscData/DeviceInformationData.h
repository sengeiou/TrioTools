//
//  DeviceInformation.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/2/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

#define READ_COMMAND_SIZE       2
#define DEVICE_INFO_COMMAND_SIZE 20

@interface DeviceInformationData : NSObject

@property(assign)long long serialNo;
@property(assign)float firmwareVersion;
@property(assign)int modelNumber;
@property(assign)char broadcastType;
@property(assign)float hardwareVersion;
@property(assign)int batteryLevel;
@property(assign)float bootLoaderVersion;
@property(assign)int betaVersionNumber;
@property(assign)int deviceSensitivity;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;

-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;
-(void)parseDeviceInfoRaw:(NSString*)rawData;
@end
