//
//  LeConnectedPeripheral.m
//  CoreBleHandler
//
//  Created by Berkley Bernales on 8/5/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "LeConnectedPeripheral.h"

@implementation LeConnectedPeripheral

@synthesize connectedPeripheral;
@synthesize firmwareVer;
@synthesize model;
@synthesize batteryLevel;
@synthesize deviceName;
@synthesize serialNum;
@synthesize betaNumber;


-(id)init
{
    self = [super init];
    if (self)
    {
        self.deviceName = [[NSString alloc]init];
    }
    
    return self;
    
}

@end
