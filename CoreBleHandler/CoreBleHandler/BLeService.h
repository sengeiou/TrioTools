//
//  TrioLeService.h
//  TrioCoreBleHandler
//
//  Created by Berkley Bernales on 12/11/14.
//  Copyright (c) 2014 MyFortify. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>



@class BLeService;

@protocol BleServiceProtocol<NSObject>
@required
- (void) blePeripheralDidConnect:(CBPeripheral*)peripheral;
- (void) blePeripheralDidDisconnect:(CBPeripheral*)peripheral;
- (void) didReceiveResponse:(CBPeripheral*)peripheral data:(NSData*)data;
@optional
@end

@interface BLeService : NSObject

- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<BleServiceProtocol>)controller;
- (void) reset;
- (void) start;


@property (readonly) CBPeripheral *peripheral;
@property(retain, nonatomic)CBCharacteristic *paramCharacteristic;
@property(retain, nonatomic)CBCharacteristic *dataCharacteristic;

-(void)invokeCommand:(CBPeripheral*)peripheral withData:(NSData*)commandData;

@end
