//
//  DeviceStatus.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/15/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

#define READ_COMMAND_SIZE      2
#define DEVICE_STATUS_COMMAND_SIZE 3

@interface DeviceStatus : NSObject

@property(assign)BOOL intensityGoalStatus;
@property(assign)BOOL frequencyGoalStatus;
@property(assign)BOOL tenacityGoalStatus;
@property(assign)int pairingStatus;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;

-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;
-(void)parseDeviceStatusRaw:(NSString*)rawData;

@end
