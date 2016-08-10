//
//  TestAppCommandDetailsViewController.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/13/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "TestAppCommandDetailsViewController.h"
#import "TestAppUpdateStepTableViewController.h"

#import "TestAppProfileGraphViewController.h"

#import "WCFRequest.h"
#import "WCFResponse.h"

#import "ProfileData.h"
#import "ProfileTableHeader.h"
#import "ProfileTable.h"
#import "StepsTableHeader.h"
#import "StepData.h"
#import "Definitions.h"
#import "Utilities.h"
#import "Field.h"

#import "AppDelegate.h"

#import "KeyboardBar.h"

@interface TestAppCommandDetailsViewController ()<UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource,KeyboardBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic)AppDelegate * myDelegate;

@property(strong, nonatomic)TestAppUpdateStepTableViewController *updateTableVC;
@property(strong, nonatomic)TestAppProfileGraphViewController *profileDataGraphVC;

// Override inputAccessoryView to readWrite
@property (nonatomic, readwrite, retain) UIView *inputAccessoryView;
@property (weak, nonatomic) id<KeyboardBarDelegate> keyboardBarDelegate;

@property(strong,nonatomic)UILabel *labelConnectionStatus;
@property(strong,nonatomic)UILabel *labelRawDataCaption;
@property(strong,nonatomic)UITextField *txtActiveTextField;

@property (strong, nonatomic) UIPickerView* pickerView;
@property (strong, nonatomic) UIDatePicker* dateTimePickerView;
@property (strong, nonatomic) NSMutableArray *pickerDataArray;
@property (assign) int selectedIndex;

@property (strong, nonatomic)UIView *customToolbar;

@property (strong, nonatomic)UIToolbar *toolbar;
@property (strong, nonatomic)UITextField *toolBarTextField;
@property (strong, nonatomic)UILabel *labelToolBarItemCaption;
@property (strong, nonatomic)NSString *textViewRawLog;

@property (strong, nonatomic)NSTimer *commandTimer;
@property (strong, nonatomic)NSTimer *profileRecordingTimer;
@property (assign)int profileRecordingDuration;

@property(strong, nonatomic)UIAlertView *alert;
@end

@implementation TestAppCommandDetailsViewController

@synthesize labelConnectionStatus;
@synthesize btnReadWrite;
@synthesize segmentedReadWriteCommand;
@synthesize myTableView;
@synthesize cmdFields;
@synthesize textViewRawData;
@synthesize txtActiveTextField;
@synthesize labelRawDataCaption;

@synthesize customToolbar;

@synthesize toolbar;
@synthesize toolBarTextField;
@synthesize labelToolBarItemCaption;

@synthesize textViewRawLog;

@synthesize isReceivingResponse;

@synthesize commandTimer;
@synthesize profileRecordingTimer;

@synthesize alert;

@synthesize pickerDataArray;
@synthesize pickerView;
@synthesize dateTimePickerView;


- (void)didTouchView {
    [self.view becomeFirstResponder];
}

// Override canBecomeFirstResponder
// to allow this view to be a responder
- (BOOL) canBecomeFirstResponder {
    return YES;
}

// Override inputAccessoryView to use
// an instance of KeyboardBar
- (UIView *)inputAccessoryView {
    if(!_inputAccessoryView) {
        _inputAccessoryView = [[KeyboardBar alloc] initWithDelegate:self.keyboardBarDelegate];
    }
    return _inputAccessoryView;
}

-(void)showResults
{
    [self.navigationController pushViewController:self.profileDataGraphVC animated:YES];
}

#pragma KeyboardBarDelegate

// Handle keyboard bar event by creating an alert that contains
// the text from the keyboard bar. In reality, this would do something more useful
- (void)keyboardBar:(KeyboardBar *)keyboardBar sendText:(NSString *)text {
    //UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Keyboard Text" message:text delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    //[alert show];
    self.inputAccessoryView.hidden = YES;
    
    id textFieldSuper = self.txtActiveTextField;
    while (![textFieldSuper isKindOfClass:[UITableViewCell class]]) {
        textFieldSuper = [textFieldSuper superview];
    }
    // Get that cell's index path
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(UITableViewCell *)textFieldSuper];
    Field *selectedField = [self.cmdFields.fields objectAtIndex:indexPath.row];
    
    UITextField *textfield = (UITextField*)[self.inputAccessoryView viewWithTag:200];
    
    selectedField.value = [textfield.text longLongValue];

    
    if([selectedField.fieldname isEqualToString:@"No of Screens:"])
    {
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (int i=1; i < [self.cmdFields.fields count]; i++)
        {
            [indexSet addIndex:i];
        }
        
        [self.cmdFields.fields removeObjectsAtIndexes:indexSet];
        
        for (int i=0; i<selectedField.value; i++)
        {
            Field *field = [[Field alloc] init];
            
            field.uiControlType = 0;
            field.textfieldKeyboardType = 50;
            field.value = i+1;
            
            switch (field.value) {
                case 1:
                    field.fieldname = @"First Screen:";
                    break;
                case 2:
                    field.fieldname = @"Second Screen:";
                    break;
                case 3:
                    field.fieldname = @"Third Screen:";
                    break;
                case 4:
                    field.fieldname = @"Fourth Screen:";
                    break;
                case 5:
                    field.fieldname = @"Fifth Screen:";
                    break;
                case 6:
                    field.fieldname = @"Sixth Screen:";
                    break;
                case 7:
                    field.fieldname = @"Seventh Screen:";
                    break;
                case 8:
                    field.fieldname = @"Eight Screen:";
                    break;
                case 9:
                    field.fieldname = @"Ninth Screen:";
                    break;
                case 10:
                    field.fieldname = @"Tenth Screen:";
                    break;
                case 11:
                    field.fieldname = @"Eleventh Screen:";
                    break;
                case 12:
                    field.fieldname = @"Twelfth Screen:";
                    break;
                case 13:
                    field.fieldname = @"Thirteenth Screen:";
                    break;
                case 14:
                    field.fieldname = @"Fourteenth Screen:";
                    break;
                case 15:
                    field.fieldname = @"Fifteenth Screen:";
                    break;
                default:
                    break;
            }
            
            [self.cmdFields.fields addObject:field];
        }
    }
    
    
    [self.myTableView reloadData];
    
    [self becomeFirstResponder];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view becomeFirstResponder];
    
    // Pass the current controller as the keyboardBarDelegate
    self.keyboardBarDelegate = self;
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    self.view.inputAccessoryView.hidden = YES;
    //UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTouchView)];
    
    //[self.view addGestureRecognizer:recognizer];
    
    self.updateTableVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"updateStepTableVC"];
    
    self.profileDataGraphVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"profileDataGraphVC"];

    self.labelConnectionStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 20)];
    self.labelConnectionStatus.text = @"Connected";
    self.labelConnectionStatus.textAlignment = NSTextAlignmentCenter;
    self.labelConnectionStatus.backgroundColor = [UIColor greenColor];
    
    self.btnReadWrite.layer.borderWidth = 2.0f;
    self.btnReadWrite.layer.borderColor = [UIColor grayColor].CGColor;
    self.btnReadWrite.layer.cornerRadius = 5.0f;

    [self.view addSubview:self.labelConnectionStatus];
    
    self.customToolbar=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height+50, self.view.frame.size.width, 50)];
    
    self.toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    self.toolbar.barTintColor = [UIColor grayColor];
    
    self.labelToolBarItemCaption = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 260, 30)];
    self.labelToolBarItemCaption.textColor = [UIColor whiteColor];
    
    self.toolBarTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 40, 200, 30)];
    self.toolBarTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.toolBarTextField.tag = 0;
    self.toolBarTextField.delegate = self;
    
    self.textViewRawLog = [[NSString alloc] init];
    
    self.dateTimePickerView = [[UIDatePicker alloc] init];
    self.dateTimePickerView.date = [NSDate date];
    
    NSLog(@"view width %f",self.view.frame.size.width);
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeConnectionState:)
                                                 name:@"ConnectionState"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setTextViewData:)
                                                 name:@"setTextViewData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveCommandResponse:)
                                                 name:@"didReceiveCommandResponse"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSelectedField:)
                                                 name:@"updateSelectedField"
                                               object:nil];
    
}

