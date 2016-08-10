//
//  BleConnectionHandler.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/5/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "BleConnectionHandler.h"
#import "BLeDiscovery.h"

#import "CommandFields.h"

#import "Definitions.h"


//Settings Data Object
#import "UserSettings.h"
#import "ExerciseSettings.h"
#import "CompanySettings.h"
#import "DeviceSettings.h"
#import "ProfileSettings.h"
#import "SensitivitySettings.h"
#import "ScreenSettings.h"
#import "DeviceStatus.h"
#import "ScreenTimeoutCommand.h"

//Misc Data Object
#import "DfuCommand.h"
#import "EEPROMCommand.h"
#import "DeviceModeCommand.h"
#import "DeviceInformationData.h"
#import "AlarmCommandData.h"
#import "TalliesCommandData.h"
#import "ChargingHistoryCommand.h"

#import "AckCommand.h"

//Steps Data Object
#import "StepsTableHeader.h"
#import "StepData.h"

//Profile Data Object
#import "StartProfileRecordingCommand.h"
#import "ProfileTableHeader.h"
#import "ProfileData.h"

//Messaging Data Object
#import "ReadAllImageCodeCommand.h"
#import "EraseMessageCommand.h"
#import "SetMessageCommand.h"
#import "ShowWrittenMessage.h"
#import "MessageSchedule.h"
#import "DisplayOnScreenCommand.h"

@interface BleConnectionHandler()<BleDiscoveryDelegate, BleServiceProtocol>

@property(assign)int allowedModel;

@property(nonatomic, strong)UserSettings *userSettings;
@property(nonatomic, strong)ExerciseSettings *exerciseSettings;
@property(nonatomic, strong)CompanySettings *companySettings;
@property(nonatomic, strong)DeviceSettings *deviceSettings;
@property(nonatomic, strong)ProfileSettings *profileSettings;
@property(nonatomic, strong)SensitivitySettings *sensitivitySettings;
@property(nonatomic, strong)ScreenSettings *screenSettings;
@property(nonatomic, strong)DeviceStatus *deviceStatus;
@property(nonatomic, strong)ScreenTimeoutCommand *screenTimeout;

@property(nonatomic, strong)DfuCommand *dfuCommand;
@property(nonatomic, strong)EEPROMCommand *eepromCommand;
@property(nonatomic, strong)DeviceModeCommand *deviceModeCommand;
@property(nonatomic, strong)DeviceInformationData *deviceInfoCommand;
@property(nonatomic, strong)AlarmCommandData *alarmCommand;
@property(nonatomic, strong)TalliesCommandData *talliesCommand;
@property(nonatomic, strong)ChargingHistoryCommand *chargingHistoryCommand;

@property(nonatomic, strong)AckCommand *ackCommand;

@property(nonatomic, strong)StepsTableHeader *stepsTableHeader;
@property(nonatomic, strong)StepData *stepData;

@property(nonatomic, strong)StartProfileRecordingCommand *startProfileRecordingCommand;
@property(nonatomic, strong)ProfileTableHeader *profileTableHeader;
@property(nonatomic, strong)ProfileData *profileData;

@property(nonatomic, strong)ReadAllImageCodeCommand *allImageCodeData;
@property(nonatomic, strong)EraseMessageCommand *eraseMessageCommand;
@property(nonatomic, strong)SetMessageCommand *setMessageCommand;
@property(nonatomic, strong)ShowWrittenMessage *showWrittenMessage;
@property(nonatomic, strong)MessageSchedule *messageSchedule;
@property(nonatomic, strong)DisplayOnScreenCommand *displayOnScreen;

@property(nonatomic, strong)CommandFields *lastCommandFields;
@property(nonatomic, strong)NSMutableString *rawData;

@property(assign)dataStreamingType dataType;
@property(assign)int packetCounter;
@property(assign)int expectedNoOfPackets;

@property(assign)BOOL didConnect;
@end

@implementation BleConnectionHandler

@synthesize deviceInfo;
@synthesize allowedModel;
@synthesize lastCommandFields;

@synthesize dfuCommand;
@synthesize deviceModeCommand;
@synthesize eepromCommand;
@synthesize deviceInfoCommand;
@synthesize alarmCommand;

@synthesize ackCommand;

