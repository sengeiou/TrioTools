//
//  TalliesCommandData.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 4/6/16.
//  Copyright © 2016 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandFields.h"
#import "DeviceInformation.h"

#define READ_COMMAND_SIZE      2
#define TALLIES_COMMAND_SIZE 20

@interface TalliesCommandData : NSObject

@property(assign)int hoursUsed;
@property(assign)int beaconConnected;
@property(assign)int beaconFailed;
@property(assign)int onDemandConnected;
@property(assign)int onDemandFailed;
@property(assign)int numberOfCharge;
@property(assign)int numberOfHardReset;
@property(assign)int numberOfVibration;

//Command Property
@property (assign)int commandAction;
@property (assign)int commandPrefix;
@property (assign)int writeCommandID;
@property (assign)int readCommandID;

@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)CommandFields *commandFields;


-(id)initWithCommandFields:(CommandFields*)cmdFields deviceInfo:(DeviceInformation*)devInfo commandAction:(int)action;

-(NSData*)getCommands;
-(void)parseTalliesDataRaw:(NSString*)rawData;
@end
