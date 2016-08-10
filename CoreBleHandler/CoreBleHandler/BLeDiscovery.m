//
//  TrioLeDiscovery.m
//  TrioCoreBleHandler
//
//  Created by Berkley Bernales on 12/11/14.
//  Copyright (c) 2014 MyFortify. All rights reserved.
//

/*
 Abstract: Scan for and discover nearby LE peripherals with the
 matching service UUID.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc.
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "BLeDiscovery.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface BLeDiscovery() <CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCentralManager    *centralManager;
}

@end

@implementation BLeDiscovery

@synthesize discoveryDelegate;
@synthesize peripheralDelegate;
@synthesize connectedPeripheralArray;
@synthesize connectedServices;
@synthesize conPeripheral;
@synthesize connectingPeripheral;

@synthesize isScanning;

/****************************************************************************/
/*									Init									*/
/****************************************************************************/
+ (id) sharedInstance
{
    static BLeDiscovery	*this	= nil;
    
    if (!this)
        this = [[BLeDiscovery alloc] init];
    
    return this;
}

- (id) init
{
    self = [super init];
    if (self) {
        
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        connectedPeripheralArray = [[NSMutableArray alloc] init];
        connectedServices = [[NSMutableArray alloc] init];

    }
    return self;
}

/****************************************************************************/
/*								Discovery                                   */
/****************************************************************************/
- (void) startScanningWithServiceUUID:(NSArray*)services
{
    if (centralManager.state == CBCentralManagerStatePoweredOn)
    {
        [centralManager scanForPeripheralsWithServices:services options:[NSDictionary dictionaryWithObject:
                                                                         [NSNumber numberWithBool:YES]
                                                                                                    forKey:
                                                                         CBCentralManagerScanOptionAllowDuplicatesKey]];
    }
    if(self.isScanning)
        return;

    self.isScanning = YES;
    
    [discoveryDelegate discoveryStarted];
}

- (void) stopScanning
{
    [centralManager stopScan];
    self.isScanning = NO;
    [discoveryDelegate discoveryStopped];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Peripheral name:%@",[peripheral name]);
    if( peripheral != nil)
    {
        [discoveryDelegate didDiscoverBleDevice:peripheral advertisementData:advertisementData signalStrength:[RSSI intValue]];
    }
}

- (void) connectPeripheral:(CBPeripheral*)peripheral
{
    if ([peripheral state] != CBPeripheralStateConnected)
    {
        self.connectingPeripheral = peripheral;
        [centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    [centralManager cancelPeripheralConnection:peripheral];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if([connectedPeripheralArray count]==0)
    {
        [centralManager stopScan];
        self.isScanning = NO;
        LeConnectedPeripheral *lePeripheral = [[LeConnectedPeripheral alloc] init];
        lePeripheral.connectedPeripheral = peripheral;
        self.conPeripheral = lePeripheral;
        [connectedPeripheralArray addObject:connectingPeripheral];
        
        BLeService *service = [[BLeService alloc] initWithPeripheral:peripheral controller:peripheralDelegate];
        [service start];
        
        if (![connectedServices containsObject:service])
        {
            [connectedServices addObject:service];
        }
    }
    else
    {
        [self disconnectPeripheral:peripheral];
    }
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self clearDevices];
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self clearDevices];
    [peripheralDelegate blePeripheralDidDisconnect:peripheral];
}

- (void) clearDevices
{
    BLeService	*service;
    [connectedPeripheralArray removeAllObjects];
    
    for (service in connectedServices) {
        [service reset];
    }
    [connectedServices removeAllObjects];
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    static CBCentralManagerState previousState = -1;
    
    switch ([centralManager state])
    {
        case CBCentralManagerStateUnsupported:
            NSLog(@"Centra Manager state Unsupported");
            break;
        case CBCentralManagerStatePoweredOff:
        {
            NSLog(@"Centra Manager state Powered Off");
            self.bleState = CBCentralManagerStatePoweredOff;
            /* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            [discoveryDelegate discoveryStatePoweredOff];
            break;
        }
        case CBCentralManagerStateUnauthorized:
        {
            NSLog(@"Centra Manager state Unauthorized");
            /* Tell user the app is not allowed. */
            self.bleState = CBCentralManagerStatePoweredOn;
            break;
        }
        case CBCentralManagerStateUnknown:
        {
            NSLog(@"Centra Manager state Unsupported");
            /* Bad news, let's wait for another event. */
            self.bleState = CBCentralManagerStatePoweredOff;
            break;
        }
        case CBCentralManagerStatePoweredOn:
        {
             NSLog(@"Centra Manager state Powered ON");
            self.bleState = CBCentralManagerStatePoweredOn;
            [discoveryDelegate discoveryStatePoweredOn];
            break;
        }
        case CBCentralManagerStateResetting:
        {
            self.bleState = CBCentralManagerStateResetting;
            centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
            break;
        }
    }
    previousState = [centralManager state];
}

- (void) sendCommand:(NSData*)data
{
    for (BLeService *connectedService in connectedServices)
    {
        [connectedService invokeCommand:self.connectingPeripheral withData:data];
        break;
    }
}

@end
