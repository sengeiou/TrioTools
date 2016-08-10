//
//  DfuCommand.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/26/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

@interface DfuCommand : NSObject

@property (assign)int firmwareVer;
@property (assign)BOOL flashOverride;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;


-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;


@end
