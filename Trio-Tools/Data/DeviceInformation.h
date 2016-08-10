//
//  DeviceInformation.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/7/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInformation : NSObject

@property (strong, nonatomic)NSString *deviceName;
@property (assign)long long serialNum;
@property (assign)float firmwareVersion;
@property (assign)int model;
@property (assign)int batteryLevel;

@property (assign)int betaNumber;

@end
