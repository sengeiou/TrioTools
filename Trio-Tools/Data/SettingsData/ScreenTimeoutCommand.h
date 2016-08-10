//
//  ScreenTimeoutCommand.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/12/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CommandFields.h"
#import "DeviceInformation.h"

#define READ_COMMAND_SIZE      2
#define SCREEN_TIMEOUT_COMMAND_SIZE 4

@interface ScreenTimeoutCommand : NSObject

@property(assign)int timeoutValue;


//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;

-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;
-(void)parseScreenTimeoutRaw:(NSString*)rawData;

@end
