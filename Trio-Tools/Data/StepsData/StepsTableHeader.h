//
//  StepsTableHeader.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/21/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CommandFields.h"
#import "DeviceInformation.h"
#import "StepTable.h"

@interface StepsTableHeader : NSObject

@property(assign)int tableType;
@property (assign)long selectedFieldIndex;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;

-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;
-(void)parseStepsTableHeaderRaw:(NSString*)rawData;

@end
