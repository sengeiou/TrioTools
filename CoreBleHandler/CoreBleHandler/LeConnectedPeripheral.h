//
//  LeConnectedPeripheral.h
//  CoreBleHandler
//
//  Created by Berkley Bernales on 8/5/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface LeConnectedPeripheral : NSObject


-(id)init;

@property(retain, nonatomic)CBPeripheral * connectedPeripheral;
@property(strong, nonatomic)NSString *deviceName;
@property(assign)float firmwareVer;
@property(assign)int batteryLevel;
@property(assign)int model;
@property(assign)long long serialNum;
@property(assign)int betaNumber;

@end