-(void)updateDeviceCmdFieldsValuesWithCurrentDateTime
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components: NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate: [NSDate date]];
    dateComponents.timeZone = [NSTimeZone timeZoneWithName: @"UTC"];
    
    for(Field *field in self.cmdFields.fields)
    {
        if([field.fieldname isEqualToString:@"Month:"] || [field.fieldname isEqualToString:@"DST Start Month:"] || [field.fieldname isEqualToString:@"DST End Month:"] || [field.fieldname isEqualToString:@"Schedule Month:"])
        {
            field.value = (int) dateComponents.month;
        }
        else if([field.fieldname isEqualToString:@"Day:"] || [field.fieldname isEqualToString:@"DST Start Day:"] || [field.fieldname isEqualToString:@"DST End Day:"] || [field.fieldname isEqualToString:@"Schedule Day:"])
        {
            field.value =[field.fieldname isEqualToString:@"DST End Day:"]? (int)dateComponents.day +1:(int)dateComponents.day;
        }
        else if([field.fieldname isEqualToString:@"Year:"] || [field.fieldname isEqualToString:@"Schedule Year:"])
        {
            field.value = (int)dateComponents.year - 2000;
        }
        else if([field.fieldname isEqualToString:@"Hour:"] || [field.fieldname isEqualToString:@"DST Start Hour:"] || [field.fieldname isEqualToString:@"DST End Hour:"])
        {
            field.value = (int)dateComponents.hour;
        }
        else if([field.fieldname isEqualToString:@"Minute:"])
        {
            field.value = (int)dateComponents.minute;
        }
        else if([field.fieldname isEqualToString:@"Second:"])
        {
            field.value = (int)dateComponents.second;
        }
        else if([field.fieldname isEqualToString:@"AM/PM:"])
        {
            field.value = dateComponents.hour >=12?1:0;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.segmentedReadWriteCommand.selectedSegmentIndex = 0;
    self.btnReadWrite.frame = CGRectMake(0, self.view.frame.size.height-51, self.view.frame.size.width, 50);
    self.segmentedReadWriteCommand.frame = CGRectMake(0, self.labelConnectionStatus.frame.origin.y+self.labelConnectionStatus.frame.size.height, self.view.frame.size.width, 45);
    self.textViewRawData.frame = CGRectMake(0, self.btnReadWrite.frame.origin.y-61, self.view.frame.size.width, 60);
    self.labelRawDataCaption = [[UILabel alloc] initWithFrame:CGRectMake(0, self.textViewRawData.frame.origin.y-20, self.view.frame.size.width, 20)];
    self.labelRawDataCaption.text = @"Raw Data:";
    self.labelRawDataCaption.backgroundColor = [UIColor blueColor];
    self.labelRawDataCaption.textColor = [UIColor whiteColor];
    self.labelRawDataCaption.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
    self.segmentedReadWriteCommand.hidden = !self.cmdFields.readWrite;
    int myTableViewHeight = [self getMyTableViewHeight];
    int myTableViewYCoor = self.segmentedReadWriteCommand.hidden?self.segmentedReadWriteCommand.frame.origin.y:self.segmentedReadWriteCommand.frame.origin.y+self.segmentedReadWriteCommand.frame.size.height;
    self.myTableView.frame = CGRectMake(0, myTableViewYCoor, self.view.frame.size.width, myTableViewHeight-15);
    
    if(self.cmdFields.readWrite)
    {
        if(self.segmentedReadWriteCommand.selectedSegmentIndex == 0)
        {
            [self.btnReadWrite setTitle:@"READ" forState:UIControlStateNormal];
        }
        else
        {
            [self.btnReadWrite setTitle:@"WRITE" forState:UIControlStateNormal];
        }
    }
    else
    {
        if([self.cmdFields.featureName isEqualToString:@"Start Profile Recording"])
        {
            [self.btnReadWrite setTitle:@"START RECORDING" forState:UIControlStateNormal];
        }
        else if([self.cmdFields.featureName isEqualToString:@"Erase Message Command"])
        {
            segmentedReadWriteCommand.selectedSegmentIndex = 1;
            
            [segmentedReadWriteCommand sendActionsForControlEvents:UIControlEventValueChanged];
            [self.btnReadWrite setTitle:@"ERASE" forState:UIControlStateNormal];
        }
        else if([self.cmdFields.featureName isEqualToString:@"Set Message Command"])
        {
            segmentedReadWriteCommand.selectedSegmentIndex = 1;
            
            [segmentedReadWriteCommand sendActionsForControlEvents:UIControlEventValueChanged];
            [self.btnReadWrite setTitle:@"SET MESSAGE" forState:UIControlStateNormal];
        }
        else if([self.cmdFields.featureName isEqualToString:@"Display On Screen"])
        {
            segmentedReadWriteCommand.selectedSegmentIndex = 1;
            
            [segmentedReadWriteCommand sendActionsForControlEvents:UIControlEventValueChanged];
            [self.btnReadWrite setTitle:@"SHOW ON SCREEN" forState:UIControlStateNormal];
        }

        else
        {
            [self.btnReadWrite setTitle:@"READ" forState:UIControlStateNormal];
        }
    }
    
    if([self.cmdFields.featureName isEqualToString:@"Read Steps Table Header"])
    {
        self.segmentedReadWriteCommand.enabled = NO;
        self.myTableView.hidden = YES;

    }
    if([self.cmdFields.featureName isEqualToString:@"DFU Command"] || [self.cmdFields.featureName isEqualToString:@"EEPROM Command"] ||
       [self.cmdFields.featureName isEqualToString:@"Show Written Message"])
    {
        segmentedReadWriteCommand.selectedSegmentIndex = 1;
        
        [segmentedReadWriteCommand sendActionsForControlEvents:UIControlEventValueChanged];
    }
    else if([self.cmdFields.featureName isEqualToString:@"Read Profile Data"])
    {
        [self updateDeviceCmdFieldsValuesWithCurrentDateTime];
    }
    else
    {
        self.segmentedReadWriteCommand.enabled = YES;
        self.myTableView.hidden = NO;
    }
    
    self.isReceivingResponse = NO;
    [self.myTableView reloadData];
    [self.view addSubview:self.labelRawDataCaption];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didChangeConnectionState:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    
    self.labelConnectionStatus.text = [[userInfo objectForKey:@"status"] boolValue]?@"Connected":@"Disconnected";
    self.labelConnectionStatus.textColor = [[userInfo objectForKey:@"status"] boolValue]?[UIColor blackColor]:[UIColor whiteColor];
    self.labelConnectionStatus.backgroundColor =[[userInfo objectForKey:@"status"] boolValue]?[UIColor greenColor]:[UIColor redColor];
    
    if(![[userInfo objectForKey:@"status"] boolValue])
    {
        self.btnReadWrite.enabled = NO;
        [self.navigationItem setHidesBackButton:NO];
    }
    else
    {
        self.btnReadWrite.enabled = YES;
    }
}

-(int)getMyTableViewHeight
{
    int height = 480; //default iphone 4s
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if([[UIScreen mainScreen] bounds].size.height == 667)
        {
            height = 667;
        }
        else if([[UIScreen mainScreen] bounds].size.height == 736)
        {
            height = 736;
        }
        else if([[UIScreen mainScreen] bounds].size.height == 568)
        {
            height = 568;
        }
    }
    
    if(self.segmentedReadWriteCommand.hidden)
    {
        height = height - ( self.btnReadWrite.frame.size.height + self.labelConnectionStatus.frame.size.height + self.textViewRawData.frame.size.height + self.labelRawDataCaption.frame.size.height + 64);
    }
    else
    {
        height = height - ( self.btnReadWrite.frame.size.height+self.segmentedReadWriteCommand.frame.size.height+ self.labelConnectionStatus.frame.size.height + self.textViewRawData.frame.size.height + self.labelRawDataCaption.frame.size.height + 64);
    }
    return height;
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    if([self.cmdFields.featureName isEqualToString:@"Steps Table Header"])
    {
        if(section > 1)
        {
            UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 25)];
            labelDate.backgroundColor = [UIColor lightGrayColor];
            labelDate.textColor = [UIColor whiteColor];
            labelDate.layer.borderWidth = 1.0f;
            labelDate.layer.borderColor = [UIColor darkGrayColor].CGColor;
            labelDate.textAlignment = NSTextAlignmentCenter;
            labelDate.font = [UIFont fontWithName:@"Arial-BoldMT" size:15];
            
            UILabel *totalHours = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width* 0.1, 25)];
            totalHours.backgroundColor = [UIColor grayColor];
            totalHours.textColor = [UIColor whiteColor];
            totalHours.layer.borderWidth = 1.0f;
            totalHours.layer.borderColor = [UIColor darkGrayColor].CGColor;
            totalHours.textAlignment = NSTextAlignmentLeft;
            totalHours.lineBreakMode = NSLineBreakByWordWrapping;
            totalHours.font = [UIFont fontWithName:@"Arial-BoldMT" size:8];
            totalHours.text = @"Hour No.";
            
            UILabel *flags = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width* 0.1, 20, self.view.frame.size.width* 0.8, 25)];
            flags.backgroundColor = [UIColor whiteColor];
            flags.textColor = [UIColor grayColor];
            flags.layer.borderWidth = 1.0f;
            flags.layer.borderColor = [UIColor darkGrayColor].CGColor;
            flags.textAlignment = NSTextAlignmentCenter;
            flags.lineBreakMode = NSLineBreakByWordWrapping;
            flags.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
            flags.text = @"Hourly Flags";
            
            UILabel *sigflags = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width* 0.9, 20, self.view.frame.size.width* 0.1, 25)];
            sigflags.backgroundColor = [UIColor grayColor];
            sigflags.textColor = [UIColor whiteColor];
            sigflags.layer.borderWidth = 1.0f;
            sigflags.layer.borderColor = [UIColor darkGrayColor].CGColor;
            sigflags.textAlignment = NSTextAlignmentCenter;
            sigflags.lineBreakMode = NSLineBreakByWordWrapping;
            sigflags.font = [UIFont fontWithName:@"Arial" size:7];
            sigflags.text = @"Sign flag";
            
            Field *field = [self.cmdFields.fields objectAtIndex:section];
            
            StepTable *selectedTable = (StepTable*)field.objectValue;
            if(selectedTable.tableMonth  && selectedTable.tableMonth != 63)
            {
                NSString *monthDesc = [Utilities getMonthDescription:selectedTable.tableMonth];
                labelDate.text = [NSString stringWithFormat:@"%@ %d, 20%d",monthDesc,selectedTable.tableDay,selectedTable.tableYear];
            }
            else
            {
                labelDate.text = @"Unused slot";
            }
            
            [headerView addSubview:labelDate];
            [headerView addSubview:totalHours];
            [headerView addSubview:flags];
            [headerView addSubview:sigflags];
        }
    }
    else
    {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        labelTitle.textAlignment = NSTextAlignmentCenter;
        labelTitle.text = self.cmdFields.featureName;
        labelTitle.font = [UIFont fontWithName:@"Arial-BoldMT" size:20.0];
        
        UILabel *labelSubHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 30)];
        labelSubHeader.textAlignment = NSTextAlignmentCenter;
        labelSubHeader.font = [UIFont fontWithName:@"Arial-BoldMT" size:17.0];
        labelSubHeader.textColor = [UIColor blueColor];
        
        if(([self.cmdFields.featureName isEqualToString:@"Steps by Hour Range"] && [self.cmdFields.fields count] > 7) ||
           ([self.cmdFields.featureName isEqualToString:@"Current Hour Steps"] && [self.cmdFields.fields count] > 2) )
        {
            labelSubHeader.text = [NSString stringWithFormat:@"Total Steps: %d",[self getTotalSteps]];
            [headerView addSubview:labelSubHeader];
        }
        else if([self.cmdFields.featureName isEqualToString:@"Profile Table Header"])
        {
            if(self.isReceivingResponse)
            {
                labelSubHeader.text = [self.cmdFields.fields count]>0?@"Date/Time of Profile Recorded":@"No Record Found";
            }
            else
            {
                labelSubHeader.text = @"Date/Time of Profile Data Recorded";
            }
            [headerView addSubview:labelSubHeader];
        }
        else if([self.cmdFields.featureName isEqualToString:@"Read Profile Data"])
        {
            if(self.isReceivingResponse)
            {
                int count = 0;
                if([self.cmdFields.fields count] >=5)
                {
                    Field *field = (Field*)[self.cmdFields.fields lastObject];
                    NSDictionary *dict = (NSDictionary*)field.objectValue;
                    count = (int) [[dict objectForKey:@"xaxis"] count];
                }
                labelSubHeader.text = count?[NSString stringWithFormat:@"Total data per Axis: %d",count]:@"No Record Found";
                labelSubHeader.textColor = !count?[UIColor redColor]:[UIColor blueColor];
            }
            else
            {
                labelSubHeader.text = @"";
            }
            [headerView addSubview:labelSubHeader];
        }
        

        [headerView addSubview:labelTitle];
    }
    
    return  headerView;
}

-(int)getTotalSteps
{
    int tSteps = 0;
    int index = 0;
    if([self.cmdFields.featureName isEqualToString:@"Steps by Hour Range"] )
    {
        index =7;
    }
    else if  ([self.cmdFields.featureName isEqualToString:@"Current Hour Steps"] )
    {
        index =2;
    }
    for (int i=index; i<[self.cmdFields.fields count]; i++)
    {
        Field *currentField = [self.cmdFields.fields objectAtIndex:i];
        tSteps += ((StepDataHourly*)currentField.objectValue).totalHourlySteps;
    }
    
    return tSteps;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    int numOfSections = 1;
    
    if([self.cmdFields.featureName isEqualToString:@"Steps Table Header"])
    {
        numOfSections = (int) [self.cmdFields.fields count];
    }
    
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int numOfRows = (int)[self.cmdFields.fields count];
    
    if([self.cmdFields.featureName isEqualToString:@"Steps Table Header"])
    {
        numOfRows = 1;
    }

    /*
    else if([self.cmdFields.featureName isEqualToString:@"SCREEN Settings"])
    {
        numOfRows = (int) [self.cmdFields.fields count] + (int) field.value;
    }*/
    
    return  numOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    int heightHeader = 60.0;
    if([self.cmdFields.featureName isEqualToString:@"Steps Table Header"])
    {
        if(section < 2)
        {
            heightHeader = 5;
        }
        else
        {
            heightHeader = 45.0;
        }
    }
    return heightHeader;
}



- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"Cell"];
    BOOL cellIsPreviouslyNil = NO;
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cellIsPreviouslyNil = YES;
    }
    Field *field = [self.cmdFields.fields objectAtIndex:indexPath.row];
    
    //Remove all current subviews when reloading data
    if ([cell.contentView subviews])
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }

    if([self.cmdFields.featureName isEqualToString:@"Steps Table Header"])
    {
        Field *field = [self.cmdFields.fields objectAtIndex:indexPath.section];
        
        if(field.uiControlType == TextField)
        {
            UILabel *fieldCaption = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 240, 40)];
            fieldCaption.text = field.fieldname;
            fieldCaption.tag = indexPath.row + 1000;
            [cell.contentView addSubview:fieldCaption];
            
            UITextField *textField = [[UITextField alloc] initWithFrame: CGRectMake(240, 5, self.view.frame.size.width - 245, 40)];
            textField.keyboardType = [self getTextFieldKeyBoardType:field.textfieldKeyboardType];
            textField.textAlignment = NSTextAlignmentCenter;
            textField.layer.borderWidth = 2.0f;
            textField.layer.borderColor = [UIColor grayColor].CGColor;
            textField.layer.cornerRadius = 1.0f;
            textField.text = field.textfieldKeyboardType==UIKeyboardTypeNumberPad?[NSString stringWithFormat:@"%d",(int)field.value]:[self getStringValueOfCustomControl:field];
            textField.tag = indexPath.row + 3000;
            textField.delegate = self;
            [cell.contentView addSubview:textField];
        }
        else
        {
            UILabel *hourNo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width* 0.1, 25)];
            hourNo.backgroundColor = [UIColor grayColor];
            hourNo.textColor = [UIColor whiteColor];
            hourNo.layer.borderWidth = 1.0f;
            hourNo.layer.borderColor = [UIColor darkGrayColor].CGColor;
            hourNo.textAlignment = NSTextAlignmentCenter;
            hourNo.lineBreakMode = NSLineBreakByWordWrapping;
            hourNo.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
            
            UILabel *flags = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width* 0.1, 0, self.view.frame.size.width* 0.8, 25)];
            flags.backgroundColor = [UIColor whiteColor];
            flags.textColor = [UIColor grayColor];
            flags.layer.borderWidth = 1.0f;
            flags.layer.borderColor = [UIColor darkGrayColor].CGColor;
            flags.textAlignment = NSTextAlignmentLeft;
            flags.lineBreakMode = NSLineBreakByWordWrapping;
            flags.font = [UIFont fontWithName:@"Arial-BoldMT" size:12];
            
            UILabel *signFlag = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width* 0.9), 0, self.view.frame.size.width* 0.1, 25)];
            signFlag.backgroundColor = [UIColor grayColor];
            signFlag.textColor = [UIColor whiteColor];
            signFlag.layer.borderWidth = 1.0f;
            signFlag.layer.borderColor = [UIColor darkGrayColor].CGColor;
            signFlag.textAlignment = NSTextAlignmentCenter;
            signFlag.lineBreakMode = NSLineBreakByWordWrapping;
            signFlag.font = [UIFont fontWithName:@"Arial-BoldMT" size:13];
            
            UILabel *labelInstruct = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, self.view.frame.size.width, 25)];
            labelInstruct.backgroundColor = [UIColor grayColor];
            labelInstruct.textColor = [UIColor yellowColor];
            labelInstruct.layer.borderWidth = 1.0f;
            labelInstruct.layer.borderColor = [UIColor darkGrayColor].CGColor;
            labelInstruct.textAlignment = NSTextAlignmentCenter;
            labelInstruct.lineBreakMode = NSLineBreakByWordWrapping;
            labelInstruct.font = [UIFont fontWithName:@"Arial-BoldMT" size:15];
            

            StepTable *selectedTable =  (StepTable*)field.objectValue;
            
            if(selectedTable.tableMonth  && selectedTable.tableMonth != 63)
            {
                labelInstruct.text = @"Tap here to update hourly flags";
                hourNo.text = [NSString stringWithFormat:@"%d",selectedTable.tableCurrentHour];
                NSString *temp = [[NSString alloc] init];
                for (NSString *flag in selectedTable.tableSentHourFlag)
                {
                    temp = [temp stringByAppendingFormat:@" %@",flag];
                }
                flags.text = temp;
                signFlag.text = [NSString stringWithFormat:@"%d",selectedTable.tableSignatureFlag & 0x0F];
            }

            [cell.contentView addSubview:hourNo];
            [cell.contentView addSubview:flags];
            [cell.contentView addSubview:signFlag];
            [cell.contentView addSubview:labelInstruct];
        }
    }
    else if([self.cmdFields.featureName isEqualToString:@"Steps by Hour Range"] || [self.cmdFields.featureName isEqualToString:@"Current Hour Steps"])
    {
        if(field.uiControlType == TextField)
        {
            UILabel *fieldCaption = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 240, 40)];
            fieldCaption.text = field.fieldname;
            fieldCaption.tag = indexPath.row + 1000;
            [cell.contentView addSubview:fieldCaption];
            
            UITextField *textField = [[UITextField alloc] initWithFrame: CGRectMake(240, 5, self.view.frame.size.width - 245, 40)];
            textField.keyboardType = [self getTextFieldKeyBoardType:field.textfieldKeyboardType];
            textField.textAlignment = NSTextAlignmentCenter;
            textField.layer.borderWidth = 2.0f;
            textField.layer.borderColor = [UIColor grayColor].CGColor;
            textField.layer.cornerRadius = 1.0f;
            textField.text = field.textfieldKeyboardType==UIKeyboardTypeNumberPad?[NSString stringWithFormat:@"%d",(int)field.value]:[self getStringValueOfCustomControl:field];
            textField.tag = indexPath.row + 3000;
            textField.delegate = self;
            [cell.contentView addSubview:textField];
        }
        else
        {
            StepDataHourly *hourly = (StepDataHourly*)field.objectValue;
            
            UILabel *fieldCaption = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.view.frame.size.width, 40)];
            fieldCaption.text = [NSString stringWithFormat:@"Hour#: %d   Total Steps: %d   Total kCal: %d",[hourly.hourNumber intValue]+1, hourly.totalHourlySteps,hourly.totalHourlyCal];
            fieldCaption.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
            fieldCaption.tag = indexPath.row + 1000;
            [cell.contentView addSubview:fieldCaption];
        }
    }
    else if([self.cmdFields.featureName isEqualToString:@"Profile Table Header"])
    {
        Field *field = [self.cmdFields.fields objectAtIndex:indexPath.row];
        
        ProfileTable *profileTableData = (ProfileTable*)field.objectValue;
        UILabel *labelProfileRecord = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 240, 40)];
        labelProfileRecord.text = field.fieldname;
        labelProfileRecord.tag = indexPath.row + 1000;
        
        if(profileTableData.profileYear && profileTableData.profileYear != 63)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [cell.contentView addSubview:labelProfileRecord];
    }
    else if([self.cmdFields.featureName isEqualToString:@"Read Profile Data"])
    {
        if(field.uiControlType == TextField)
        {
            UILabel *fieldCaption = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 240, 40)];
            fieldCaption.text = field.fieldname;
            fieldCaption.tag = indexPath.row + 1000;
            [cell.contentView addSubview:fieldCaption];
            
            UITextField *textField = [[UITextField alloc] initWithFrame: CGRectMake(240, 5, self.view.frame.size.width - 245, 40)];
            textField.keyboardType = [self getTextFieldKeyBoardType:field.textfieldKeyboardType];
            textField.textAlignment = NSTextAlignmentCenter;
            textField.layer.borderWidth = 2.0f;
            textField.layer.borderColor = [UIColor grayColor].CGColor;
            textField.layer.cornerRadius = 1.0f;
            textField.text = field.textfieldKeyboardType==UIKeyboardTypeNumberPad?[NSString stringWithFormat:@"%d",(int)field.value]:[self getStringValueOfCustomControl:field];
            textField.tag = indexPath.row + 3000;
            textField.delegate = self;
            [cell.contentView addSubview:textField];
        }
        else if(field.uiControlType == DatePicker)
        {
            UILabel *fieldCaption = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 240, 40)];
            fieldCaption.text = field.fieldname;
            fieldCaption.tag = indexPath.row + 1000;
            [cell.contentView addSubview:fieldCaption];
            UITextField *textField = [[UITextField alloc] initWithFrame: CGRectMake(170, 5, self.view.frame.size.width - 170, 40)];
            textField.keyboardType = [self getTextFieldKeyBoardType:field.textfieldKeyboardType];
            textField.textAlignment = NSTextAlignmentCenter;
            textField.layer.borderWidth = 2.0f;
            textField.layer.borderColor = [UIColor grayColor].CGColor;
            textField.layer.cornerRadius = 1.0f;
            textField.text = [self getDatePickerFieldValue:self.dateTimePickerView.date];
            textField.tag = indexPath.row + 4000;
            textField.delegate = self;
            field.objectValue = self.dateTimePickerView.date;
            [cell.contentView addSubview:textField];
        }
        else if(field.uiControlType == Button)
        {
            UILabel *fieldCaption = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 40)];
            fieldCaption.text = @"Read Profile successful!";
            fieldCaption.textColor = [UIColor blueColor];
            fieldCaption.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
            fieldCaption.tag = indexPath.row + 1000;
            
            UIButton *viewProfileGraphBtn =[UIButton buttonWithType:UIButtonTypeRoundedRect];
            viewProfileGraphBtn.frame = CGRectMake(200, 5, self.view.frame.size.width-205, 40);
            viewProfileGraphBtn.layer.borderWidth = 2.5f;
            viewProfileGraphBtn.layer.borderColor = [UIColor greenColor].CGColor;
            viewProfileGraphBtn.layer.cornerRadius = 8.0f;
            [viewProfileGraphBtn setTitle:@"View Results" forState:UIControlStateNormal];
            [viewProfileGraphBtn.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:18]];
            [viewProfileGraphBtn addTarget:self action:@selector(showResults) forControlEvents:UIControlEventTouchUpInside];
            
            self.profileDataGraphVC.dictionary = [NSDictionary dictionaryWithDictionary:(NSDictionary*) field.objectValue];
            [cell.contentView addSubview:viewProfileGraphBtn];
            [cell.contentView addSubview:fieldCaption];
        }
    }
    else if([self.cmdFields.featureName isEqualToString:@"Charging History"])
    {
        Field *field = [self.cmdFields.fields objectAtIndex:indexPath.row];
        
        NSDictionary *historyDict = (NSDictionary*)field.objectValue;
        UILabel *chargingHistory = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.view.frame.size.width, 50)];
        [chargingHistory setFont:[UIFont fontWithName:@"Arial-BoldMT" size:13]];
        int year = [[historyDict objectForKey:@"year"] intValue];
        int month = [[historyDict objectForKey:@"month"] intValue];
        int day = [[historyDict objectForKey:@"day"] intValue];
        int hour = [[historyDict objectForKey:@"hour"] intValue];
        int min = [[historyDict objectForKey:@"min"] intValue];
        int batLvlPlug = [[historyDict objectForKey:@"batLevelPlug"] intValue];
        int duration = [[historyDict objectForKey:@"duration"] intValue];
        int batLvlUnPlug = [[historyDict objectForKey:@"batLevelUnPlug"] intValue];
        chargingHistory.text = [NSString stringWithFormat:@"%@ %d, 20%.2d %.2d:%.2d Plug:%d%% Dur:%d UnPlug:%d%%",[Utilities getMonthDescription:month],day,year,hour,min,batLvlPlug,duration,batLvlUnPlug];
        chargingHistory.tag = indexPath.row + 1000;
        


        
        [cell.contentView addSubview:chargingHistory];
    }
    else
    {
        
        UILabel *fieldCaption = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 240, 40)];
        fieldCaption.text = field.fieldname;
        fieldCaption.tag = indexPath.row + 1000;
        [cell.contentView addSubview:fieldCaption];
        
        if(self.segmentedReadWriteCommand.selectedSegmentIndex == 0)
        {
            UILabel *fieldValue = [[UILabel alloc] initWithFrame:CGRectMake(240, 5, self.view.frame.size.width - 245, 40)];
            fieldValue.textAlignment = NSTextAlignmentCenter;
            fieldValue.backgroundColor = field.uiControlType ==TableView?[UIColor whiteColor]:[UIColor yellowColor];
            fieldValue.tag = indexPath.row + 2000;

            if(self.isReceivingResponse)
            {
                if(field.uiControlType == TextField || field.uiControlType == Switch)
                {
                    fieldValue.text = field.textfieldKeyboardType==UIKeyboardTypeNumberPad?[NSString stringWithFormat:@"%d",(int)field.value]:[self getStringValueOfCustomControl:field];
                }
                else
                {
                    if([field.fieldname isEqualToString:@"Serial Number:"])
                    {
                        fieldValue.text = [NSString stringWithFormat:@"%lld",field.value];
                    }
                    else if([field.fieldname isEqualToString:@"Firmware Version:"])
                    {
                        fieldValue.text = [NSString stringWithFormat:@"%.1f",field.floatValue];
                    }
                    else if([field.fieldname isEqualToString:@"Hardware Version:"])
                    {
                        fieldValue.text = [NSString stringWithFormat:@"%.1f",field.floatValue];
                    }
                    else if([field.fieldname isEqualToString:@"Boot Loader Version:"])
                    {
                        fieldValue.text = [NSString stringWithFormat:@"%.1f",field.floatValue];
                    }
                    else if([field.fieldname isEqualToString:@"Broadcast Type:"])
                    {
                        fieldValue.text = [NSString stringWithFormat:@"%c",(char)field.value];
                    }
                    else if([field.fieldname isEqualToString:@"No of Screens:"] )
                    {
                        fieldValue.text = [NSString stringWithFormat:@"%d",(int) [self.cmdFields.fields count]];
                    }
                    else
                    {
                        fieldValue.text = [NSString stringWithFormat:@"%d",(int)field.value];
                    }
                }
            }
            
            if([field.fieldname isEqualToString:@"Serial Number:"] || [field.fieldname isEqualToString:@"Beep Type:"] || [field.fieldname isEqualToString:@"Device Mode:"])
            {
                fieldValue.frame = CGRectMake(130, 5, self.view.frame.size.width - 130, 40);
            }
            else if([field.fieldname isEqualToString:@"Alarm Duration(ms):"] )
            {
                fieldValue.frame = CGRectMake(195, 5, self.view.frame.size.width - 195, 40);
            }
            else if([field.fieldname isEqualToString:@"Tenacity Steps:"] )
            {
                fieldValue.frame = CGRectMake(220, 5, self.view.frame.size.width - 220, 40);
            }
            else if([field.fieldname isEqualToString:@"First Screen:"]      ||
                    [field.fieldname isEqualToString:@"Second Screen:"]     ||
                    [field.fieldname isEqualToString:@"Third Screen:"]      ||
                    [field.fieldname isEqualToString:@"Fourth Screen:"]     ||
                    [field.fieldname isEqualToString:@"Fifth Screen:"]      ||
                    [field.fieldname isEqualToString:@"Sixth Screen:"]      ||
                    [field.fieldname isEqualToString:@"Seventh Screen:"]    ||
                    [field.fieldname isEqualToString:@"Eight Screen:"]      ||
                    [field.fieldname isEqualToString:@"Ninth Screen:"]      ||
                    [field.fieldname isEqualToString:@"Tenth Screen:"]      ||
                    [field.fieldname isEqualToString:@"Eleventh Screen:"]   ||
                    [field.fieldname isEqualToString:@"Twelfth Screen:"]    ||
                    [field.fieldname isEqualToString:@"Thirteenth Screen:"] ||
                    [field.fieldname isEqualToString:@"Fourteenth Screen:"] ||
                    [field.fieldname isEqualToString:@"Fifteenth Screen:"]
                    )
            {

                fieldValue.frame = CGRectMake(180, 5, self.view.frame.size.width - 180, 40);
            }
            if([field.fieldname isEqualToString:@"Schedule ID:"] )
            {
                UITextField *textField = [[UITextField alloc] initWithFrame: CGRectMake(240, 5, self.view.frame.size.width - 245, 40)];
                textField.keyboardType = [self getTextFieldKeyBoardType:field.textfieldKeyboardType];
                textField.textAlignment = NSTextAlignmentCenter;
                textField.layer.borderWidth = 2.0f;
                textField.layer.borderColor = [UIColor grayColor].CGColor;
                textField.layer.cornerRadius = 1.0f;
                textField.text = [NSString stringWithFormat:@"%d",(int)field.value];
                textField.tag = indexPath.row + 3000;
                textField.delegate = self;
                [cell.contentView addSubview:textField];
            }
            else
            {
                [cell.contentView addSubview: fieldValue];
            }
            
        }
        else
        {
            if(field.uiControlType == TextField)
            {
                UITextField *textField = [[UITextField alloc] initWithFrame: CGRectMake(240, 5, self.view.frame.size.width - 245, 40)];
                textField.keyboardType = [self getTextFieldKeyBoardType:field.textfieldKeyboardType];
                textField.textAlignment = NSTextAlignmentCenter;
                textField.layer.borderWidth = 2.0f;
                textField.layer.borderColor = [UIColor grayColor].CGColor;
                textField.layer.cornerRadius = 1.0f;
                if(field.textfieldKeyboardType == 1)
                {
                    textField.text = field.stringValue;
                }
                else
                {
                    textField.text = field.textfieldKeyboardType==UIKeyboardTypeNumberPad?[NSString stringWithFormat:@"%d",(int)field.value]:[self getStringValueOfCustomControl:field];
                }
                textField.tag = indexPath.row + 3000;
                textField.delegate = self;
                
                if([field.fieldname isEqualToString:@"Device Mode:"] || [field.fieldname isEqualToString:@"Beep Type:"])
                {
                    textField.frame = CGRectMake(175, 5, self.view.frame.size.width - 175, 40);
                }
                else if([field.fieldname isEqualToString:@"Alarm Duration(ms):"])
                {
                    textField.frame = CGRectMake(195, 5, self.view.frame.size.width - 195, 40);
                }
                else if([field.fieldname isEqualToString:@"Tenacity Steps:"] )
                {
                    textField.frame = CGRectMake(220, 5, self.view.frame.size.width - 220, 40);
                }
                else if([field.fieldname isEqualToString:@"Message:"] )
                {
                    textField.frame = CGRectMake(150, 5, self.view.frame.size.width - 150, 40);
                }
                else if([field.fieldname isEqualToString:@"Intensity Goal Achieve:"] ||
                        [field.fieldname isEqualToString:@"Frequency Goal Achieve:"] ||
                        [field.fieldname isEqualToString:@"Tenacity Goal Achieve:"])
                {
                    textField.enabled = NO;
                    [textField setBackgroundColor:[UIColor grayColor]];
                }
                else if([field.fieldname isEqualToString:@"First Screen:"]      ||
                        [field.fieldname isEqualToString:@"Second Screen:"]     ||
                        [field.fieldname isEqualToString:@"Third Screen:"]      ||
                        [field.fieldname isEqualToString:@"Fourth Screen:"]     ||
                        [field.fieldname isEqualToString:@"Fifth Screen:"]      ||
                        [field.fieldname isEqualToString:@"Sixth Screen:"]      ||
                        [field.fieldname isEqualToString:@"Seventh Screen:"]    ||
                        [field.fieldname isEqualToString:@"Eight Screen:"]      ||
                        [field.fieldname isEqualToString:@"Ninth Screen:"]      ||
                        [field.fieldname isEqualToString:@"Tenth Screen:"]      ||
                        [field.fieldname isEqualToString:@"Eleventh Screen:"]   ||
                        [field.fieldname isEqualToString:@"Twelfth Screen:"]    ||
                        [field.fieldname isEqualToString:@"Thirteenth Screen:"] ||
                        [field.fieldname isEqualToString:@"Fourteenth Screen:"] ||
                        [field.fieldname isEqualToString:@"Fifteenth Screen:"]
                        )
                {
                    textField.frame = CGRectMake(180, 5, self.view.frame.size.width - 180, 40);
                }
                
                [cell.contentView addSubview:textField];
            }
            else if(field.uiControlType == Switch)
            {
                UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(240, 7, self.view.frame.size.width - 245, 40)];
                [switchControl setOn:field.value];
                [switchControl addTarget:self action:@selector(switchStateChanged:) forControlEvents:UIControlEventValueChanged];
                switchControl.tag = indexPath.row + 4000;
                if([field.fieldname isEqualToString:@"Boot Up Flag:"])
                {
                    switchControl.frame = CGRectMake(175, 5, self.view.frame.size.width - 175, 40);
                }
                [cell.contentView addSubview:switchControl];
            }
            else if(field.uiControlType == Label)
            {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(240, 7, self.view.frame.size.width - 245, 40)];
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = field.uiControlType ==TableView?[UIColor whiteColor]:[UIColor yellowColor];
                label.tag = indexPath.row + 5000;
                if([field.fieldname isEqualToString:@"Serial Number:"])
                {
                    label.frame = CGRectMake(130, 5, self.view.frame.size.width - 130, 40);
                }
                [cell.contentView addSubview:label];
            }
            /*
            else
            {
                if([self.cmdFields.featureName isEqualToString:@"SCREEN settings"])
                {
                    UITextField *textField = [[UITextField alloc] initWithFrame: CGRectMake(240, 5, self.view.frame.size.width - 245, 40)];
                    textField.keyboardType = [self getTextFieldKeyBoardType:field.textfieldKeyboardType];
                    textField.textAlignment = NSTextAlignmentCenter;
                    textField.layer.borderWidth = 2.0f;
                    textField.layer.borderColor = [UIColor grayColor].CGColor;
                    textField.layer.cornerRadius = 1.0f;
                    textField.text = [self getStringValueOfCustomControl:field];
                    textField.tag = indexPath.row + 3000;
                    textField.delegate = self;
                    
                    [cell.contentView addSubview:textField];
                }
            }
             */
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Did tap row#:%d",(int)indexPath.row);
    if([self.cmdFields.featureName isEqualToString:@"Steps Table Header"])
    {
        Field *tableTypeField = [self.cmdFields.fields objectAtIndex:1];
        Field *field = [self.cmdFields.fields objectAtIndex:indexPath.section];
        StepTable *selectedTable =  (StepTable*)field.objectValue;
        
        if(selectedTable.tableMonth  && selectedTable.tableMonth != 63)
        {
            self.updateTableVC.selectedField = field;
            self.updateTableVC.isFraud = tableTypeField.value;
            [self.navigationController pushViewController:self.updateTableVC animated:YES];
        }
    }
    
}

