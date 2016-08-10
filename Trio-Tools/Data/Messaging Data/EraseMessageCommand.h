//
//  EraseMessageCommand.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/13/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"


#define ERASE_MESSAGE_COMMAND_SIZE 20


@interface EraseMessageCommand : NSObject

@property (assign)int slot1;
@property (assign)int slot2;
@property (assign)int slot3;
@property (assign)int slot4;
@property (assign)int slot5;
@property (assign)int slot6;
@property (assign)int slot7;
@property (assign)int slot8;
@property (assign)int slot9;
@property (assign)int slot10;
@property (assign)int slot11;
@property (assign)int slot12;
@property (assign)int slot13;
@property (assign)int slot14;
@property (assign)int slot15;
@property (assign)int slot16;
@property (assign)int slot17;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;


-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

//-(void)parseEraseMesageDataRaw:(NSString*)rawData;

-(NSData*)getCommand;


@end
