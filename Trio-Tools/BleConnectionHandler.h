//
//  BleConnectionHandler.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/5/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeviceInformation.h"

@protocol ConnectionProtocol <NSObject>

@required
- (void) bleDeviceConnected;
- (void) bleDeviceDisconnected;
- (void) bleDidDiscoverDevice:(NSString*)deviceName signalStrength:(int)rssiValue;
@optional
- (void) didReceiveCompleteResponse;
@end

@interface BleConnectionHandler : NSObject

@property (nonatomic, assign) id<ConnectionProtocol> connectiondelegate;
@property (strong, nonatomic)DeviceInformation *deviceInfo;
@property (strong, nonatomic)NSString *modelName;


-(id)init;

-(void)startBleDiscoveryWithServices:(NSArray*)services;
-(void)startBleDiscoveryWithServices:(NSArray*)services modelAllowed:(int)model;
-(void)stopBleDiscovery;
-(void)disconnect;
-(BOOL)isScanning;
-(BOOL)isConnected;
@end