-(void)switchStateChanged:(UISwitch*)thisSwitch{
    // code
    id mySwitch = thisSwitch;
    while (![mySwitch isKindOfClass:[UITableViewCell class]]) {
        mySwitch = [mySwitch superview];
    }
    // Get that cell's index path
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(UITableViewCell *)mySwitch];
    Field *selectedField = [self.cmdFields.fields objectAtIndex:indexPath.row];
    
    if([selectedField.fieldname isEqualToString:@"Auto Sync:"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    else if([selectedField.fieldname isEqualToString:@"Frequency Alarm:"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    else  if([selectedField.fieldname isEqualToString:@"Multiple Intensity:"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    else if([selectedField.fieldname isEqualToString:@"Flash Override:"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    else if([selectedField.fieldname isEqualToString:@"Clear Steps:"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    else if([selectedField.fieldname isEqualToString:@"Clear Profile:"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    else if([selectedField.fieldname isEqualToString:@"Clear Messaging:"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    else if([selectedField.fieldname isEqualToString:@"Clear Tallies n Charge History:"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    else if([selectedField.fieldname isEqualToString:@"Clear FW Update Flag:"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    else if([selectedField.fieldname isEqualToString:@"Set Default:"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    else if([selectedField.fieldname isEqualToString:@"Boot Up Flag:"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    else if([selectedField.fieldname isEqualToString:@"Save User Response:"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    else if([selectedField.fieldname isEqualToString:@"Vibration Setting:"] ||
            [selectedField.fieldname isEqualToString:@"Sensor1:"] ||
            [selectedField.fieldname isEqualToString:@"Sensor2:"] ||
            [selectedField.fieldname isEqualToString:@"Sensor3:"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    else if([selectedField.fieldname isEqualToString:@"Scrolling (OFF/ON):"])
    {
        selectedField.value = [thisSwitch isOn];
    }
    

    [self.cmdFields.fields replaceObjectAtIndex:indexPath.row withObject:selectedField];
}

- (IBAction)segmentedControlSelectedIndexChange:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 0)
    {
        [self.btnReadWrite setTitle:@"READ" forState:UIControlStateNormal];
    }
    else
    {
        if([self.cmdFields.featureName isEqualToString:@"DFU Command"])
        {
            [self.btnReadWrite setTitle:@"SEND DFU COMMAND" forState:UIControlStateNormal];
        }
        if([self.cmdFields.featureName isEqualToString:@"Set Serial Command"])
        {
            [self.btnReadWrite setTitle:@"UPDATE SERIAL" forState:UIControlStateNormal];
        }
        else if([self.cmdFields.featureName isEqualToString:@"Device Settings"])
        {
            [self updateDeviceCmdFieldsValuesWithCurrentDateTime];
            [self.myTableView reloadData];
            [self.btnReadWrite setTitle:@"WRITE" forState:UIControlStateNormal];
        }
        else
        {
            [self.btnReadWrite setTitle:@"WRITE" forState:UIControlStateNormal];
        }
    }
    self.isReceivingResponse = NO;
    [self.myTableView reloadData];
}

//Helper Method

-(UIKeyboardType)getTextFieldKeyBoardType:(int)type
{
    UIKeyboardType keyboardType = UIKeyboardTypeDefault;
    switch (type) {
        case 4:
            keyboardType = UIKeyboardTypeNumberPad;
            break;
        case 0:
            keyboardType = UIKeyboardTypeDefault;
            
        default:
            break;
    }
    return keyboardType;
}

-(int)getIntValueOfCustomTextField:(Field*)field stringValue:(NSString*)str
{
    int value = 0;
    
    if([field.fieldname isEqualToString:@"Unit of Measure:"])
    {
        value = [str isEqualToString:@"English"]?0:1;
    }
    else if([field.fieldname isEqualToString:@"Year of Birth:"])
    {
        value = [str intValue] - 1900;
    }
    else if([field.fieldname isEqualToString:@"Month of Birth:"])
    {
        value = [Utilities getMonthIntValue:str];
    }
    else if([field.fieldname isEqualToString:@"Year:"] || [field.fieldname isEqualToString:@"Schedule Year:"])
    {
        value = [str intValue]-2000;
    }
    else if([field.fieldname isEqualToString:@"Month:"] ||
            [field.fieldname isEqualToString:@"DST Start Month:"] ||
            [field.fieldname isEqualToString:@"DST End Month:"] ||
            [field.fieldname isEqualToString:@"Schedule Month:"])
    {
        value = [Utilities getMonthIntValue:str];
    }
    else if([field.fieldname isEqualToString:@"24Hr/12Hr:"])
    {
        value = [str isEqualToString:@"12Hr"]?0:1;
    }
    else if([field.fieldname isEqualToString:@"AM/PM:"])
    {
        value = [str isEqualToString:@"AM"]?0:1;
    }
    else if([field.fieldname isEqualToString:@"Offset Type:"] || [field.fieldname isEqualToString:@"DST Offset Type:"])
    {
        value = [str isEqualToString:@"ADD"]?0:1;
    }
    else if([field.fieldname isEqualToString:@"DST Applicable:"])
    {
        value = [str isEqualToString:@"YES"]?1:0;
    }
    else if([field.fieldname isEqualToString:@"Day:"] ||
            [field.fieldname isEqualToString:@"DST Start Day:"] ||
            [field.fieldname isEqualToString:@"DST End Day:"] ||
            [field.fieldname isEqualToString:@"Schedule Day:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"Hour:"] ||
            [field.fieldname isEqualToString:@"DST Start Hour:"] ||
            [field.fieldname isEqualToString:@"DST End Hour:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"Minute:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"Second:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"Sensitivity Level:"])
    {
        if([str isEqualToString:@"Normal"])
        {
            value = 0;
        }
        else if([str isEqualToString:@"Medium (N/A)"])
        {
            value = 1;
        }
        else if([str isEqualToString:@"High"])
        {
            value = 2;
        }
    }
    else if([field.fieldname isEqualToString:@"Relative Limit:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"Sensitivity Threshold:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"Start Hour:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"End Hour:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"No. of Packet handshake:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"Firmware version:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"Sampling Frequency:"])
    {
        if([str isEqualToString:@"16Hz"])
        {
            value = 16;
        }
        else if([str isEqualToString:@"32Hz"])
        {
            value = 32;
        }
        else if([str isEqualToString:@"48Hz"])
        {
            value = 48;
        }
        else if([str isEqualToString:@"64Hz"])
        {
            value = 64;
        }
    }
    else if([field.fieldname isEqualToString:@"Device Mode:"])
    {
        if([str isEqualToString:@"Normal"])
        {
            value = 0;
        }
        else if([str isEqualToString:@"Always Broadcast"])
        {
            value = 1;
        }
        else if([str isEqualToString:@"Factory"])
        {
            value = 2;
        }
        else if([str isEqualToString:@"Shipment"])
        {
            value = 3;
        }
        else if([str isEqualToString:@"Accel Trigger"])
        {
            value = 4;
        }
    }
    else if([field.fieldname isEqualToString:@"Alarm Duration(ms):"])
    {
        value = ([str floatValue]/1000) * 16;
    }
    else if([field.fieldname isEqualToString:@"Beep Type:"])
    {
        value = [[str lowercaseString] isEqualToString:@"long beep"]?1:0;
    }
    else if([field.fieldname isEqualToString:@"Start Block:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"End Block:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"No. of packet Handshake:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"Flag:"])
    {
        value = [str intValue];
    }
    else if([field.fieldname isEqualToString:@"First Screen:"]      ||
            [field.fieldname isEqualToString:@"Second Screen:"]     ||
            [field.fieldname isEqualToString:@"Third Screen:"]      ||
            [field.fieldname isEqualToString:@"Fourth Screen:"]     ||
            [field.fieldname isEqualToString:@"Fifth Screen:"]      ||
            [field.fieldname isEqualToString:@"Sixth Screen:"]      ||
            [field.fieldname isEqualToString:@"Seventh Screen:"]    ||
            [field.fieldname isEqualToString:@"Eight Screen:"]      ||
            [field.fieldname isEqualToString:@"Ninth Screen:"]      ||
            [field.fieldname isEqualToString:@"Tenth Screen:"]      ||
            [field.fieldname isEqualToString:@"Eleventh Screen:"]   ||
            [field.fieldname isEqualToString:@"Twelfth Screen:"]    ||
            [field.fieldname isEqualToString:@"Thirteenth Screen:"] ||
            [field.fieldname isEqualToString:@"Fourteenth Screen:"] ||
            [field.fieldname isEqualToString:@"Fifteenth Screen:"]
            )
    {
        value = (int) [[self getScreenSettingsChoices] indexOfObject:str];
    }
    else if([field.fieldname isEqualToString:@"DST Started:"] ||
            [field.fieldname isEqualToString:@"DST Ended:"] )
    {
        value = [str isEqualToString:@"ON"]?1:0;
    }
    else if([field.fieldname isEqualToString:@"Message Type:"])
    {
        if([str isEqualToString:@"Greetings"])
        {
            value = 0;
        }
        else if([str isEqualToString:@"Medicine"])
        {
            value = 1;
        }
        else if([str isEqualToString:@"Survey"])
        {
            value = 2;
        }
        else if([str isEqualToString:@"SMS"])
        {
            value = 3;
        }
        else if([str isEqualToString:@"Call"])
        {
            value = 4;
        }
        else if([str isEqualToString:@"MisCall"])
        {
            value = 5;
        }
        else if([str isEqualToString:@"Reminder"])
        {
            value = 6;
        }
    }
    else if([field.fieldname isEqualToString:@"Font Style:"])
    {
        if([str isEqualToString:@"Large"])
        {
            value = 0;
        }
        else if([str isEqualToString:@"Medium"])
        {
            value = 1;
        }
        else if([str isEqualToString:@"Small"])
        {
            value = 2;
        }
        else if([str isEqualToString:@"XSmall"])
        {
            value = 3;
        }
        else if([str isEqualToString:@"LONG1"])
        {
            value = 4;
        }
        else if([str isEqualToString:@"LONG2"])
        {
            value = 5;
        }

    }
    else if([field.fieldname isEqualToString:@"Text Color:"])
    {
        if([str isEqualToString:@"Black"])
        {
            value = 0;
        }
        else if([str isEqualToString:@"Blue"])
        {
            value = 1;
        }
        else if([str isEqualToString:@"Green"])
        {
            value = 2;
        }
        else if([str isEqualToString:@"Cyan"])
        {
            value = 3;
        }
        else if([str isEqualToString:@"Red"])
        {
            value = 4;
        }
        else if([str isEqualToString:@"Magenta"])
        {
            value = 5;
        }
        else if([str isEqualToString:@"Yellow"])
        {
            value = 6;
        }
        else if([str isEqualToString:@"White"])
        {
            value = 7;
        }
    }
    else if([field.fieldname isEqualToString:@"Background Color:"])
    {
        if([str isEqualToString:@"Black"])
        {
            value = 0;
        }
        else if([str isEqualToString:@"White"])
        {
            value = 65535;
        }
    }
    else if([field.fieldname isEqualToString:@"Pairing Status:"])
    {
        if([str isEqualToString:@"Not-Paired"])
        {
            value =0;
        }
        else if([str isEqualToString:@"Paired in Prod"])
        {
            value = 1;
        }
        else if([str isEqualToString:@"Paired in Test"])
        {
            value = 2;
        }
    }
    else if([field.fieldname isEqualToString:@"Intensity Goal Achieve:"] ||
            [field.fieldname isEqualToString:@"Frequency Goal Achieve:"] ||
            [field.fieldname isEqualToString:@"Tenacity Goal Achieve:"])
    {
        if([str isEqualToString:@"YES"])
        {
            value = 1;
        }
        else
        {
            value = 0;
        }
    }
    else if([field.fieldname isEqualToString:@"Display Trigger Type:"])
    {
        if([str isEqualToString:@"Time Based"])
        {
            value = 1;
        }
        else
        {
            value = 0;
        }
    }
    else if([field.fieldname isEqualToString:@"Display Type:"])
    {
        if([str isEqualToString:@"Visibility Time"])
        {
            value = 0;
        }
        else if([str isEqualToString:@"Force Touch"])
        {
            value = 1;
        }
        else if([str isEqualToString:@"Tap"])
        {
            value = 2;
        }
        else
        {
            value = 3;
        }
    }
    else if([field.fieldname isEqualToString:@"Interval Type:"])
    {
        if([str isEqualToString:@"Hourly"])
        {
            value = 1;
        }
        else
        {
            value = 0;
        }
    }
    else if([field.fieldname isEqualToString:@"DataType/Answer1:"] ||
            [field.fieldname isEqualToString:@"DataType/Answer2:"] ||
            [field.fieldname isEqualToString:@"DataType/Answer3:"] ||
            [field.fieldname isEqualToString:@"DataType/Answer4:"] ||
            [field.fieldname isEqualToString:@"DataType/Answer5:"] ||
            [field.fieldname isEqualToString:@"DataType/Answer6:"] )
    {
        if([str isEqualToString:@"Image"])
        {
            value = 1;
        }
        else
        {
            value = 0;
        }
    }
    else if([field.fieldname isEqualToString:@"Table Type:"] || [field.fieldname isEqualToString:@"Data Type:"])
    {
        if([str isEqualToString:@"Fraud"])
        {
            value = 1;
        }
        else
        {
            value = 0;
        }
    }
    else if([field.fieldname isEqualToString:@"Screen Invert Setting:"])
    {
        if([str isEqualToString:@"Auto daylight"])
        {
            value =0;
        }
        else if([str isEqualToString:@"Always inverted"])
        {
            value = 1;
        }
        else if([str isEqualToString:@"Always not inverted"])
        {
            value = 2;
        }
        else
        {
            value = 3;
        }
    }

    
    return value;
}


-(NSString*)getDatePickerFieldValue:(NSDate*)date
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.dateFormat = @"MM-dd-yyyy   HH:mm";
    NSString *dateString = [outputFormatter stringFromDate:date];

    return dateString;
}

-(NSString*)getStringValueOfCustomControl:(Field*)field
{
    NSString *str = @"";
    
    if([field.fieldname isEqualToString:@"Unit of Measure:"])
    {
        if(field.value)
        {
            str = @"Metric";
        }
        else
        {
            str = @"English";
        }
    }
    else if([field.fieldname isEqualToString:@"Year of Birth:"] )
    {
        int value =(int) field.value + 1900;
        str = [NSString stringWithFormat:@"%d",value];
    }
    else if([field.fieldname isEqualToString:@"Year:"] || [field.fieldname isEqualToString:@"Schedule Year:"])
    {
        int value = (int) field.value>=2000?(int)field.value:(int)field.value+2000;
        str = [NSString stringWithFormat:@"%d",value];
    }
    else if([field.fieldname isEqualToString:@"Month of Birth:"] || [field.fieldname isEqualToString:@"Schedule Month:"])
    {
        str = [Utilities getMonthDescription:(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"Frequency Alarm:"] ||
            [field.fieldname isEqualToString:@"Auto Sync:"] ||
            [field.fieldname isEqualToString:@"Multiple Intensity:"] ||
            [field.fieldname isEqualToString:@"Boot Up Flag:"] ||
            [field.fieldname isEqualToString:@"DST Started:"] ||
            [field.fieldname isEqualToString:@"DST Ended:"] ||
            [field.fieldname isEqualToString:@"Save User Response:"] ||
            [field.fieldname isEqualToString:@"Vibration Setting:"] ||
            [field.fieldname isEqualToString:@"Sensor1:"] ||
            [field.fieldname isEqualToString:@"Sensor2:"] ||
            [field.fieldname isEqualToString:@"Sensor3:"] ||
            [field.fieldname isEqualToString:@"Scrolling (OFF/ON):"])
    {
        str = field.value?@"ON":@"OFF";
    }
    else if([field.fieldname isEqualToString:@"Month:"] ||
            [field.fieldname isEqualToString:@"DST Start Month:"] ||
            [field.fieldname isEqualToString:@"DST End Month:"])
    {
        str = [Utilities getMonthDescription:(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"Day:"] ||
            [field.fieldname isEqualToString:@"DST Start Day:"] ||
            [field.fieldname isEqualToString:@"DST End Day:"] ||
            [field.fieldname isEqualToString:@"Schedule Day:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"Hour:"] ||
            [field.fieldname isEqualToString:@"DST Start Hour:"] ||
            [field.fieldname isEqualToString:@"DST End Hour:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"Minute:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"Second:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"24Hr/12Hr:"])
    {
        str = field.value?@"24Hr":@"12Hr";
    }
    else if([field.fieldname isEqualToString:@"AM/PM:"])
    {
        str = field.value?@"PM":@"AM";
    }
    else if([field.fieldname isEqualToString:@"Offset Type:"] || [field.fieldname isEqualToString:@"DST Offset Type:"])
    {
         str = field.value?@"MINUS":@"ADD";
    }
    else if([field.fieldname isEqualToString:@"Sensitivity Level:"])
    {
        switch (field.value) {
            case 0:
                str= @"Normal";
                break;
            case 1:
                str = @"Medium (N/A))";
                break;
            case 2:
                str = @"High";
                break;
            default:
                str = [NSString stringWithFormat:@"Invalid Value: (%lld)",field.value];
                break;
        }
    }
    else if([field.fieldname isEqualToString:@"Relative Limit:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"Sensitivity Threshold:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"Start Hour:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"End Hour:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"No. of Packet handshake:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"Firmware version:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"Sampling Frequency:"])
    {
        switch (field.value) {
            case 16:
                str = @"16Hz";
                break;
            case 32:
                str = @"32Hz";
                break;
            case 48:
                str = @"48Hz";
                break;
            case 64:
                str = @"64Hz";
                break;
            default:
                str = [NSString stringWithFormat:@"Invalid Value: (%lld)",field.value];
                break;
        }
    }
    else if([field.fieldname isEqualToString:@"Device Mode:"])
    {
        switch (field.value) {
            case 0:
                str = @"Normal";
                break;
            case 1:
                str = @"Always Broadcast";
                break;
            case 2:
                str = @"Factory";
                break;
            case 3:
                str = @"Shipment";
                break;
            case 4:
                str = @"Accel Trigger";
                break;
            default:
                str = [NSString stringWithFormat:@"Invalid Value: (%lld)",field.value];
                break;
        }
    }
    else if([field.fieldname isEqualToString:@"Alarm Duration(ms):"])
    {
        str = [NSString stringWithFormat:@"%.1f",(field.value/16.0) * 1000];
    }
    else if([field.fieldname isEqualToString:@"Beep Type:"])
    {
        str = field.value?@"Long beep":@"Short beep";
    }
    else if([field.fieldname isEqualToString:@"Start Block:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"End Block:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"No. of packet Handshake:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"Flag:"])
    {
        str = [NSString stringWithFormat:@"%d",(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"Boot Up Flag:"])
    {
    }
    else if([field.fieldname isEqualToString:@"First Screen:"]      ||
            [field.fieldname isEqualToString:@"Second Screen:"]     ||
            [field.fieldname isEqualToString:@"Third Screen:"]      ||
            [field.fieldname isEqualToString:@"Fourth Screen:"]     ||
            [field.fieldname isEqualToString:@"Fifth Screen:"]      ||
            [field.fieldname isEqualToString:@"Sixth Screen:"]      ||
            [field.fieldname isEqualToString:@"Seventh Screen:"]    ||
            [field.fieldname isEqualToString:@"Eight Screen:"]      ||
            [field.fieldname isEqualToString:@"Ninth Screen:"]      ||
            [field.fieldname isEqualToString:@"Tenth Screen:"]      ||
            [field.fieldname isEqualToString:@"Eleventh Screen:"]   ||
            [field.fieldname isEqualToString:@"Twelfth Screen:"]    ||
            [field.fieldname isEqualToString:@"Thirteenth Screen:"] ||
            [field.fieldname isEqualToString:@"Fourteenth Screen:"] ||
            [field.fieldname isEqualToString:@"Fifteenth Screen:"]
            )
    {
        str = [[self getScreenSettingsChoices] objectAtIndex:(int)field.value];
    }
    else if([field.fieldname isEqualToString:@"DST Applicable:"])
    {
        str = field.value?@"YES":@"NO";
    }
    else if([field.fieldname isEqualToString:@"Message Type:"])
    {
        switch (field.value) {
            case 0:
                str = @"Greetings";
                break;
            case 1:
                str = @"Medicine";
                break;
            case 2:
                str = @"Survey";
                break;
            case 3:
                str = @"SMS";
                break;
            case 4:
                str = @"Call";
                break;
            case 5:
                str = @"MisCall";
                break;
            case 6:
                str = @"Reminder";
                break;
            default:
                str = [NSString stringWithFormat:@"Invalid Value: (%lld)",field.value];
                break;
        }
    }
    else if([field.fieldname isEqualToString:@"Font Style:"])
    {
        switch (field.value) {
            case 0:
                str = @"Large";
                break;
            case 1:
                str = @"Medium";
                break;
            case 2:
                str = @"Small";
                break;
            case 3:
                str = @"XSmall";
                break;
            case 4:
                str = @"LONG1";
                break;
            case 5:
                str = @"LONG2";
                break;
            default:
                str = [NSString stringWithFormat:@"Invalid Value: (%lld)",field.value];
                break;
        }
    }
    else if([field.fieldname isEqualToString:@"Text Color:"])
    {
        switch (field.value) {
            case 0:
                str = @"Black";
                break;
            case 1:
                str = @"Blue";
                break;
            case 2:
                str = @"Green";
                break;
            case 3:
                str = @"Cyan";
                break;
            case 4:
                str = @"Red";
                break;
            case 5:
                str = @"Magenta";
                break;
            case 6:
                str = @"Yellow";
                break;
            case 7:
                str = @"White";
                break;
            default:
                str = [NSString stringWithFormat:@"Invalid Value: (%lld)",field.value];
                break;
        }
    }
    else if([field.fieldname isEqualToString:@"Background Color:"])
    {
        switch (field.value) {
            case 0:
                str = @"Black";
                break;
            case 65535:
                str = @"White";
                break;
            default:
                str = [NSString stringWithFormat:@"Invalid Value: (%lld)",field.value];
                break;
        }
    }
    else if([field.fieldname isEqualToString:@"Pairing Status:"])
    {
        
        switch (field.value) {
            case 0:
                str = @"Not-Paired";
                break;
            case 1:
                str = @"Paired in Prod";
                break;
            case 2:
                str = @"Paired in Test";
                break;
            default:
                str = [NSString stringWithFormat:@"Invalid Value: (%lld)",field.value];
                break;
        }
    }
    else if([field.fieldname isEqualToString:@"Intensity Goal Achieve:"] ||
            [field.fieldname isEqualToString:@"Frequency Goal Achieve:"] ||
            [field.fieldname isEqualToString:@"Tenacity Goal Achieve:"])
    {
        str = field.value?@"YES":@"NO";
    }
    else if([field.fieldname isEqualToString:@"Display Trigger Type:"])
    {
        str = field.value?@"Time Based":@"WakeUp/Rand";
    }
    else if([field.fieldname isEqualToString:@"Display Type:"])
    {
        switch (field.value) {
            case 0:
                str = @"Visibility Time";
                break;
            case 1:
                str = @"Force Touch";
                break;
            case 2:
                str = @"Tap";
                break;
            case 3:
                str = @"Swipe 3 Sensors";
                break;
            default:
                str = [NSString stringWithFormat:@"Invalid Value: (%lld)",field.value];
                break;
        }
    }
    else if([field.fieldname isEqualToString:@"Skip Button No:"])
    {
        switch (field.value) {
            case 0:
                str = @"No Skip";
                break;
            case 1:
                str = @"Button1";
                break;
            case 2:
                str = @"Button2";
                break;
            case 3:
                str = @"Button3";
                break;
            default:
                str = [NSString stringWithFormat:@"Invalid Value: (%lld)",field.value];
                break;

        }
    }
    else if([field.fieldname isEqualToString:@"Interval Type:"])
    {
        str = field.value?@"Hourly":@"Daily";
    }
    else if([field.fieldname isEqualToString:@"DataType/Answer1:"] ||
            [field.fieldname isEqualToString:@"DataType/Answer2:"] ||
            [field.fieldname isEqualToString:@"DataType/Answer3:"] ||
            [field.fieldname isEqualToString:@"DataType/Answer4:"] ||
            [field.fieldname isEqualToString:@"DataType/Answer5:"] ||
            [field.fieldname isEqualToString:@"DataType/Answer6:"] )
    {

        str = field.value?@"Image":@"Text";
    }
    else if([field.fieldname isEqualToString:@"Table Type:"] || [field.fieldname isEqualToString:@"Data Type:"])
    {
        str = field.value?@"Fraud":@"Normal";
    }
    else if([field.fieldname isEqualToString:@"Screen Invert Setting:"])
    {
        switch (field.value) {
            case 0:
                str = @"Auto daylight";
                break;
            case 1:
                str = @"Always inverted";
                break;
            case 2:
                str = @"Always not inverted";
                break;
            default:
                str = [NSString stringWithFormat:@"Invalid Value: (%lld)",field.value];
                break;
                
        }
    }
    
    return str;
}


//################## Textfield delegates ########################
//###############################################################


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    id textFieldSuper = textField;
    while (![textFieldSuper isKindOfClass:[UITableViewCell class]]) {
        textFieldSuper = [textFieldSuper superview];
    }
    // Get that cell's index path
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(UITableViewCell *)textFieldSuper];
    Field *selectedField = [self.cmdFields.fields objectAtIndex:indexPath.row];
    if(selectedField.textfieldKeyboardType == 1)
    {
        self.navigationItem.rightBarButtonItem = nil;
        selectedField.stringValue = self.txtActiveTextField.text;
    }
    [textField setEnabled:YES];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField// textFieldShouldBeginEditing:(UITextField *)aTextField
{
    if(aTextField.tag!=0)
    {
        self.txtActiveTextField = aTextField;
        id textFieldSuper = aTextField;
        while (![textFieldSuper isKindOfClass:[UITableViewCell class]]) {
            textFieldSuper = [textFieldSuper superview];
        }
        // Get that cell's index path
        NSIndexPath *indexPath = [self.myTableView indexPathForCell:(UITableViewCell *)textFieldSuper];
        Field *selectedField = [self.cmdFields.fields objectAtIndex:indexPath.row];
        
        if(selectedField.textfieldKeyboardType == UIKeyboardTypeNumberPad)
        {
            //[aTextField setKeyboardType:UIKeyboardTypeNumberPad];
            //self.toolBarTextField.text = aTextField.text;
            //[self setToolbarMember:aTextField];
            UITextField *textfield = (UITextField*)[self.inputAccessoryView viewWithTag:200];
            textfield.text = [NSString stringWithFormat:@"%lld",selectedField.value];
            [textfield becomeFirstResponder];
            
            UILabel *label = (UILabel*)[self.inputAccessoryView viewWithTag:100];
            label.text = selectedField.fieldname;
            
            
            ((KeyboardBar*)self.inputAccessoryView).maxLen = selectedField.maxLen;
            
            self.inputAccessoryView.hidden = NO;
        }
        else if(selectedField.textfieldKeyboardType == 200)
        {
            [aTextField setEnabled:NO];
            [self showDateTimePicker:aTextField];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneDateTimePickerClicked:)];
        }
        else if(selectedField.textfieldKeyboardType == 1)
        {
            [aTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [aTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneMessageTextField:)];
        }
        else
        {
            [aTextField setEnabled:NO];
            [self showPicker:aTextField];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
        }
    
        return YES;
    }
    else
    {
        [aTextField setKeyboardType:UIKeyboardTypeNumberPad];
        return YES;
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag!=0)
    {

        id textFieldSuper = textField;
        while (![textFieldSuper isKindOfClass:[UITableViewCell class]]) {
            textFieldSuper = [textFieldSuper superview];
        }
        // Get that cell's index path
        NSIndexPath *indexPath = [self.myTableView indexPathForCell:(UITableViewCell *)textFieldSuper];
        Field *selectedField = [self.cmdFields.fields objectAtIndex:indexPath.row];
        
        if(selectedField.textfieldKeyboardType == UIKeyboardTypeNumberPad)
        {
            [textField resignFirstResponder];
            [self.txtActiveTextField resignFirstResponder];
            return YES;
        }
        else if(selectedField.textfieldKeyboardType == 1)
        {
            [self.txtActiveTextField resignFirstResponder];
            return YES;
        }
        else
        {
            return NO;
        }
    
    }
    else
    {
        return YES;
    }
}
-(void)doneDateTimePickerClicked:(id) sender
{
    [self.txtActiveTextField resignFirstResponder];
    [self.txtActiveTextField setEnabled:YES];
    
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)doneMessageTextField:(id)sender
{
    id textFieldSuper = self.txtActiveTextField;
    while (![textFieldSuper isKindOfClass:[UITableViewCell class]]) {
        textFieldSuper = [textFieldSuper superview];
    }
    // Get that cell's index path
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(UITableViewCell *)textFieldSuper];
    Field *selectedField = [self.cmdFields.fields objectAtIndex:indexPath.row];
    
    selectedField.stringValue = self.txtActiveTextField.text;
    [self.cmdFields.fields replaceObjectAtIndex:indexPath.row withObject:selectedField];
    self.isReceivingResponse = NO;
    [self.myTableView reloadData];
    [self.txtActiveTextField resignFirstResponder];
    [self.txtActiveTextField setEnabled:YES];
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)doneClicked:(id) sender
{
    if(self.txtActiveTextField.tag !=0)
    {
        id textFieldSuper = self.txtActiveTextField;
        while (![textFieldSuper isKindOfClass:[UITableViewCell class]]) {
            textFieldSuper = [textFieldSuper superview];
        }
        // Get that cell's index path
        NSIndexPath *indexPath = [self.myTableView indexPathForCell:(UITableViewCell *)textFieldSuper];
        Field *selectedField = [self.cmdFields.featureName isEqualToString:@"Steps Table Header"]?[self.cmdFields.fields objectAtIndex:indexPath.section]:[self.cmdFields.fields objectAtIndex:indexPath.row];
        
        if(selectedField.textfieldKeyboardType == UIKeyboardTypeNumberPad)
        {
            NSLog(@"tool bar textfield: %@",self.toolBarTextField.text);
            int value = [self.toolBarTextField.text intValue];
            self.txtActiveTextField.text = [NSString stringWithFormat:@"%d",value];
            [self.view becomeFirstResponder];
            [self.txtActiveTextField resignFirstResponder];
            [self.toolBarTextField resignFirstResponder];
            
            
            selectedField.value = value;
            
            [self.cmdFields.fields replaceObjectAtIndex:indexPath.row withObject:selectedField];
            self.isReceivingResponse = NO;
            [self.myTableView reloadData];
        }
        else if(selectedField.textfieldKeyboardType == 200)
        {
            self.navigationItem.rightBarButtonItem = nil;
        }
        else if(selectedField.textfieldKeyboardType == 1)
        {
            selectedField.stringValue = self.txtActiveTextField.text;
        }
        else
        {
            int value = [self getIntValueOfCustomTextField:selectedField stringValue:self.txtActiveTextField.text];
            selectedField.value = value;
            int index = [self.cmdFields.featureName isEqualToString:@"Steps Table Header"]?indexPath.section:indexPath.row;
            [self.cmdFields.fields replaceObjectAtIndex:index withObject:selectedField];
            self.isReceivingResponse = NO;
            [self.myTableView reloadData];
            [self.txtActiveTextField resignFirstResponder];
            [self.txtActiveTextField setEnabled:YES];
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}

-(void)setToolbarMember:(UITextField*)textfield
{
    if(textfield.tag!=0)
    {
        id textFieldSuper = textfield;
        while (![textFieldSuper isKindOfClass:[UITableViewCell class]]) {
            textFieldSuper = [textFieldSuper superview];
        }
        // Get that cell's index path
        NSIndexPath *indexPath = [self.myTableView indexPathForCell:(UITableViewCell *)textFieldSuper];
        Field *selectedField = [self.cmdFields.fields objectAtIndex:indexPath.row];

        self.labelToolBarItemCaption.text = selectedField.fieldname;

        UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *dontBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(doneClicked:)];
        
        NSMutableArray *btns = [[NSMutableArray alloc] initWithObjects:flexButton,dontBtn, nil];
        
        [self.toolbar setItems:btns];
        [self.toolbar addSubview:self.labelToolBarItemCaption];
        [self.toolbar addSubview:self.toolBarTextField];
        [textfield setInputAccessoryView:self.toolbar];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(firstRes:) name:UIKeyboardDidShowNotification object:nil];
    }
}

-(void)firstRes:(id)sender
{
    [self.toolBarTextField becomeFirstResponder];
}



//####################### Pickerview delegate ###########################//
//#########################################################################
//####################################################################################################################

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [self.pickerDataArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [self.pickerDataArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.txtActiveTextField.text = [self.pickerDataArray objectAtIndex:row];
    
    id textFieldSuper = self.txtActiveTextField;
    while (![textFieldSuper isKindOfClass:[UITableViewCell class]]) {
        textFieldSuper = [textFieldSuper superview];
    }
    // Get that cell's index path
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(UITableViewCell *)textFieldSuper];
    Field *selectedField = [self.cmdFields.fields objectAtIndex:indexPath.row];
    
    if(selectedField.textfieldKeyboardType == UIKeyboardTypeNumberPad)
    {
        int value = [self.toolBarTextField.text intValue];
        selectedField.value = value;
        [self.cmdFields.fields replaceObjectAtIndex:indexPath.row withObject:selectedField];
    }
    else
    {
        int value = [self getIntValueOfCustomTextField:selectedField stringValue:self.txtActiveTextField.text];
        selectedField.value = value;
        [self.cmdFields.fields replaceObjectAtIndex:indexPath.row withObject:selectedField];
    }
    
    self.selectedIndex = (int) row;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //I have taken two components thats why I have set frame of my "label" accordingly. you can set the frame of the label depends on number of components you have...
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 145, 45)];
    
    //For right alignment of text,You can set the UITextAlignmentRight of the label.
    //No need to set alignment to UITextAlignmentLeft because it is defaulted to picker data display behavior.
    
    [label setTextAlignment:NSTextAlignmentCenter];
    label.opaque=NO;
    label.backgroundColor=[UIColor clearColor];
    label.textColor = [UIColor blackColor];
    UIFont *font = [UIFont boldSystemFontOfSize:20];
    label.font = font;
    [label sizeToFit];
    if(component == 0)
    {
        [label setText:[NSString stringWithFormat:@"%@",[self.pickerDataArray objectAtIndex:row]]];
    }
    else if(component == 1)
    {
        [label setText:[NSString stringWithFormat:@"%@", [self.pickerDataArray objectAtIndex:row]]];
    }
    return label;
}

- (IBAction)showPicker:(id)sender
{
    id textFieldSuper = self.txtActiveTextField;
    while (![textFieldSuper isKindOfClass:[UITableViewCell class]]) {
        textFieldSuper = [textFieldSuper superview];
    }
    // Get that cell's index path
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(UITableViewCell *)textFieldSuper];
    Field *selectedField =  [self.cmdFields.featureName isEqualToString:@"Steps Table Header"]?[self.cmdFields.fields objectAtIndex:indexPath.section]:[self.cmdFields.fields objectAtIndex:indexPath.row];
    
    self.pickerView = [[UIPickerView alloc]init];
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerDataArray = [[NSMutableArray alloc] init];
    
    UILabel *pickerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 350, 44)];
    [pickerTitle setBackgroundColor:[UIColor clearColor]];
    [pickerTitle setTextColor:[UIColor whiteColor]];
    [pickerTitle setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20]];
    [pickerTitle setText:selectedField.fieldname];
    if([selectedField.fieldname isEqualToString:@"Unit of Measure:"])
    {
        [self.pickerDataArray addObject:@"English"];
        [self.pickerDataArray addObject:@"Metric"];
    }
    else if([selectedField.fieldname isEqualToString:@"24Hr/12Hr:"])
    {
        [self.pickerDataArray addObject:@"24Hr"];
        [self.pickerDataArray addObject:@"12Hr"];
    }
    else if([selectedField.fieldname isEqualToString:@"AM/PM:"])
    {
        [self.pickerDataArray addObject:@"AM"];
        [self.pickerDataArray addObject:@"PM"];
    }
    else if([selectedField.fieldname isEqualToString:@"Offset Type:"] || [selectedField.fieldname isEqualToString:@"DST Offset Type:"])
    {
        [self.pickerDataArray addObject:@"ADD"];
        [self.pickerDataArray addObject:@"MINUS"];
    }
    else if([selectedField.fieldname isEqualToString:@"Year of Birth:"])
    {
        int min = 1920;
        int max = 2015;
        
        for (int i =min; i<=max; i++)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    else if([selectedField.fieldname isEqualToString:@"DST Applicable:"])
    {
        [self.pickerDataArray addObject:@"NO"];
        [self.pickerDataArray addObject:@"YES"];
    }
    else if([selectedField.fieldname isEqualToString:@"Year:"] || [selectedField.fieldname isEqualToString:@"Schedule Year:"])
    {
        int min = 2015;
        int max = 2099;
        
        for (int i =min; i<=max; i++)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
        }

    }
    else if([selectedField.fieldname isEqualToString:@"Month of Birth:"]  || [selectedField.fieldname isEqualToString:@"Month:"] ||
            [selectedField.fieldname isEqualToString:@"DST Start Month:"] || [selectedField.fieldname isEqualToString:@"DST End Month:"] ||
            [selectedField.fieldname isEqualToString:@"Schedule Month:"])
    {
        [self.pickerDataArray addObject:@"Jan"];
        [self.pickerDataArray addObject:@"Feb"];
        [self.pickerDataArray addObject:@"Mar"];
        [self.pickerDataArray addObject:@"Apr"];
        [self.pickerDataArray addObject:@"May"];
        [self.pickerDataArray addObject:@"June"];
        [self.pickerDataArray addObject:@"July"];
        [self.pickerDataArray addObject:@"Aug"];
        [self.pickerDataArray addObject:@"Sep"];
        [self.pickerDataArray addObject:@"Oct"];
        [self.pickerDataArray addObject:@"Nov"];
        [self.pickerDataArray addObject:@"Dec"];
    }
    else if([selectedField.fieldname isEqualToString:@"Day:"] ||
            [selectedField.fieldname isEqualToString:@"DST Start Day:"] ||
            [selectedField.fieldname isEqualToString:@"DST End Day:"] ||
            [selectedField.fieldname isEqualToString:@"Schedule Day:"])
    {
        int min = 1;
        int max = 32;
        for (int i =min; i<=max; i++)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
            
        }
    }
    else if([selectedField.fieldname isEqualToString:@"Hour:"] ||
            [selectedField.fieldname isEqualToString:@"DST Start Hour:"] ||
            [selectedField.fieldname isEqualToString:@"DST End Hour:"])
    {
        int min = 0;
        int max = 23;
        for (int i =min; i<=max; i++)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
            
        }
    }
    else if([selectedField.fieldname isEqualToString:@"Minute:"] ||
            [selectedField.fieldname isEqualToString:@"Second:"])
    {
        int min = 0;
        int max = 59;
        for (int i =min; i<=max; i++)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
            
        }
    }
    else if([selectedField.fieldname isEqualToString:@"Start Hour:"] ||
            [selectedField.fieldname isEqualToString:@"End Hour:"])
    {
        int min = 1;
        int max = 24;
        for (int i =min; i<=max; i++)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
            
        }
    }
    else if([selectedField.fieldname isEqualToString:@"Sensitivity Level:"])
    {
        [self.pickerDataArray addObject:@"Normal"];
        [self.pickerDataArray addObject:@"Medium (N/A))"];
        [self.pickerDataArray addObject:@"High"];
    }
    else if([selectedField.fieldname isEqualToString:@"Relative Limit:"])
    {
        int min = 0;
        int max = 255;
        for (int i =min; i<=max; i++)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
            
        }
    }
    else if([selectedField.fieldname isEqualToString:@"Sensitivity Threshold:"])
    {
        int min = 0;
        int max = 65535;
        for (int i =min; i<=max; i++)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
            
        }
    }
    else if([selectedField.fieldname isEqualToString:@"Sampling Frequency:"])
    {
        [self.pickerDataArray addObject:@"16Hz"];
        [self.pickerDataArray addObject:@"32Hz"];
        [self.pickerDataArray addObject:@"48Hz"];
        [self.pickerDataArray addObject:@"64Hz"];
    }
    else if([selectedField.fieldname isEqualToString:@"Device Mode:"])
    {
        [self.pickerDataArray addObject:@"Normal"];
        [self.pickerDataArray addObject:@"Always Broadcast"];
        [self.pickerDataArray addObject:@"Factory"];
        [self.pickerDataArray addObject:@"Shipment"];
        [self.pickerDataArray addObject:@"Accel Trigger"];
    }
    else if([selectedField.fieldname isEqualToString:@"Firmware version:"])
    {
        [self.pickerDataArray addObject:@"01"];
        [self.pickerDataArray addObject:@"02"];
        [self.pickerDataArray addObject:@"03"];
        [self.pickerDataArray addObject:@"04"];
        [self.pickerDataArray addObject:@"05"];
        [self.pickerDataArray addObject:@"06"];
        [self.pickerDataArray addObject:@"07"];
        [self.pickerDataArray addObject:@"08"];
        [self.pickerDataArray addObject:@"09"];
        [self.pickerDataArray addObject:@"10"];
        [self.pickerDataArray addObject:@"11"];
        [self.pickerDataArray addObject:@"12"];
        [self.pickerDataArray addObject:@"13"];
        [self.pickerDataArray addObject:@"14"];
        [self.pickerDataArray addObject:@"15"];
        [self.pickerDataArray addObject:@"16"];
        [self.pickerDataArray addObject:@"17"];
        [self.pickerDataArray addObject:@"18"];
        [self.pickerDataArray addObject:@"19"];
        [self.pickerDataArray addObject:@"20"];
        [self.pickerDataArray addObject:@"21"];
        [self.pickerDataArray addObject:@"22"];
        [self.pickerDataArray addObject:@"23"];
        [self.pickerDataArray addObject:@"24"];
        [self.pickerDataArray addObject:@"25"];
        [self.pickerDataArray addObject:@"26"];
        [self.pickerDataArray addObject:@"27"];
        [self.pickerDataArray addObject:@"28"];
        [self.pickerDataArray addObject:@"29"];
        [self.pickerDataArray addObject:@"30"];
        [self.pickerDataArray addObject:@"31"];
        [self.pickerDataArray addObject:@"32"];
        [self.pickerDataArray addObject:@"33"];
        [self.pickerDataArray addObject:@"34"];
        [self.pickerDataArray addObject:@"35"];
        [self.pickerDataArray addObject:@"36"];
        [self.pickerDataArray addObject:@"37"];
        [self.pickerDataArray addObject:@"38"];
        [self.pickerDataArray addObject:@"39"];
        [self.pickerDataArray addObject:@"40"];
        [self.pickerDataArray addObject:@"41"];
        [self.pickerDataArray addObject:@"42"];
        [self.pickerDataArray addObject:@"43"];
    }
    else if([selectedField.fieldname isEqualToString:@"Alarm Duration(ms):"])
    {
        [self.pickerDataArray addObject:@"OFF"];
        for (int i=1; i<256; i++)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%.1f",(i/16.0) * 1000]];
        }
        pickerTitle.text = @"Device vibration Duration (ms):";
    }
    else if([selectedField.fieldname isEqualToString:@"Beep Type:"])
    {
        [self.pickerDataArray addObject:@"Short beep"];
        [self.pickerDataArray addObject:@"Long beep"];
        
        pickerTitle.text = @"Beep Type:";
    }
    else if([selectedField.fieldname isEqualToString:@"Start Block:"])
    {
        for (int i=1; i<=64; i++)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        pickerTitle.text = @"Start Block:";
    }
    else if([selectedField.fieldname isEqualToString:@"End Block:"])
    {
        for (int i=1; i<=64; i++)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        pickerTitle.text = @"End Block:";
    }
    else if([selectedField.fieldname isEqualToString:@"No. of Packet handshake:"])
    {
        for (int i=0; i<=255; i++)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        pickerTitle.text = @"No. of packet Handshake:";
    }
    else if([selectedField.fieldname isEqualToString:@"Flag:"])
    {
        for (int i=0; i<=1; i++)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        pickerTitle.text = @"Flag:";
    }
    else if([selectedField.fieldname isEqualToString:@"First Screen:"]      ||
            [selectedField.fieldname isEqualToString:@"Second Screen:"]     ||
            [selectedField.fieldname isEqualToString:@"Third Screen:"]      ||
            [selectedField.fieldname isEqualToString:@"Fourth Screen:"]     ||
            [selectedField.fieldname isEqualToString:@"Fifth Screen:"]      ||
            [selectedField.fieldname isEqualToString:@"Sixth Screen:"]      ||
            [selectedField.fieldname isEqualToString:@"Seventh Screen:"]    ||
            [selectedField.fieldname isEqualToString:@"Eight Screen:"]      ||
            [selectedField.fieldname isEqualToString:@"Ninth Screen:"]      ||
            [selectedField.fieldname isEqualToString:@"Tenth Screen:"]      ||
            [selectedField.fieldname isEqualToString:@"Eleventh Screen:"]   ||
            [selectedField.fieldname isEqualToString:@"Twelfth Screen:"]    ||
            [selectedField.fieldname isEqualToString:@"Thirteenth Screen:"] ||
            [selectedField.fieldname isEqualToString:@"Fourteenth Screen:"] ||
            [selectedField.fieldname isEqualToString:@"Fifteenth Screen:"]
            )
    {
        self.pickerDataArray = [[NSMutableArray alloc] initWithArray:[self getScreenSettingsChoices] copyItems:YES];
    }
    else if([selectedField.fieldname isEqualToString:@"DST Started:"] ||
            [selectedField.fieldname isEqualToString:@"DST Ended:"])
    {
        pickerTitle.text = [NSString stringWithFormat:@"%@",selectedField.fieldname];
        [self.pickerDataArray addObject:@"OFF"];
        [self.pickerDataArray addObject:@"ON"];
    }
    else if([selectedField.fieldname isEqualToString:@"Message Type:"])
    {
        pickerTitle.text = [NSString stringWithFormat:@"%@",selectedField.fieldname];
        
        [self.pickerDataArray addObject:@"Greetings"];
        [self.pickerDataArray addObject:@"Medicine"];
        [self.pickerDataArray addObject:@"Survey"];
        [self.pickerDataArray addObject:@"SMS"];
        [self.pickerDataArray addObject:@"Call"];
        [self.pickerDataArray addObject:@"MisCall"];
        [self.pickerDataArray addObject:@"Reminder"];
    }
    else if([selectedField.fieldname isEqualToString:@"Font Style:"])
    {
        pickerTitle.text = [NSString stringWithFormat:@"%@",selectedField.fieldname];
        
        [self.pickerDataArray addObject:@"Large"];
        [self.pickerDataArray addObject:@"Medium"];
        [self.pickerDataArray addObject:@"Small"];
        [self.pickerDataArray addObject:@"XSmall"];
        [self.pickerDataArray addObject:@"LONG1"];
        [self.pickerDataArray addObject:@"LONG2"];
    }
    else if([selectedField.fieldname isEqualToString:@"Text Color:"])
    {
        pickerTitle.text = [NSString stringWithFormat:@"%@",selectedField.fieldname];
        
        [self.pickerDataArray addObject:@"Black"];
        [self.pickerDataArray addObject:@"Blue"];
        [self.pickerDataArray addObject:@"Green"];
        [self.pickerDataArray addObject:@"Cyan"];
        [self.pickerDataArray addObject:@"Red"];
        [self.pickerDataArray addObject:@"Magenta"];
        [self.pickerDataArray addObject:@"Yellow"];
        [self.pickerDataArray addObject:@"White"];
    }
    else if([selectedField.fieldname isEqualToString:@"Background Color:"])
    {
        pickerTitle.text = [NSString stringWithFormat:@"%@",selectedField.fieldname];
        
        [self.pickerDataArray addObject:@"Black"];
        [self.pickerDataArray addObject:@"White"];
    }
    else if([selectedField.fieldname isEqualToString:@"Pairing Status:"])
    {
        pickerTitle.text = [NSString stringWithFormat:@"%@",selectedField.fieldname];
        
        [self.pickerDataArray addObject:@"Not-Paired"];
        [self.pickerDataArray addObject:@"Paired in Prod"];
        [self.pickerDataArray addObject:@"Paired in Test"];
    }
    else if([selectedField.fieldname isEqualToString:@"Intensity Goal Achieve:"] ||
            [selectedField.fieldname isEqualToString:@"Frequency Goal Achieve:"] ||
            [selectedField.fieldname isEqualToString:@"Tenacity Goal Achieve:"])
    {
        pickerTitle.text = [NSString stringWithFormat:@"%@",selectedField.fieldname];
        
        [self.pickerDataArray addObject:@"NO"];
        [self.pickerDataArray addObject:@"YES"];
    }
    else if([selectedField.fieldname isEqualToString:@"Display Trigger Type:"])
    {
        pickerTitle.text = [NSString stringWithFormat:@"%@",selectedField.fieldname];
        
        [self.pickerDataArray addObject:@"Wake Up/Random"];
        [self.pickerDataArray addObject:@"Time Based"];
    }
    else if([selectedField.fieldname isEqualToString:@"Display Type:"])
    {
        pickerTitle.text = [NSString stringWithFormat:@"%@",selectedField.fieldname];
        
        [self.pickerDataArray addObject:@"Visibility Time"];
        [self.pickerDataArray addObject:@"Force Touch"];
        [self.pickerDataArray addObject:@"Tap"];
        [self.pickerDataArray addObject:@"Swipe 3 Sensors"];
    }
    else if([selectedField.fieldname isEqualToString:@"Skip Button No:"])
    {
        pickerTitle.text = [NSString stringWithFormat:@"%@",selectedField.fieldname];
        
        [self.pickerDataArray addObject:@"No Skip"];
        [self.pickerDataArray addObject:@"Button1"];
        [self.pickerDataArray addObject:@"Button2"];
        [self.pickerDataArray addObject:@"Button3"];
    }
    else if([selectedField.fieldname isEqualToString:@"Interval Type:"])
    {
        pickerTitle.text = [NSString stringWithFormat:@"%@",selectedField.fieldname];
        
        [self.pickerDataArray addObject:@"Daily"];
        [self.pickerDataArray addObject:@"Hourly"];
    }
    else if([selectedField.fieldname isEqualToString:@"DataType/Answer1:"] ||
            [selectedField.fieldname isEqualToString:@"DataType/Answer2:"] ||
            [selectedField.fieldname isEqualToString:@"DataType/Answer3:"] ||
            [selectedField.fieldname isEqualToString:@"DataType/Answer4:"] ||
            [selectedField.fieldname isEqualToString:@"DataType/Answer5:"] ||
            [selectedField.fieldname isEqualToString:@"DataType/Answer6:"] )
    {

        pickerTitle.text = [NSString stringWithFormat:@"%@",selectedField.fieldname];
        
        [self.pickerDataArray addObject:@"Text"];
        [self.pickerDataArray addObject:@"Image"];
    }
    else if([selectedField.fieldname isEqualToString:@"Table Type:"] || [selectedField.fieldname isEqualToString:@"Data Type:"])
    {
        pickerTitle.text = [NSString stringWithFormat:@"%@",selectedField.fieldname];
        
        [self.pickerDataArray addObject:@"Normal"];
        [self.pickerDataArray addObject:@"Fraud"];
    }
    else if([selectedField.fieldname isEqualToString:@"Screen Invert Setting:"])
    {
        [self.pickerDataArray addObject:@"Auto daylight"];
        [self.pickerDataArray addObject:@"Always inverted"];
        [self.pickerDataArray addObject:@"Always not inverted"];
    }

    

    UIToolbar* localToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    localToolbar.barStyle = UIBarStyleBlackOpaque;
    [localToolbar sizeToFit];
    
    //to make the done button aligned to the right
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    /*UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
     style:UIBarButtonItemStyleDone target:self
     action:@selector(doneClicked:)];
     */
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:pickerTitle];
    
    
    [localToolbar setItems:[NSArray arrayWithObjects:title, flexibleSpaceLeft, nil]];
    
    //custom input view
    //textField.inputView = pickerView;
    if(self.pickerDataArray.count >0)
    {
        self.selectedIndex = ((int)[self.pickerDataArray indexOfObject:[sender text]]> (int)[self.pickerDataArray count]) || (int)([self.pickerDataArray indexOfObject:[sender text]]) <0?0:(int)[self.pickerDataArray indexOfObject:[sender text]];
        [self.pickerView selectRow:self.selectedIndex  inComponent:0 animated:NO];
        [sender setText:[self.pickerDataArray objectAtIndex:self.selectedIndex]];
    }
    [sender setInputView:self.pickerView];
    [sender setInputAccessoryView:localToolbar];
}

- (IBAction)showDateTimePicker:(id)sender
{
    self.dateTimePickerView = [[UIDatePicker alloc] init];
    [self.dateTimePickerView addTarget:self action:@selector(updateTextFieldDate) forControlEvents:UIControlEventValueChanged];
    
    UILabel *pickerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 350, 44)];
    [pickerTitle setBackgroundColor:[UIColor clearColor]];
    [pickerTitle setTextColor:[UIColor whiteColor]];
    [pickerTitle setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20]];
    
    UIToolbar* tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    tb.barStyle = UIBarStyleBlackOpaque;
    [tb sizeToFit];
    
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.dateFormat = @"MM-dd-yyyy HH:mm";
    NSDate *selectedDateTime = [outputFormatter dateFromString:self.txtActiveTextField.text];
    self.dateTimePickerView.datePickerMode = UIDatePickerModeDateAndTime;
    self.dateTimePickerView.date = selectedDateTime;
    pickerTitle.text = @"Profile Date Time:";
    
    
    //to make the done button aligned to the right
    
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTimePickerClicked:)];
    
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:pickerTitle];
    
    [tb setItems:[NSArray arrayWithObjects:title, flexibleSpaceLeft, nil]];
    
    [sender setInputView:self.dateTimePickerView];
    [sender setInputAccessoryView:tb];
}

-(void)doneTimePickerClicked:(id) sender
{
    id textFieldSuper = self.txtActiveTextField;
    while (![textFieldSuper isKindOfClass:[UITableViewCell class]]) {
        textFieldSuper = [textFieldSuper superview];
    }
    // Get that cell's index path
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(UITableViewCell *)textFieldSuper];
    Field *selectedField = [self.cmdFields.fields objectAtIndex:indexPath.row];

    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    outputFormatter.dateFormat = @"MM-dd-yyyy HH:mm";
    NSString *timeString = [outputFormatter stringFromDate:self.dateTimePickerView.date];
    self.txtActiveTextField.text = timeString;
    
    selectedField.objectValue = self.dateTimePickerView.date;
    
    [self.cmdFields.fields replaceObjectAtIndex:indexPath.row withObject:selectedField];
    
    [self.myTableView reloadData];

}

-(void)updateTextFieldDate
{
    id textFieldSuper = self.txtActiveTextField;
    while (![textFieldSuper isKindOfClass:[UITableViewCell class]]) {
        textFieldSuper = [textFieldSuper superview];
    }
    // Get that cell's index path
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(UITableViewCell *)textFieldSuper];
    Field *selectedField = [self.cmdFields.fields objectAtIndex:indexPath.row];

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];

    outputFormatter.dateFormat = @"MM-dd-yyyy HH:mm";
    NSString *timeString = [outputFormatter stringFromDate:self.dateTimePickerView.date];
    self.txtActiveTextField.text = timeString;

    selectedField.objectValue = self.dateTimePickerView.date;
    
    [self.cmdFields.fields replaceObjectAtIndex:indexPath.row withObject:selectedField];
}


- (IBAction)startSendCommand:(UIButton *)sender
{
    self.commandTimer = [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(commandTimeout) userInfo:nil repeats:NO];
    self.btnReadWrite.enabled = NO;
    
    self.navigationItem.hidesBackButton = YES;
    NSMutableDictionary* commandInfo = [NSMutableDictionary dictionary];
    
    if([self.cmdFields.featureName isEqualToString:@"Steps by Hour Range"] ||  [self.cmdFields.featureName isEqualToString:@"Current Hour Steps"] || [self.cmdFields.featureName isEqualToString:@"Steps Table Header"])
    {
        int startIndex = 0;
        Field *field = [[Field alloc] init];
        if([self.cmdFields.featureName isEqualToString:@"Steps by Hour Range"])
        {
            startIndex = 7;
            field = [self.cmdFields.fields objectAtIndex:startIndex-2];
        }
        else if([self.cmdFields.featureName isEqualToString:@"Steps Table Header"])
        {
            startIndex = 2;
            field = [self.cmdFields.fields objectAtIndex:startIndex-2];
        }
        else if([self.cmdFields.featureName isEqualToString:@"Current Hour Steps"])
        {
            startIndex = 2;
            field = [self.cmdFields.fields objectAtIndex:startIndex-2];
        }
        
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (int i=startIndex; i < [self.cmdFields.fields count]; i++)
        {
            [indexSet addIndex:i];
        }
        
        self.isReceivingResponse = NO;
        [self.cmdFields.fields removeObjectsAtIndexes:indexSet];
        [self.myTableView reloadData];

        [commandInfo setObject:[NSNumber numberWithInt:(int)field.value] forKey:@"totalPackets"];
    }
    else if ([self.cmdFields.featureName isEqualToString:@"Read Profile Data"])
    {
        int startIndex = 4;
        Field *field = [[Field alloc] init];
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (int i=startIndex; i < [self.cmdFields.fields count]; i++)
        {
            [indexSet addIndex:i];
        }
        self.isReceivingResponse = NO;
        [self.cmdFields.fields removeObjectsAtIndexes:indexSet];
        [self.myTableView reloadData];
        
        field = [self.cmdFields.fields objectAtIndex:startIndex-1];
        [commandInfo setObject:[NSNumber numberWithInt:(int)field.value] forKey:@"totalPackets"];
    }
    else if ([self.cmdFields.featureName isEqualToString:@"Charging History"])
    {
        int startIndex = 0;

        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (int i=startIndex; i < [self.cmdFields.fields count]; i++)
        {
            [indexSet addIndex:i];
        }
        self.isReceivingResponse = NO;
        [self.cmdFields.fields removeObjectsAtIndexes:indexSet];
        [self.myTableView reloadData];
    }

    
    supportedCommandAction action = self.segmentedReadWriteCommand.selectedSegmentIndex?WRITE:READ;
    [commandInfo setObject:[NSNumber numberWithInt:action] forKey:@"commandAction"];
    [commandInfo setObject:[NSNumber numberWithLong:[self.myTableView indexPathForSelectedRow].section] forKey:@"index"];
    [commandInfo setObject:self.cmdFields forKey:@"commandFields"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SendCommand" object:self userInfo:commandInfo];
}

-(void)commandTimeout
{
    self.navigationItem.hidesBackButton = NO;
    self.btnReadWrite.enabled = YES;
    [self.commandTimer invalidate];
}

-(void)didReceiveCommandResponse:(NSNotification*)notification
{
    [self.commandTimer invalidate];
    NSDictionary* responseInfo = notification.userInfo;
    BOOL isSupportedCommand = ![[responseInfo objectForKey:@"UnsupportedCommand"] boolValue];
    self.cmdFields = [responseInfo objectForKey:@"commandFields"];
    supportedCommandAction action = [[responseInfo objectForKey:@"commandAction"] intValue];
    self.profileRecordingDuration = [[responseInfo objectForKey:@"recordDuration"] intValue];
    if(isSupportedCommand)
    {
        if ([self.cmdFields.featureName isEqualToString:@"Start Profile Recording"]  && self.profileRecordingDuration>0)
        {
            
            NSString *tempStr = [NSString stringWithFormat:@"Profile Recording in Progress... %d sec", self.profileRecordingDuration--];
            self.alert = [[UIAlertView alloc] initWithTitle:tempStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            self.profileRecordingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(profileRecordingInProgress) userInfo:nil repeats:YES];
        }
        else
        {
            self.btnReadWrite.enabled = YES;
            self.navigationItem.hidesBackButton = NO;
            
            if(action==READ)
            {
                self.isReceivingResponse = YES;
                [self.myTableView reloadData];
            }
        }
    }
    else
    {
        self.btnReadWrite.enabled = YES;
        self.navigationItem.hidesBackButton = NO;
    }
}

-(void)profileRecordingInProgress
{
    if(self.profileRecordingDuration>0)
    {
        NSString *tempStr = [NSString stringWithFormat:@"Profile Recording in Progress... %d sec", self.profileRecordingDuration--];
        
        [self.alert setTitle:tempStr];
        if(!self.alert.visible)
        {
            [self.alert show];
        }
    }
    else
    {
        [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        self.btnReadWrite.enabled = YES;
        self.navigationItem.hidesBackButton = NO;
    }
}

-(void)setTextViewData:(NSNotification*)notification
{
    NSDictionary* rawLogInfo = notification.userInfo;
    NSString *rawLog = [rawLogInfo objectForKey:@"log"];
    if ([self.textViewRawLog length]>1000) {
        self.textViewRawLog = @"";
    }
    self.textViewRawLog = [self.textViewRawLog stringByAppendingString:rawLog];
    self.textViewRawData.text = self.textViewRawLog;
    [self.textViewRawData scrollRangeToVisible:NSMakeRange([self.textViewRawData.text length], 0)];

    self.updateTableVC.textviewRawData.text = self.textViewRawLog;
    [self.updateTableVC.textviewRawData scrollRangeToVisible:NSMakeRange([self.updateTableVC.textviewRawData.text length], 0)];
}

-(void)updateSelectedField:(NSNotification*)notification
{
    self.commandTimer = [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(commandTimeout) userInfo:nil repeats:NO];
    
    NSDictionary* updateInfo = notification.userInfo;
    Field *selectedField = [updateInfo objectForKey:@"field"];
    
    NSIndexPath *indexPath = [self.myTableView indexPathForSelectedRow];
    
    [self.cmdFields.fields replaceObjectAtIndex:indexPath.section withObject:selectedField];
    
    NSMutableDictionary* commandInfo = [NSMutableDictionary dictionary];
    supportedCommandAction action = WRITE;
    [commandInfo setObject:[NSNumber numberWithInt:action] forKey:@"commandAction"];
    [commandInfo setObject:[NSNumber numberWithLong:[self.myTableView indexPathForSelectedRow].section] forKey:@"index"];
    [commandInfo setObject:self.cmdFields forKey:@"commandFields"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SendCommand" object:self userInfo:commandInfo];
}

-(NSMutableArray*)getScreenSettingsChoices
{
    if(self.myDelegate.selectedModel == PE939)
    {
        if(self.myDelegate.connectedFirmwareVersion <= 0.5f)
        {
            return [[NSMutableArray alloc] initWithObjects:@"OFF",@"Steps",@"Intensity Steps",@"Intensity Time",@"Intensity Cycle",@"Frequency of Steps",@"Distance",@"Calories",@"Time",@"SYNC", nil];
        }
        else
        {
            return [[NSMutableArray alloc] initWithObjects:@"OFF",@"Steps",@"Intensity Steps",@"Intensity Time",@"Frequency of Steps",@"Distance",@"Calories",@"Time",@"SYNC", nil];
        }
    }
    else if(self.myDelegate.selectedModel == PE961 || self.myDelegate.selectedModel == FT962 || self.myDelegate.selectedModel == 661)
    {
        return [[NSMutableArray alloc] initWithObjects:@"OFF",@"Steps",@"Intensity and Time",@"Frequency",@"Distance",@"Calories",@"Time and Date",@"SYNC",@"RESERVED",@"RESERVED",@"RESERVED",@"RESERVED",@"RESERVED",@"RESERVED",@"RESERVED",@"RESERVED",nil];
    }
    else if(self.myDelegate.selectedModel == FT900)
    {
        if(self.myDelegate.connectedFirmwareVersion <=2.3f)
        {
            return [[NSMutableArray alloc] initWithObjects:@"OFF",@"Alarm Message",@"Frequency",@"Steps",@"Time",@"SYNC", nil];
        }
        else
        {
            return [[NSMutableArray alloc] initWithObjects:@"OFF",@"Combined Screen",@"SYNC", nil];
        }
    }
    else if(self.myDelegate.selectedModel == FT905 || self.myDelegate.selectedModel == FT969)
    {
        return [[NSMutableArray alloc] initWithObjects:@"OFF",@"Steps",@"Intensity of Steps",@"Frequency of Steps",@"Distance",@"Calories",@"Time",@"SYNC",@"RESERVED",@"RESERVED",@"RESERVED",@"RESERVED",@"RESERVED",@"RESERVED",@"RESERVED",@"RESERVED", nil];
    }
    else
    {
        return [[NSMutableArray alloc] initWithObjects:@"OFF",@"Steps",@"Intensity of Steps",@"Intensity Time",@"Frequency of Steps",@"Distance",@"Calories",@"Time",@"SYNC", nil];
    }
    
}


@end
