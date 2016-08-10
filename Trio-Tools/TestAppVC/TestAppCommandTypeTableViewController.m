//
//  TestAppCommandTypeTableViewController.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/11/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "TestAppCommandTypeTableViewController.h"

#import "TestAppCommandDetailsViewController.h"

#import "Field.h"

#import "FeatureList.h"
#import "CommandList.h"

#import "AppDelegate.h"

@interface TestAppCommandTypeTableViewController ()

@property(strong,nonatomic)TestAppCommandDetailsViewController *commandDetailsVC;
@property (strong, nonatomic)AppDelegate * myDelegate;
@end

@implementation TestAppCommandTypeTableViewController

@synthesize myDelegate;
@synthesize features;
@synthesize commandDetailsVC;
@synthesize isConnected;
@synthesize cmdList;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeConnectionState:)
                                                 name:@"ConnectionState"
                                               object:nil];
    self.commandDetailsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"commandDetailsVC"];
    
    self.title = @"Commands";
}

-(void)didChangeConnectionState:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    
    self.isConnected = [[userInfo objectForKey:@"status"] boolValue];
    

    [self.tableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //self.commandTypes = [CommandTypeXmlParser parseCommandType:self.myDelegate.connectedTrioModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.features.featureGroupList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    FeatureList *featureList =[self.features.featureGroupList objectAtIndex:section];
    return  [featureList.featureList count];
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
    NSString *featureType = [[NSString alloc] init];
    
    featureType = [[[self.features.featureGroupList objectAtIndex:indexPath.section] featureList] objectAtIndex:indexPath.row];
    [cell.textLabel setText:featureType];
    [cell.textLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:22.0]];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tableViewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width*0.70, 40)];
    
    labelTitle.text = [[self.features.featureGroupList objectAtIndex:section] groupName];
    labelTitle.textColor = [UIColor blueColor];
    labelTitle.font = [UIFont fontWithName:@"Arial-BoldMT" size:19.0];
    
    UILabel *labelConnectionStatus = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.67, 5, self.view.frame.size.width*0.30, 40)];
    
    labelConnectionStatus.textColor = self.isConnected?[UIColor blackColor]:[UIColor whiteColor];
    labelConnectionStatus.backgroundColor = self.isConnected?[UIColor greenColor]:[UIColor redColor];
    labelConnectionStatus.text = self.isConnected?@"Connected":@"Disconnected";
    labelConnectionStatus.textAlignment =NSTextAlignmentCenter;
    
    [tableViewHeader addSubview:labelConnectionStatus];
    [tableViewHeader addSubview:labelTitle];
    return tableViewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    self.commandDetailsVC.title = cell.textLabel.text;
    int index = [self getCmdFieldsIndex:indexPath];
    
    CommandFields *fields = [self.cmdList.commandList objectAtIndex:index];

    self.commandDetailsVC.cmdFields = fields;
    if([fields.featureName isEqualToString:@"Device Settings"])
    {
        [self.commandDetailsVC updateDeviceCmdFieldsValuesWithCurrentDateTime];
    }
    else if([fields.featureName isEqualToString:@"Screen Settings"])
    {
        Field *NumberOfScreen = (Field*) [self.commandDetailsVC.cmdFields.fields objectAtIndex:0];
        for (int i=0; i<NumberOfScreen.value; i++)
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
            
            [self.commandDetailsVC.cmdFields.fields addObject:field];
        }
    }
    [self.navigationController pushViewController:self.commandDetailsVC animated:YES];
    self.commandDetailsVC.isReceivingResponse = NO;
    [self.commandDetailsVC.myTableView reloadData];
}

-(int)getCmdFieldsIndex:(NSIndexPath*)indexPath
{
    int index = 0;
    
    for (int sec =0 ; sec <[self.tableView numberOfSections]; sec++)
    {
        if(indexPath.section == sec)
        {
            index = index + (int)indexPath.row;
            break;
        }
        else
        {
            index = index + (int)[self.tableView numberOfRowsInSection:sec];
        }
    }
    
    
    
    return index;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