@synthesize userSettings;
@synthesize exerciseSettings;
@synthesize companySettings;
@synthesize deviceSettings;
@synthesize profileSettings;
@synthesize sensitivitySettings;
@synthesize screenSettings;

@synthesize stepsTableHeader;
@synthesize stepData;

@synthesize startProfileRecordingCommand;
@synthesize profileTableHeader;
@synthesize profileData;

@synthesize allImageCodeData;
@synthesize eraseMessageCommand;
@synthesize setMessageCommand;
@synthesize showWrittenMessage;
@synthesize messageSchedule;
@synthesize displayOnScreen;

@synthesize dataType;
@synthesize packetCounter;
@synthesize expectedNoOfPackets;

@synthesize modelName;

@synthesize didConnect;

-(id)init
{
    self = [super init];
    if (self)
    {
        [[BLeDiscovery sharedInstance] setDiscoveryDelegate:self];
        [[BLeDiscovery sharedInstance] setPeripheralDelegate:self];
        
        self.rawData = [[NSMutableString alloc] init];
        self.dataType = STEPS_DATA;
        self.packetCounter = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(SendCommand:)
                                                     name:@"SendCommand"
                                                   object:nil];
    }
    return self;
}

-(BOOL)isConnected
{
    return ([[[BLeDiscovery sharedInstance] connectingPeripheral] state] == CBPeripheralStateConnected);
}

-(BOOL)isScanning
{
    return [[BLeDiscovery sharedInstance] isScanning];
}

-(void)startBleDiscoveryWithServices:(NSArray*)services
{
    [[BLeDiscovery sharedInstance] startScanningWithServiceUUID:services];
}

-(void)startBleDiscoveryWithServices:(NSArray*)services modelAllowed:(int)model
{
    NSLog(@"Allowed model: %d",model);
    self.allowedModel = model;
    [[BLeDiscovery sharedInstance] startScanningWithServiceUUID:services];
}
-(void)stopBleDiscovery
{
    [[BLeDiscovery sharedInstance] stopScanning];
}

-(void)disconnect
{
    if([[BLeDiscovery sharedInstance] connectingPeripheral].state == CBPeripheralStateConnected)
    {
        [[BLeDiscovery sharedInstance] disconnectPeripheral:[[BLeDiscovery sharedInstance] connectingPeripheral]];
    }
}

/*################ BLE Discovery delegate ################
 #########################################################*/

- (void) discoveryStatePoweredOff
{
    NSLog(@"Bluetooth setting was turned OFF.");
}
- (void) discoveryStatePoweredOn
{
    NSLog(@"Bluetooth setting is ON.");
}
- (void) discoveryStarted
{
    NSLog(@"BLE Discovery Started.");
}
- (void) discoveryStopped
{
    NSLog(@"BLE Discovery Stopped.");
}

- (void) didDiscoverBleDevice:(CBPeripheral*)peripheral advertisementData:(NSDictionary *)advertisementData signalStrength:(int)RSSI
{
    int validRSSI;
    
    NSString *peripheralName = [advertisementData objectForKey:@"kCBAdvDataLocalName"]?[[advertisementData objectForKey:@"kCBAdvDataLocalName"] lowercaseString]:@"";
    
    peripheralName = [peripheralName length]>0?peripheralName:[peripheral name];
    NSLog(@"Detected peripheral name: %@   RSSI: %d",peripheralName,RSSI);
#ifdef DEBUG
    validRSSI = -120;
#else
    validRSSI = -85;
#endif
    
    [self.connectiondelegate bleDidDiscoverDevice:[peripheral name] signalStrength:RSSI];
    if(RSSI >= validRSSI)
    {
        if([[peripheralName lowercaseString] rangeOfString:[NSString stringWithFormat:@"%d",self.allowedModel]].location != NSNotFound && [peripheralName rangeOfString:[self.modelName lowercaseString]].location != NSNotFound)
       {
           [[BLeDiscovery sharedInstance] connectPeripheral:peripheral];
       }
    }
    
}


/*################ BLE Services delegate ################
 ##########################################################*/

