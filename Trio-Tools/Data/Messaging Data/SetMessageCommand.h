//
//  SetMessageCommand.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/14/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

@interface SetMessageCommand : NSObject

@property(strong, nonatomic)NSString *message;
@property(assign)int scrollingDelay;
@property(assign)int messageCode;
@property(assign)int slotNo;
@property(assign)int messageType;
@property(assign)BOOL scrollSettings;
@property(assign)int fontStyle;
@property(assign)int textColor;
@property(assign)int xCoor;
@property(assign)int yCoor;
@property(assign)int bgColor;

@property(strong, nonatomic)NSMutableArray *setMessageCommandsArray;

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
