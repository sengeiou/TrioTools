//
//  EEPROMCommand.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/26/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

@interface EEPROMCommand : NSObject

@property(assign)BOOL clearEE;
@property(assign)BOOL setDefault;
@property(assign)BOOL clearProfile;
@property(assign)BOOL clearMessaging;
@property(assign)BOOL clearTallies;
@property(assign)BOOL cleearFwUpdateFlag;

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
