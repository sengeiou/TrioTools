//
//  ProfileData.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/8/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

@interface ProfileData : NSObject

@property(assign)int startBlock;
@property(assign)int endBlock;

@property(assign)int profileYear;
@property(assign)int profileMonth;
@property(assign)int profileDay;
@property(assign)int profileHour;
@property(assign)int profileMin;

@property(assign)int profileSamplingFrequency;
@property(assign)int profileSamplingTime;



@property(strong, nonatomic)NSMutableArray* x_Axis;
@property(strong, nonatomic)NSMutableArray* y_Axis;
@property(strong, nonatomic)NSMutableArray* z_Axis;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;

-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;

-(void)parseProfileData:(NSString*)rawData;

@end
