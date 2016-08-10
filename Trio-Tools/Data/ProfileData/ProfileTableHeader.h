//
//  ProfileTableHeader.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/8/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

#import "ProfileTable.h"

@interface ProfileTableHeader : NSObject

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

-(void)parseProfileBlocksFlagData:(NSString*)rawData;
@end
