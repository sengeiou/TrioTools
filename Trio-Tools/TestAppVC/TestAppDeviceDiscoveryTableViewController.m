//
//  TestAppDeviceDiscoveryTableViewController.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 7/10/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "TestAppDeviceDiscoveryTableViewController.h"
#import "TestAppCommandTypeTableViewController.h"

#import "ConnectedTableViewCell.h"
#import "Definitions.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BleConnectionHandler.h"
#import "FeatureTypeXmlParser.h"
#import "CommadDetailsXmlParser.h"
#import "AppDelegate.h"




@interface TestAppDeviceDiscoveryTableViewController ()<ConnectionProtocol>
@property (strong, nonatomic)AppDelegate * myDelegate;
@property(strong, nonatomic)TestAppCommandTypeTableViewController *testCommandTypeVC;
@property(strong, nonatomic)BleConnectionHandler *connectionHandler;
@property(strong, nonatomic)NSString *detectedDeviceLog;
@property(strong, nonatomic)NSArray *servicesToDiscovery;
@property(strong, nonatomic)UISegmentedControl *testTypeSegmentedControl;

@end

@implementation TestAppDeviceDiscoveryTableViewController

@synthesize SelectedTrioModel;
@synthesize connectionHandler;
@synthesize servicesToDiscovery;
@synthesize testTypeSegmentedControl;
@synthesize selectedModel;

@synthesize myDelegate;
@synthesize testCommandTypeVC;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.connectionHandler = [[BleConnectionHandler alloc] init];
    [self.connectionHandler setConnectiondelegate:self];
    self.detectedDeviceLog = [[NSString alloc] init];
    self.title = @"Devices";

    self.testCommandTypeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"commandTypeVC"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
#if TARGET_IPHONE_SIMULATOR
    self.connectionHandler.deviceInfo = [[DeviceInformation alloc] init];
    self.connectionHandler.deviceInfo.firmwareVersion = 0.0f;
    self.connectionHandler.deviceInfo.model = PE932;
    self.connectionHandler.deviceInfo.serialNum = 123456789;
    
    [self.tableView reloadData];
