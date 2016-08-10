//
//  ReadAllImageCodeCommand.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/13/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

#define READ_COMMAND_SIZE      2
#define IMAGE_CODE_COMMAND_SIZE 20

@interface ReadAllImageCodeCommand : NSObject

@property (assign)int trademark;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;


-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(void)parseAllImageCodeDataRaw:(NSString*)rawData;

-(NSData*)getCommand;

@end
