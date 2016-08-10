//
//  TrioLeService.m
//  TrioCoreBleHandler
//
//  Created by Berkley Bernales on 12/11/14.
//  Copyright (c) 2014 MyFortify. All rights reserved.
//

#import "BLeService.h"
#import "BLeDiscovery.h"

// BLE Services UUIDs

#define DFU_SERVICE_UUID_STRING @"00001530-1212-EFDE-1523-785FEABCD123" // Trio device firmware update UUID(961 and 900)
#define TRIO_SERVICE_UUID_STRING @"3aa7ff01-c26a-4cd2-ad1c-8cf29d6874f4"// Trio device service UUID (All Trio models)
#define GATT_DEVICE_INFO_SERVICE_UUID_STRING @"180A" // Bluetooth Gatt standard service UUID for BLE Device information
#define GATT_BATTERY_LEVEL_SERVICE_UUID_STRING @"180F" // Bluetooth Gatt standard service UUID for BLE device battery level

//BLE Characteristic UUIDs
#define DFU_CONTROL_POINT_CHARACTERISTIC_UUID_STRING @"00001531-1212-EFDE-1523-785FEABCD123"
#define DFU_PACKET_CHARACTERISTIC_UUID_STRING @"00001531-1212-EFDE-1523-785FEABCD123"

#define TRIO_FF07_CHARACTERISTIC_UUID_STRING @"3aa7ff07-c26a-4cd2-ad1c-8cf29d6874f4"
#define TRIO_FF08_CHARACTERISTIC_UUID_STRING @"3aa7ff08-c26a-4cd2-ad1c-8cf29d6874f4"

#define GATT_DEVICE_MODEL_NUMBER_UUID_STRING @"2A24"
#define GATT_DEVICE_SERIAL_NUMBER_UUID_STRING @"2A25"
#define GATT_DEVICE_FIRMWARE_VERSION_UUID_STRING @"2A26"
#define GATT_DEVICE_BATTERY_LEVEL_UUID_STRING @"2A19"


typedef enum connectionExitPoint
{
    TRIO_SERVICE = 0,
    DEVICEINFO_SERVICE,
    BATTERYLEVEL_SERVICE,
    DFU_SERVICE,
}ServiceDiscoveryExitPoint;


@interface BLeService() <CBPeripheralDelegate> {
    
@private
    CBPeripheral		*servicePeripheral;
        
    id<BleServiceProtocol>	peripheralDelegate;
}

@property(assign)ServiceDiscoveryExitPoint exitPoint;

@end

@implementation BLeService

@synthesize  exitPoint;
@synthesize dataCharacteristic;
@synthesize paramCharacteristic;

@synthesize peripheral = servicePeripheral;

+ (CBUUID *) trioServiceUUID
{
    return [CBUUID UUIDWithString:TRIO_SERVICE_UUID_STRING];
}
+ (CBUUID *) trioDataCharacteristicsUUID
{
    return [CBUUID UUIDWithString:TRIO_FF07_CHARACTERISTIC_UUID_STRING];
}
+ (CBUUID *) trioParamCharacteristicsUUID
{
    return [CBUUID UUIDWithString:TRIO_FF08_CHARACTERISTIC_UUID_STRING];
}
+ (CBUUID *) dfuServiceUUID
{
    return [CBUUID UUIDWithString:DFU_SERVICE_UUID_STRING];
}
+ (CBUUID *) controlPointCharacteristicUUID
{
    return [CBUUID UUIDWithString:DFU_CONTROL_POINT_CHARACTERISTIC_UUID_STRING];
}
+ (CBUUID *) packetCharacteristicUUID
{
    return [CBUUID UUIDWithString:DFU_PACKET_CHARACTERISTIC_UUID_STRING];
}
+ (CBUUID *) gattDeviceInfoServiceUUID
{
    return [CBUUID UUIDWithString:GATT_DEVICE_INFO_SERVICE_UUID_STRING];
}
+ (CBUUID *) gattDeviceModelCharacteristicUUID
{
    return [CBUUID UUIDWithString:GATT_DEVICE_MODEL_NUMBER_UUID_STRING];
}
+ (CBUUID *) gattDeviceSerialNoCharacteristicUUID
{
    return [CBUUID UUIDWithString:GATT_DEVICE_SERIAL_NUMBER_UUID_STRING];
}
+ (CBUUID *) gattDeviceFirmwareVersionCharacteristicUUID
{
    return [CBUUID UUIDWithString:GATT_DEVICE_FIRMWARE_VERSION_UUID_STRING];
}
+ (CBUUID *) gattDeviceBatteryLevelServiceUUID
{
    return [CBUUID UUIDWithString:GATT_BATTERY_LEVEL_SERVICE_UUID_STRING];
}
+ (CBUUID *) gattDeviceBatteryLevelCharacteristicUUID
{
    return [CBUUID UUIDWithString:GATT_DEVICE_BATTERY_LEVEL_UUID_STRING];
}



- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<BleServiceProtocol>)controller
{
    self = [super init];
    if (self) {
        servicePeripheral = peripheral;
        [servicePeripheral setDelegate:self];
        peripheralDelegate = controller;
        
        exitPoint = DEVICEINFO_SERVICE; //Set to default exit routine

    }
    return self;
}

- (void) reset
{
    if (servicePeripheral) {
        servicePeripheral = nil;
    }
}

- (void) start
{
    NSLog(@"Service Peripheral name: %@",[servicePeripheral name]);
    [servicePeripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error != nil) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    CBService *service = [peripheral.services lastObject];
    NSLog(@"Last Service object with UUID: %@", service.UUID);
    
    if([[service UUID] isEqual:[BLeService trioServiceUUID]])
    {
        self.exitPoint = TRIO_SERVICE;
    }
    else if([[service UUID] isEqual:[BLeService gattDeviceInfoServiceUUID]])
    {
        self.exitPoint = DEVICEINFO_SERVICE;
    }
    else if([[service UUID] isEqual:[BLeService gattDeviceBatteryLevelServiceUUID]])
    {
        self.exitPoint = BATTERYLEVEL_SERVICE;
    }
    else if([[service UUID] isEqual:[BLeService dfuServiceUUID]])
    {
        self.exitPoint = DFU_SERVICE;
    }
    
    for (CBService *aService in peripheral.services)
    {
        NSLog(@"Service found with UUID: %@", aService.UUID);
        if ([aService.UUID isEqual:[BLeService trioServiceUUID]]) {
            [peripheral discoverCharacteristics:nil forService:aService];
        }
        else if ([aService.UUID isEqual:[BLeService dfuServiceUUID]]) {
            [peripheral discoverCharacteristics:nil forService:aService];
        }
        else if ([aService.UUID isEqual:[BLeService gattDeviceInfoServiceUUID]]) {
            [peripheral discoverCharacteristics:nil forService:aService];
        }
        else if([aService.UUID isEqual:[BLeService gattDeviceBatteryLevelServiceUUID]])
        {
            [peripheral discoverCharacteristics:nil forService:aService];
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    NSLog(@"service UUID: %@",service.UUID);
    
    if([service.UUID isEqual:[BLeService trioServiceUUID]])
    {
        for (CBCharacteristic *aChar in service.characteristics) {
            NSLog(@"aCharacteristic UUID:%@",aChar.UUID);
            
            if ([aChar.UUID isEqual:[BLeService trioDataCharacteristicsUUID]])
            {
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
                
                self.dataCharacteristic = aChar;
                NSLog(@"FOUND PE932 Data Characteristic");
            }
            else if([aChar.UUID isEqual:[BLeService trioParamCharacteristicsUUID]])
            {
                [peripheral setNotifyValue:YES forCharacteristic:aChar];
                self.paramCharacteristic = aChar;
                NSLog(@"FOUND PE932 Param Characteristic");
            }
        }
    }
    else if ([service.UUID isEqual:[BLeService gattDeviceInfoServiceUUID]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:[BLeService gattDeviceModelCharacteristicUUID]])
            {
                [peripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Model Name Characteristic");
            }
            else if ([aChar.UUID isEqual:[BLeService gattDeviceSerialNoCharacteristicUUID]])
            {
                [peripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Serial Number Characteristic");
            }
            else if ([aChar.UUID isEqual:[BLeService gattDeviceFirmwareVersionCharacteristicUUID]])
            {
                [peripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Firmware Version Characteristic");
            }
        }
    }
    else if([service.UUID isEqual:[BLeService gattDeviceBatteryLevelServiceUUID]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            if([aChar.UUID isEqual:[BLeService gattDeviceBatteryLevelCharacteristicUUID]])
            {
                [peripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Battery Level Characteristic");
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([error code] != 0) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    if ([characteristic.UUID isEqual:[BLeService trioParamCharacteristicsUUID]] ||
        [characteristic.UUID isEqual:[BLeService trioDataCharacteristicsUUID]])
    {
        if(characteristic.value || !error)
        {
            NSUInteger len = [characteristic.value length];
            Byte *reportData = (Byte*)malloc(len);
            memcpy(reportData, [characteristic.value bytes], len);
            NSLog(@"Raw data receive: %@", characteristic.value);
            NSLog(@"len: %d",(int)len);
            [peripheralDelegate didReceiveResponse:peripheral data:characteristic.value];
        }
    }
    else if ([characteristic.UUID isEqual:[BLeService gattDeviceModelCharacteristicUUID]])
    {
        NSLog(@"%@",characteristic.value);
        NSString *modelStr = [[NSString alloc] initWithData:characteristic.value
                                                encoding:NSUTF8StringEncoding];
        NSLog(@"model Name = %@", modelStr);
        BOOL isSupported = NO;
        
        if(modelStr!=nil && [modelStr length]>0)
        {
            int model = [[modelStr substringFromIndex:2] intValue];
            [[[BLeDiscovery sharedInstance] conPeripheral] setModel:model];
            isSupported = YES;
        }
        
        if(!isSupported)
        {
            NSLog(@"Detected BLE device model number is unknown or not supported.");
            [[BLeDiscovery sharedInstance] disconnectPeripheral:peripheral];
        }
    }
    else if ([characteristic.UUID isEqual:[BLeService gattDeviceSerialNoCharacteristicUUID]])
    {
        NSString *serialStr = [[NSString alloc] initWithData:characteristic.value
                                                 encoding:NSUTF8StringEncoding];
        NSLog(@"serial Number = %@", serialStr);
        long long serialNum = [serialStr longLongValue];
        [[[BLeDiscovery sharedInstance] conPeripheral] setSerialNum:serialNum];
    }
    else if ([characteristic.UUID isEqual:[BLeService gattDeviceFirmwareVersionCharacteristicUUID]])
    {
        NSString *FwVerStr = [[NSString alloc] initWithData:characteristic.value
                                        encoding:NSUTF8StringEncoding];
        NSLog(@"Firmware Version = %@", FwVerStr);
        float firmwareVer = [FwVerStr floatValue];
        NSLog(@"Firmware Version = %@", [NSString stringWithFormat:@"%.1f", firmwareVer]);
        [[[BLeDiscovery sharedInstance] conPeripheral] setFirmwareVer:firmwareVer];
        if(self.exitPoint == TRIO_SERVICE)
        {
            [peripheralDelegate blePeripheralDidConnect:peripheral];
        }
    }
    else if([characteristic.UUID isEqual:[BLeService gattDeviceBatteryLevelCharacteristicUUID]])
    {
        int batteryLevel = *(int*) [characteristic.value bytes];
        
        NSLog(@"Battery Level percentage = %d", batteryLevel);
        [[[BLeDiscovery sharedInstance] conPeripheral] setBatteryLevel:batteryLevel];
        
        if(self.exitPoint == BATTERYLEVEL_SERVICE)
        {
            [peripheralDelegate blePeripheralDidConnect:peripheral];
        }
    }
}


-(void)invokeCommand:(CBPeripheral*)peripheral withData:(NSData*)commandData
{

        if(self.dataCharacteristic.properties == (CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite))
        {
            [peripheral writeValue:commandData forCharacteristic:self.dataCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        else if(self.dataCharacteristic.properties == (CBCharacteristicPropertyNotify|CBCharacteristicPropertyWriteWithoutResponse))
        {
            [peripheral writeValue:commandData forCharacteristic:self.dataCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if(self.dataCharacteristic.properties == (CBCharacteristicPropertyIndicate|CBCharacteristicPropertyWriteWithoutResponse))
        {
            [peripheral writeValue:commandData forCharacteristic:self.dataCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if(self.dataCharacteristic.properties == CBCharacteristicPropertyWriteWithoutResponse)
        {
            [peripheral writeValue:commandData forCharacteristic:self.dataCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else
        {
            //Disconnect peripheral if valid characteristic not found.
            [[BLeDiscovery sharedInstance] disconnectPeripheral:peripheral];
        }
}


@end