- (void) blePeripheralDidConnect:(CBPeripheral*)peripheral
{
    self.deviceInfo = [[DeviceInformation alloc] init];
    self.deviceInfo.deviceName = [peripheral name];
    self.deviceInfo.firmwareVersion = [[BLeDiscovery sharedInstance] conPeripheral].firmwareVer;
    self.deviceInfo.serialNum = [[BLeDiscovery sharedInstance] conPeripheral].serialNum;
    self.deviceInfo.model = [[BLeDiscovery sharedInstance] conPeripheral].model;
    self.deviceInfo.batteryLevel = [[BLeDiscovery sharedInstance] conPeripheral].batteryLevel;
    
    if((self.deviceInfo.model == FT900 && self.deviceInfo.firmwareVersion >= 2.0f) ||
       (self.deviceInfo.model == PE961 && self.deviceInfo.firmwareVersion >= 5.0f))
    {
        unsigned char * buffer = nil;
        buffer = (unsigned char*) calloc(READ_COMMAND_SIZE,sizeof(unsigned char));
        buffer[0] = self.deviceInfo.model==FT900?0x01:0x1B;
        buffer[1] = 0x40;
        
        NSData *command = [NSData dataWithBytes:buffer length:READ_COMMAND_SIZE];
        [[BLeDiscovery sharedInstance] sendCommand:command];
        NSLog(@"Command Sent: %@",command);
    }
    else
    {
        if(self.deviceInfo.model == self.allowedModel)
        {
            [self.connectiondelegate bleDeviceConnected];
            self.didConnect = YES;
        }
    }
}

