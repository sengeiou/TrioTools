//
//  ShowWrittenMessage.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/18/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CommandFields.h"
#import "DeviceInformation.h"


@interface ShowWrittenMessage : NSObject

@property (assign)int slotNumber;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;


-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommand;


@end