#else
#endif
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound)
    {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [self.connectionHandler disconnect];
        
        if(self.connectionHandler.isScanning)
           [self.connectionHandler stopBleDiscovery];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
#if TARGET_IPHONE_SIMULATOR
    
#else
    if(!self.connectionHandler.isScanning  && !self.connectionHandler.isConnected)
    {
        servicesToDiscovery = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"3aa7ff01-c26a-4cd2-ad1c-8cf29d6874f4"],[CBUUID UUIDWithString:@"180F"], [CBUUID UUIDWithString:@"180A"],  nil];
        [self.connectionHandler startBleDiscoveryWithServices:servicesToDiscovery modelAllowed:self.SelectedTrioModel];
        self.connectionHandler.modelName = self.selectedModel.modelName;
    }
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    int count = self.connectionHandler.deviceInfo!=nil?2:1;
    return count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //self.selectedIndexpath = [self.tableView indexPathForSelectedRow];
    if (editingStyle == UITableViewCellEditingStyleDelete && self.connectionHandler.deviceInfo!=nil)
    {
        if(indexPath.row == 0)
        {
            [self.connectionHandler disconnect];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    BOOL canEdit = NO;
    if (self.connectionHandler.deviceInfo!=nil)
    {
        if(indexPath.row == 0)
        {
            canEdit = YES;
        }
    }

    return canEdit;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    
    UILabel *labelHeaderTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.view.frame.size.width, 25)];
    labelHeaderTitle.textAlignment = NSTextAlignmentCenter;

    if(self.connectionHandler.deviceInfo)
    {
        labelHeaderTitle.text = @"Connected";
        headerView.backgroundColor = [UIColor greenColor];
    }
    else
    {
        labelHeaderTitle.text = [NSString stringWithFormat: @"Scanning for %@ devices...",self.selectedModel.modelName];
        headerView.backgroundColor = [UIColor clearColor];
    }
    
    [headerView addSubview:labelHeaderTitle];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    if(indexPath.row == 0 && self.connectionHandler.deviceInfo!=nil)
    {
        NSString *featuresFilename = [NSString stringWithFormat:@"%@Features",self.selectedModel.modelName];
        self.testCommandTypeVC.features = [FeatureTypeXmlParser parseCommandType:featuresFilename];
        NSString *commandDetailsFilename = [NSString stringWithFormat:@"%@CommandDetails.xml",self.selectedModel.modelName];
        self.testCommandTypeVC.cmdList = [CommadDetailsXmlParser parseCommandDetailsXml:commandDetailsFilename];
        self.testCommandTypeVC.isConnected = YES;
#if TARGET_IPHONE_SIMULATOR
        self.connectionHandler.deviceInfo.model = self.selectedModel.modelNumber;
#endif
        [self.navigationController pushViewController:self.testCommandTypeVC animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    BOOL cellIsPreviouslyNil = YES;
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cellIsPreviouslyNil = YES;
    }

    NSString *batteryLevelStr = [NSString stringWithFormat:@"%.2d", self.connectionHandler.deviceInfo.batteryLevel];
    NSString *firmwareVer = [NSString stringWithFormat:@"%.1f", self.connectionHandler.deviceInfo.firmwareVersion];
    NSString *deviceName = self.connectionHandler.deviceInfo.deviceName;
    NSString *betaNumber = [NSString stringWithFormat:@"%.2d",self.connectionHandler.deviceInfo.betaNumber];
    
    NSString *firmwareInfoStr = [NSString stringWithFormat:@"Connected - FW version: %@",firmwareVer];
    
    if((self.connectionHandler.deviceInfo.model == FT900 && self.connectionHandler.deviceInfo.firmwareVersion >= 2.0f) ||
       (self.connectionHandler.deviceInfo.model == PE961 && self.connectionHandler.deviceInfo.firmwareVersion >= 5.0f) ||
       self.connectionHandler.deviceInfo.betaNumber > 0)
    {
        firmwareInfoStr = [NSString stringWithFormat:@"Connected - FW version: %@ Beta %@",firmwareVer,betaNumber];
    }
    
    if(indexPath.row==0 && self.connectionHandler.deviceInfo!=nil)
    {
        UIButton *clearBtn = (UIButton*) [cell.contentView viewWithTag:1000];
        UITextView *textLog =(UITextView*) [cell.contentView viewWithTag:2000];
        UILabel *label = (UILabel*) [cell.contentView viewWithTag:3000];
        UILabel *labelTestType = (UILabel*) [cell.contentView viewWithTag:100];
        UISegmentedControl *testTypeControl = (UISegmentedControl*) [cell.contentView viewWithTag:200];
        
        textLog.hidden = YES;
        label.hidden = YES;
        clearBtn.hidden = YES;
        labelTestType.hidden = YES;
        testTypeControl.hidden = YES;
        
        UILabel *content = (UILabel*) [cell.contentView viewWithTag:5000+indexPath.row];
        UIActivityIndicatorView *activity = (UIActivityIndicatorView*)[cell.contentView viewWithTag:6000+indexPath.row];
        UILabel *connection = (UILabel*)[cell.contentView viewWithTag:8000+indexPath.row];
        UILabel *progressLabel =(UILabel*)[cell.contentView viewWithTag:7000+indexPath.row];
        UILabel *batteryLevel =(UILabel*)[cell.contentView viewWithTag:9000+indexPath.row];
        
        content.hidden = NO;
        activity.hidden = NO;
        connection.hidden = NO;
        progressLabel.hidden = NO;
        batteryLevel.hidden = NO;
        if(cellIsPreviouslyNil)
        {
            //UILabel *rowLabel = [[UILabel alloc] init];
            content.backgroundColor = [UIColor clearColor];
            
            content.frame = CGRectMake(10, 5, 230, 30);
            content.textColor = [UIColor blackColor];
            content.font = [UIFont fontWithName:@"Arial-BoldMT" size:20.0];
            
            content.text = deviceName;
            //content.tag = 5000 + 0;//indexPath.row;
            
            //UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activity.frame = CGRectMake(10, 60, 20, 20);
            activity.tag = 6000;
            [activity stopAnimating];
            
            //UILabel *connection = [[UILabel alloc] init];
            connection.backgroundColor = [UIColor clearColor];
            connection.frame = CGRectMake(10, 35, 290, 20);
            connection.text  = firmwareInfoStr;//[NSString stringWithFormat:@"Connected - FW version: %@",firmwareVer];
            
            connection.textColor = [UIColor blackColor];
            connection.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
            connection.tag = 8000;
            
            //UILabel *batteryLevel = [[UILabel alloc] init];
            batteryLevel.backgroundColor = [UIColor clearColor];
            batteryLevel.frame = CGRectMake(10, 60, 400, 20);
            batteryLevel.text  = [NSString stringWithFormat:@"Battery Level: %@ %%", batteryLevelStr];
            
            batteryLevel.textColor = [UIColor blackColor];
            batteryLevel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:14];
            batteryLevel.tag = 9000;
            
            //UILabel *progressLabel = [[UILabel alloc] init];
            progressLabel.backgroundColor = [UIColor clearColor];
            progressLabel.frame = CGRectMake(10, 80, 400, 20);
            progressLabel.text  =  @"Tap to configure.";//@"Status: Waiting for commmand...";
            
            progressLabel.textColor = [UIColor blackColor];
            progressLabel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:14];
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        else
        {
            UILabel *content = (UILabel*) [cell.contentView viewWithTag:5000+indexPath.row];
            UIActivityIndicatorView *activity = (UIActivityIndicatorView*)[cell.contentView viewWithTag:6000+indexPath.row];
            UILabel *connection = (UILabel*)[cell.contentView viewWithTag:8000+indexPath.row];
            UILabel *progressLabel =(UILabel*)[cell.contentView viewWithTag:7000+indexPath.row];
            UILabel *batteryLevel =(UILabel*)[cell.contentView viewWithTag:9000+indexPath.row];

            [activity stopAnimating];
            content.text = deviceName;
            connection.text  = firmwareInfoStr;//[NSString stringWithFormat:@"Connected - FW version: %@",firmwareVer];
            batteryLevel.text =  [NSString stringWithFormat:@"Battery Level: %@ %%", batteryLevelStr];
            progressLabel.text  =  @"Tap to configure.";

        }
    }
    else
    {
        UILabel *content = (UILabel*) [cell.contentView viewWithTag:5000]!=nil?(UILabel*) [cell.contentView viewWithTag:5000]:[[UILabel alloc] init];
        content.tag = 5000;
        content.backgroundColor = [UIColor clearColor];
        
        content.frame = CGRectMake(10, 5, 200, 30);
        content.textColor = [UIColor blackColor];
        content.font = [UIFont fontWithName:@"Arial-BoldMT" size:20.0];
        
        content.text = deviceName;
        
        UIActivityIndicatorView *activity = (UIActivityIndicatorView*)[cell.contentView viewWithTag:6000]!=nil?(UIActivityIndicatorView*)[cell.contentView viewWithTag:6000]:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activity.frame = CGRectMake(10, 60, 20, 20);
        [activity stopAnimating];
        activity.tag = 6000;
        UILabel *connection = (UILabel*)[cell.contentView viewWithTag:8000]!=nil? (UILabel*)[cell.contentView viewWithTag:8000]:[[UILabel alloc] init];
        connection.backgroundColor = [UIColor clearColor];
        connection.frame = CGRectMake(10, 35, 290, 20);
        connection.text  = firmwareInfoStr;//[NSString stringWithFormat:@"Connected - FW version: %@",firmwareVer ];
        connection.textColor = [UIColor blackColor];
        connection.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
        connection.tag = 8000;
        
        UILabel *progressLabel = (UILabel*)[cell.contentView viewWithTag:7000]!=nil? (UILabel*)[cell.contentView viewWithTag:7000]:[[UILabel alloc] init];
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.frame = CGRectMake(10, 80, 400, 20);
        progressLabel.textColor = [UIColor blackColor];
        progressLabel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:14];
        progressLabel.tag = 7000;
        
        UILabel *batteryLevel = (UILabel*)[cell.contentView viewWithTag:9000]!=nil?(UILabel*)[cell.contentView viewWithTag:9000]:[[UILabel alloc] init];
        batteryLevel.backgroundColor = [UIColor clearColor];
        batteryLevel.frame = CGRectMake(10, 80, 400, 20);
        batteryLevel.text  =  [NSString stringWithFormat:@"Battery Level: %@ %%", batteryLevelStr];
        batteryLevel.textColor = [UIColor blackColor];
        batteryLevel.font = [UIFont fontWithName:@"Arial-ItalicMT" size:14];
        batteryLevel.tag = 9000;
        
        content.hidden = YES;
        activity.hidden = YES;
        connection.hidden = YES;
        progressLabel.hidden = YES;
        batteryLevel.hidden = YES;
        
        
        
        UILabel *detectionLogLabel =(UILabel*) [cell.contentView viewWithTag:3000]!=nil?(UILabel*) [cell.contentView viewWithTag:3000]: [[UILabel alloc] init];
        detectionLogLabel.tag = 3000;
        detectionLogLabel.textColor = [UIColor redColor];
        detectionLogLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
        detectionLogLabel.frame = CGRectMake(10, 20, 300, 20);
        detectionLogLabel.text = @"Detected BLE devices advertise name:";
        detectionLogLabel.hidden = NO;
        
        UITextView *textLog = (UITextView*) [cell.contentView viewWithTag:2000]!=nil?(UITextView*) [cell.contentView viewWithTag:2000]: [[UITextView alloc] init];
        textLog.backgroundColor = [UIColor blackColor];
        textLog.textColor = [UIColor lightGrayColor];
        textLog.tag = 2000;
        textLog.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
        textLog.frame = self.connectionHandler.deviceInfo!=nil?CGRectMake(10, 60, self.view.frame.size.width-20, 180): CGRectMake(10, 60, self.view.frame.size.width-20, 250);
        textLog.text = self.detectedDeviceLog;
        textLog.editable = NO;
        [textLog scrollRangeToVisible:NSMakeRange([textLog.text length], 0)];
        textLog.hidden = NO;
        
        UIButton *clearBtn = (UIButton*) [cell.contentView viewWithTag:1000]!=nil?(UIButton*)[cell.contentView viewWithTag:1000]:[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [clearBtn setTitle:@"Clear" forState:UIControlStateNormal];
        clearBtn.tag = 1000;
        [clearBtn.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:24]];

        clearBtn.frame = self.connectionHandler.deviceInfo!=nil?CGRectMake(10, 250, 90, 60):CGRectMake(10, 330, 90, 60);
        clearBtn.hidden = NO;
        clearBtn.layer.borderWidth = 1.0f;
        clearBtn.layer.borderColor = [UIColor grayColor].CGColor;
        clearBtn.layer.cornerRadius = 10.0f;
        [clearBtn addTarget:self
                     action:@selector(clearLog)
           forControlEvents:UIControlEventTouchUpInside];
        
        int offset = [self iPhone6or6Plus]?50:0;
        
        UILabel *labelTestType = (UILabel*) [cell.contentView viewWithTag:100]!=nil?(UILabel*) [cell.contentView viewWithTag:100]: [[UILabel alloc] init];
        labelTestType.frame=self.connectionHandler.deviceInfo!=nil?CGRectMake(110+offset, 255, 130, 50):CGRectMake(110+offset, 335, 130, 50);
        labelTestType.text = @"Test Type:";
        labelTestType.tag = 100;
        labelTestType.hidden = YES;
        labelTestType.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
        labelTestType.textColor = [UIColor blueColor];
        
        UISegmentedControl *testTypeControl =  (UISegmentedControl*) [cell.contentView viewWithTag:200]!=nil?(UISegmentedControl*) [cell.contentView viewWithTag:200]:[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Manual",@"Auto", nil]];
        testTypeControl.frame = self.connectionHandler.deviceInfo!=nil?CGRectMake(200+offset, 260, 110, 40):CGRectMake(200+offset, 340, 110, 40);
        testTypeControl.tag = 200;
        testTypeControl.hidden = YES;
        testTypeControl.selectedSegmentIndex = 0;
        
        self.testTypeSegmentedControl = testTypeControl;
        
        [cell.contentView addSubview:testTypeControl];
        [cell.contentView addSubview:labelTestType];
        [cell.contentView addSubview:detectionLogLabel];
        [cell.contentView addSubview:textLog];
        [cell.contentView addSubview:clearBtn];
        [cell.contentView addSubview:content];
        [cell.contentView addSubview:connection];
        [cell.contentView addSubview:progressLabel];
        [cell.contentView addSubview:activity];
        [cell.contentView addSubview:batteryLevel];
        
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    
    return cell;
}