- (void) blePeripheralDidDisconnect:(CBPeripheral*)peripheral
{
    self.deviceInfo = nil;
    [self.connectiondelegate bleDeviceDisconnected];
    self.didConnect = NO;
}
- (void) didReceiveResponse:(CBPeripheral*)peripheral data:(NSData*)data
{
    NSUInteger len = [data length];
    Byte *reportData = (Byte*)malloc(len);
    memcpy(reportData, [data bytes], len);
    
    NSString *cleanRawData = [NSString stringWithFormat:@"%@",data];
    cleanRawData = [cleanRawData stringByReplacingOccurrencesOfString:@"<" withString:@""];
    cleanRawData = [cleanRawData stringByReplacingOccurrencesOfString:@">" withString:@""];
    cleanRawData = [cleanRawData stringByReplacingOccurrencesOfString:@" " withString:@""];
    //NSLog(@"%@",cleanRawData);
    
    NSString *rawLog = [NSString stringWithFormat:@"Command response: %@\n",data];
    NSMutableDictionary *rawLogInfo = [[NSMutableDictionary alloc] init];
    [rawLogInfo setObject:rawLog forKey:@"log"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setTextViewData" object:self userInfo:rawLogInfo];
    
    
    NSMutableDictionary* responseInfo = [NSMutableDictionary dictionary];
    if(reportData[0] == 0x1B && reportData[1] == WRITE_DEVICE_SETTINGS && len == 3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.deviceSettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == WRITE_USER_SETTINGS && len == 3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.userSettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == WRITE_EXERCISE_SETTINGS && len == 3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.exerciseSettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == WRITE_COMPANY_SETTINGS && len == 3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.companySettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == WRITE_PROFILE_SETTINGS && len == 3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.profileSettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == SET_SCREEN_TIMEOUT_COMMAND && len == 3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.screenTimeout.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_SCREEN_TIMEOUT_COMMAND && len == SCREEN_TIMEOUT_COMMAND_SIZE)
    {
        cleanRawData = [cleanRawData substringFromIndex:4];
        [self.rawData appendString:cleanRawData];
        [self.screenTimeout parseScreenTimeoutRaw:self.rawData];
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.screenTimeout.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == WRITE_SCREEN_SETTINGS && len == 3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.screenSettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == SHOW_WRITTEN_MESSAGE_COMMAND && len == 3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.showWrittenMessage.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_USER_SETTINGS  && (len ==USER_SETTINGS_COMMAND_LEN || len == FT900_COMMAND_LEN  || len == PE961_COMMAND_LEN1 || len == PE961_COMMAND_LEN2))
    {
        [self.userSettings parseUserSettingsRaw:cleanRawData];
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.userSettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_EXERCISE_SETTINGS  && (len ==3 || len == 4 ))
    {
        [self.exerciseSettings parseExerciseSettingsRaw:cleanRawData];
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.exerciseSettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_COMPANY_SETTINGS  && (len ==14 || len == 15 ))
    {
        [self.companySettings parseCompanySettingsRaw:cleanRawData];
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.companySettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_DEVICE_SETTINGS && (len ==9 || len == 11  || len == 10 || len == 15))
    {
        [self.deviceSettings parseDeviceSettingsRaw:cleanRawData];
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.deviceSettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_PROFILE_SETTINGS && (len == 12 || len == 11 || len == 14))
    {
        [self.profileSettings parseProfileSettingsRaw:cleanRawData];
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.profileSettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_SENSITIVITY_SETTINGS && (len ==5 || len == 3 || len == 6))
    {
        [self.sensitivitySettings parseSensitivitySettingsRaw:cleanRawData];
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.sensitivitySettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_SCREEN_SETTINGS && (len ==6 || len == 10 || len == 12))
    {
        [self.screenSettings parseScreenSettingsRaw:cleanRawData];
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.screenSettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_ALARM_COMMAND && len == 4)
    {
        [self.alarmCommand parseAlarmDataRaw:cleanRawData];
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.alarmCommand.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_DEVICE_MODE_COMMAND && len == 3)
    {
        [self.deviceModeCommand parseDeviceModeRaw:cleanRawData];
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.deviceModeCommand.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == GET_DEVICE_STATUS && len == 3)
    {
        [self.deviceStatus parseDeviceStatusRaw:cleanRawData];
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.deviceStatus.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == GET_MESSAGE_SCHEDULE_COMMAND && len == MESSAGE_SCHEDULE_COMMAND_SIZE)
    {
        cleanRawData = [cleanRawData substringFromIndex:4];
        [self.rawData appendString:cleanRawData];
        [self.messageSchedule parseMesageScheduleDataRaw:self.rawData];
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.messageSchedule.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == SET_MESSAGE_SCHEDULE_COMMAND && len == 3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.messageSchedule.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == ERASE_MESSAGES_COMMAND && len == 3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.eraseMessageCommand.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == WRITE_DEVICE_STATUS && len == 3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.deviceStatus.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == DEVICE_INFO_COMMAND && (len == 19 || len == DEVICE_INFO_COMMAND_SIZE))
    {
        if(!self.didConnect)
        {
            self.deviceInfoCommand = [[DeviceInformationData alloc] init];
            [self.deviceInfoCommand parseDeviceInfoRaw:cleanRawData];
            self.deviceInfo.betaNumber = self.deviceInfoCommand.betaVersionNumber;
            if(self.deviceInfo.model == self.allowedModel)
            {
                [self.connectiondelegate bleDeviceConnected];
                self.didConnect = YES;
            }
        }
        else
        {
            [self.deviceInfoCommand parseDeviceInfoRaw:cleanRawData];
            [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
            [responseInfo setObject:self.deviceInfoCommand.commandFields forKey:@"commandFields"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
        }
    }
    else if(reportData[0] == 0x1B && reportData[1] == WRITE_SENSITIVITY_SETTINGS && len ==3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.sensitivitySettings.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_STEPS_TABLE_DATA && (len ==19 || len ==20))
    {
        cleanRawData = [cleanRawData substringFromIndex:6];
        [self.rawData appendString:cleanRawData];
        if (reportData[2] == 0x00)
        {
            [self.stepsTableHeader parseStepsTableHeaderRaw:self.rawData];
            [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
            [responseInfo setObject:self.stepsTableHeader.commandFields forKey:@"commandFields"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
        }
        else
        {
            self.packetCounter--;
            if(self.packetCounter == 0)
            {
                [self SendAckCommand:self.lastCommandFields.readCommandID];
                self.packetCounter = self.expectedNoOfPackets;
            }
        }
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_PROFILE_TABLE_DATA_COMMAND && (len ==16 || len == 19))
    {
        cleanRawData = len == 16?[cleanRawData substringFromIndex:6]:[cleanRawData substringWithRange:NSMakeRange(6, 26)];
        [self.rawData appendString:cleanRawData];
        if (reportData[2] == 0x00)
        {
            [self.profileTableHeader parseProfileBlocksFlagData:self.rawData];
            [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
            [responseInfo setObject:self.profileTableHeader.commandFields forKey:@"commandFields"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
        }
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_TALLIES_DATA_COMMAND && len == TALLIES_COMMAND_SIZE )
    {
        cleanRawData =[cleanRawData substringFromIndex:6];
        [self.rawData appendString:cleanRawData];
        if (reportData[2] == 0x00)
        {
            [self.talliesCommand parseTalliesDataRaw:self.rawData];
            [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
            [responseInfo setObject:self.talliesCommand.commandFields forKey:@"commandFields"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
        }
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_CHARGING_HISTORY_DATA_COMMAND && (len == CHARGING_HISTORY_COMMAND_SIZE || len == 19) )
    {
        cleanRawData =[cleanRawData substringFromIndex:4];
        [self.rawData appendString:cleanRawData];
        [self.chargingHistoryCommand parseChargingHistoryDataRaw:self.rawData];
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.chargingHistoryCommand.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == WRITE_STEPS_TABLE_DATA && len ==3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.stepsTableHeader.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_STEPS_DATA_BY_HOUR_RANGE && len ==3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
        [responseInfo setObject:self.stepData.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0]== 0x1B && reportData[1] == DFU_COMMAND && len==3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.dfuCommand.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0]== 0x1B && reportData[1] == EEPROM_COMMAND && len==3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.eepromCommand.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0]== 0x1B && reportData[1] == SET_DEVICE_MODE_COMMAND && len==3)
    {
        [responseInfo setObject:[NSNumber numberWithInt:WRITE] forKey:@"commandAction"];
        [responseInfo setObject:self.deviceModeCommand.commandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == SET_ALARM_COMMAND && len == 3)
    {
        [responseInfo setObject:self.lastCommandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == SET_MESSAGE_COMMAND && (len == 5 || len == 3))
    {
        int packetNumber = [[cleanRawData substringFromIndex:6] intValue];
        if(reportData[2] == 0x00 && packetNumber > 0x00)
        {
            [self.setMessageCommand.setMessageCommandsArray removeObjectAtIndex:0];
            NSData *command = [self.setMessageCommand getCommand];
            NSLog(@"Command Sent: %@",command);
            NSString *rawLog = [NSString stringWithFormat:@"Command Sent: %@\n",command];
            NSMutableDictionary *rawLogInfo = [[NSMutableDictionary alloc] init];
            [rawLogInfo setObject:rawLog forKey:@"log"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setTextViewData" object:self userInfo:rawLogInfo];
            
            [[BLeDiscovery sharedInstance] sendCommand:command];
            
            return;
        }
        
        [responseInfo setObject:self.lastCommandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == DISPLAY_ON_SCREEN_COMMAND && (len == 5 || len == 3))
    {
        int packetNumber = [[cleanRawData substringFromIndex:6] intValue];
        if(reportData[2] == 0x00 && packetNumber > 0x00)
        {
            [self.displayOnScreen.setMessageCommandsArray removeObjectAtIndex:0];
            NSData *command = [self.displayOnScreen getCommand];
            NSLog(@"Command Sent: %@",command);
            NSString *rawLog = [NSString stringWithFormat:@"Command Sent: %@\n",command];
            NSMutableDictionary *rawLogInfo = [[NSMutableDictionary alloc] init];
            [rawLogInfo setObject:rawLog forKey:@"log"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setTextViewData" object:self userInfo:rawLogInfo];

            [[BLeDiscovery sharedInstance] sendCommand:command];
            
            return;
        }
        
        [responseInfo setObject:self.lastCommandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == START_PROFILE_RECORDING_COMMAND && (len == 3 || len == 4))
    {
        self.startProfileRecordingCommand.recordDuration = 0;
        if(len == 4)
        {
           [self.startProfileRecordingCommand parseRecordDuration:cleanRawData];
        }
        [responseInfo setObject:self.lastCommandFields forKey:@"commandFields"];
        [responseInfo setObject:[NSNumber numberWithInt:self.startProfileRecordingCommand.recordDuration] forKey:@"recordDuration"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_PROFILE_DATA_COMMAND && len == 20)
    {
        self.packetCounter--;
        self.dataType = PROFILE_DATA;
        [self.rawData appendString:cleanRawData];
        if(self.packetCounter == 0)
        {
            [self SendAckCommand:self.lastCommandFields.readCommandID];
            self.packetCounter = self.expectedNoOfPackets;
        }
    }
    else if(reportData[0] == 0x1B && reportData[1] == READ_PROFILE_DATA_COMMAND && len == 3)
    {
        [responseInfo setObject:self.lastCommandFields forKey:@"commandFields"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else if(reportData[0] == 0x1B && reportData[1] == ACK_COMMAND && len == 3)
    {
        if(reportData[2] == 0)
        {
            NSLog(@"ACK command was sent successfully!");
        }
        else{
            NSLog(@"ACK command failed!");
        }
    }
    else if(reportData[0] == 0x1B && reportData[1] == UNSUPPORTED_COMMAND && len == 2)
    {
        [responseInfo setObject:self.lastCommandFields forKey:@"commandFields"];
        [responseInfo setObject:[NSNumber numberWithBool:YES] forKey:@"UnsupportedCommand"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
    }
    else
    {
        
        [self.rawData appendString:cleanRawData];
        NSString *rawData = self.rawData;
        NSLog(@"Raw data length %d",(int)[self.rawData length]/2);
       

        if([rawData length]>40)
        {
            NSString *terminatorString = [rawData substringWithRange:NSMakeRange([rawData length]-8, 8)];
            
            if([[terminatorString lowercaseString] isEqualToString:@"ffffffff"])
            {
                NSString *tempRawData = [NSString stringWithString:rawData];
                for(int i=0; i<[rawData length];)
                {
                    if([[[tempRawData substringWithRange:NSMakeRange([tempRawData length]-2, 2)] lowercaseString] isEqualToString:@"ff"])
                    {
                        tempRawData  = [tempRawData substringWithRange:NSMakeRange(0, [tempRawData length]-2)];
                    }
                    else
                    {
                        //tempRawData  = [tempRawData substringWithRange:NSMakeRange(0, [tempRawData length]-4)];
                        break;
                    }
                    i+=2;
                }
                
                [self.rawData setString:@""];
                self.rawData = [NSMutableString stringWithString:tempRawData];
                
                if(self.dataType == PROFILE_DATA)
                {
                    [self.profileData parseProfileData:self.rawData];
                    [responseInfo setObject:self.profileData.commandFields forKey:@"commandFields"];
                    [self.rawData setString:@""];
                }
                else if(self.dataType == SEIZURE_DATA)
                {
                    
                }
                else
                {
                    [self.stepData parseStepsData:self.rawData];
                    [responseInfo setObject:self.stepData.commandFields forKey:@"commandFields"];
                    [self.rawData setString:@""];
                }
                
                [responseInfo setObject:[NSNumber numberWithInt:READ] forKey:@"commandAction"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveCommandResponse" object:self userInfo:responseInfo];
            }
            else
            {
                self.packetCounter--;
                if(self.packetCounter == 0)
                {
                    [self SendAckCommand:self.lastCommandFields.readCommandID];
                    self.packetCounter = self.expectedNoOfPackets;
                }
            }
        }
        else
        {
            self.packetCounter--;
            if(self.packetCounter == 0)
            {
                [self SendAckCommand:self.lastCommandFields.readCommandID];
                self.packetCounter = self.expectedNoOfPackets;
            }
        }

    }
}

//################ Send Command Handler #######################

-(void)SendAckCommand:(int)commandID
{
    NSData *command = [[NSData alloc] init];
    self.ackCommand = [[AckCommand alloc] init];
    command = [self.ackCommand getCommand:commandID];
    NSLog(@"ACK Command Sent: %@",command);
    [[BLeDiscovery sharedInstance] sendCommand:command];
}

//############## Send Command #######################//
-(void)SendCommand:(NSNotification*)notification
{
    [self.rawData setString:@""];
    self.dataType = STEPS_DATA;
    NSDictionary* userInfo = notification.userInfo;
    supportedCommandAction action = [[userInfo objectForKey:@"commandAction"] intValue];
    CommandFields *cmdFields = [userInfo objectForKey:@"commandFields"];
    self.packetCounter = self.expectedNoOfPackets = [[userInfo objectForKey:@"totalPackets"] intValue];
    self.lastCommandFields = cmdFields;
    
    NSData *command = [[NSData alloc] init];
    if([cmdFields.featureName isEqualToString:@"User Settings"])
    {
        self.userSettings = [[UserSettings alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.userSettings getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Exercise Settings"])
    {
        self.exerciseSettings = [[ExerciseSettings alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.exerciseSettings getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Company Settings"])
    {
        self.companySettings = [[CompanySettings alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.companySettings getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Device Settings"])
    {
        self.deviceSettings = [[DeviceSettings alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.deviceSettings getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Profile Settings"])
    {
        self.profileSettings = [[ProfileSettings alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.profileSettings getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Steps Table Header"])
    {
        self.stepsTableHeader = [[StepsTableHeader alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        self.stepsTableHeader.selectedFieldIndex = [[userInfo objectForKey:@"index"] longValue];
        command = [self.stepsTableHeader getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Sensitivity Settings"])
    {
        self.sensitivitySettings = [[SensitivitySettings alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        
        command = [self.sensitivitySettings getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Steps by Hour Range"]  ||
            [cmdFields.featureName isEqualToString:@"Current Hour Steps"])
    {
        self.stepData = [[StepData alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.stepData getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"DFU Command"])
    {
        self.dfuCommand = [[DfuCommand alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.dfuCommand getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"EEPROM Command"])
    {
        self.eepromCommand = [[EEPROMCommand alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.eepromCommand getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Device Mode Command"])
    {
        self.deviceModeCommand = [[DeviceModeCommand alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.deviceModeCommand getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Device INFO Command"])
    {
        self.deviceInfoCommand = [[DeviceInformationData alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.deviceInfoCommand getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Alarm Command"])
    {
        self.alarmCommand = [[AlarmCommandData alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.alarmCommand getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Start Profile Recording"])
    {
        self.startProfileRecordingCommand = [[StartProfileRecordingCommand alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.startProfileRecordingCommand getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Profile Table Header"])
    {
        self.profileTableHeader = [[ProfileTableHeader alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.profileTableHeader getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Read Profile Data"])
    {
        self.profileData = [[ProfileData alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.profileData getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Screen Settings"])
    {
        self.screenSettings = [[ScreenSettings alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.screenSettings getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Screen Timeout Settings"])
    {
        self.screenTimeout = [[ScreenTimeoutCommand alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.screenTimeout getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Tallies Command"])
    {
        self.talliesCommand = [[TalliesCommandData alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.talliesCommand getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Charging History"])
    {
        self.chargingHistoryCommand = [[ChargingHistoryCommand alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.chargingHistoryCommand getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Read All Image Code"])
    {
        self.allImageCodeData = [[ReadAllImageCodeCommand alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.allImageCodeData getCommand];
    }
    else if([cmdFields.featureName isEqualToString:@"Erase Message Command"])
    {
        self.eraseMessageCommand = [[EraseMessageCommand alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.eraseMessageCommand getCommand];
    }
    else if([cmdFields.featureName isEqualToString:@"Device Status"])
    {
        self.deviceStatus = [[DeviceStatus alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.deviceStatus getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Set Message Command"])
    {
        self.setMessageCommand = [[SetMessageCommand alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.setMessageCommand getCommand];
    }
    else if([cmdFields.featureName isEqualToString:@"Set/Get Message Schedule"])
    {
        self.messageSchedule = [[MessageSchedule alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.messageSchedule getCommands];
    }
    else if([cmdFields.featureName isEqualToString:@"Show Written Message"])
    {
        self.showWrittenMessage = [[ShowWrittenMessage alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.showWrittenMessage getCommand];
    }
    else if([cmdFields.featureName isEqualToString:@"Display On Screen"])
    {
        self.displayOnScreen = [[DisplayOnScreenCommand alloc] initWithCommandFields:cmdFields deviceInfo:self.deviceInfo commandAction:action];
        command = [self.displayOnScreen getCommand];
    }
    
    
    NSLog(@"Command Sent: %@",command);
    NSString *rawLog = [NSString stringWithFormat:@"Command Sent: %@\n",command];
    NSMutableDictionary *rawLogInfo = [[NSMutableDictionary alloc] init];
    [rawLogInfo setObject:rawLog forKey:@"log"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setTextViewData" object:self userInfo:rawLogInfo];
    
    [[BLeDiscovery sharedInstance] sendCommand:command];
}

@end
