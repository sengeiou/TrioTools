//
//  DeviceModeCommand.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/27/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

@interface DeviceModeCommand : NSObject

@property(assign)BOOL bootUpFlag;
@property(assign)int deviceMode;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;

-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;

-(void)parseDeviceModeRaw:(NSString*)rawData;

@end