-(void)clearLog
{
    self.detectedDeviceLog = @"";
    NSIndexPath *indexPath =self.connectionHandler.deviceInfo!=nil ?[NSIndexPath indexPathForRow:1 inSection:0]:[NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextView *textLog = (UITextView*) [cell.contentView viewWithTag:2000];
    textLog.text = self.detectedDeviceLog;
    [textLog scrollRangeToVisible:NSMakeRange([textLog.text length], 0)];
}

-(BOOL)iPhone6or6Plus
{
    BOOL iSiPhone6orPlus = NO;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if([[UIScreen mainScreen] bounds].size.height == 667 ||
           [[UIScreen mainScreen] bounds].size.height == 736)
        {
            iSiPhone6orPlus = YES;
        }
       
    }
    return iSiPhone6orPlus;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height =110;
    if(self.connectionHandler.deviceInfo != nil)
    {
        if(indexPath.row==0)
        {
            height = 110;
        }
        else if(indexPath.row==1)
        {
            height = 370;
        }
    }
    else
    {
        height = 480;
    }
    return height;
}



/*############ BLE Connection Delegates ##################*/

- (void) bleDeviceConnected
{
    self.myDelegate.connectedFirmwareVersion = self.connectionHandler.deviceInfo.firmwareVersion;
    [self.tableView reloadData];
    
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"status"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectionState" object:self userInfo:userInfo];
}
- (void) bleDeviceDisconnected
{
    [self.tableView reloadData];
    
    if (self.isViewLoaded && self.view.window &&
        ([self.navigationController.viewControllers indexOfObject:self]>0))
    {
        [self.connectionHandler startBleDiscoveryWithServices:servicesToDiscovery modelAllowed:self.SelectedTrioModel];
    }
    
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"status"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectionState" object:self userInfo:userInfo];
}

- (void) bleDidDiscoverDevice:(NSString*)deviceName signalStrength:(int)rssiValue
{
    NSIndexPath *indexPath =self.connectionHandler.deviceInfo!=nil ?[NSIndexPath indexPathForRow:1 inSection:0]:[NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextView *textLog = (UITextView*) [cell.contentView viewWithTag:2000];
    if ([self.detectedDeviceLog length]>1000) {
        self.detectedDeviceLog = @"";
    }
    self.detectedDeviceLog = [self.detectedDeviceLog stringByAppendingString:[NSString stringWithFormat: @"%@         RSSI:%d\n",deviceName, rssiValue]];
    
    textLog.text = self.detectedDeviceLog;
    [textLog scrollRangeToVisible:NSMakeRange([textLog.text length], 0)];
}

@end
