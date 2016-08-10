//
//  ScreenSettings.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/25/15.
//  Copyright © 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

@interface ScreenSettings : NSObject

@property(assign)int numberOfScreens;

@property(assign)int scr1;
@property(assign)int scr2;
@property(assign)int scr3;
@property(assign)int scr4;
@property(assign)int scr5;
@property(assign)int scr6;
@property(assign)int scr7;
@property(assign)int scr8;
@property(assign)int scr9;
@property(assign)int scr10;
@property(assign)int scr12;
@property(assign)int scr13;
@property(assign)int scr14;
@property(assign)int scr15;


//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;

-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;
-(void)parseScreenSettingsRaw:(NSString*)rawData;

@end
