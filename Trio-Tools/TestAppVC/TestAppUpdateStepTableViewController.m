//
//  TestAppUpdateStepTableViewController.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/25/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "TestAppUpdateStepTableViewController.h"

#import "StepTable.h"
#import "Utilities.h"

@interface TestAppUpdateStepTableViewController ()

@end

@implementation TestAppUpdateStepTableViewController

@synthesize selectedField;
@synthesize isFraud;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btnUpdate.frame = CGRectMake(0, self.view.frame.size.height-51, self.view.frame.size.width, 50);
    self.textviewRawData.frame = CGRectMake(0, self.view.frame.size.height-151, self.view.frame.size.width, 100);
    
    self.txtActiveTextField.delegate = self;
    self.textfieldFlagValue.delegate = self;
    self.textfieldHourNo.delegate = self;

    self.title = @"Update Step Table";
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    StepTable *table = (StepTable*)self.selectedField.objectValue;
    
    self.labelTableDate.text = [NSString stringWithFormat:@"%@ %d, 20%.2d",[Utilities getMonthDescription:table.tableMonth],table.tableDay,table.tableYear];
    self.textfieldHourNo.text = @"1";
    self.textfieldFlagValue.text = @"0";
    self.labelTableType.text = self.isFraud?@"Fraud":@"Normal";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//################################################################################################

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
    self.txtActiveTextField.text = [self.pickerDataArray objectAtIndex:row];//self.txtSyncTime.text = [self.pickerDataArray objectAtIndex:row];
    
    self.selectedIndex = (int)row;
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


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField setEnabled:YES];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField// textFieldShouldBeginEditing:(UITextField *)aTextField
{
    self.txtActiveTextField = aTextField;
    [aTextField setEnabled:NO];
    
    [self showPicker:aTextField];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    
    return YES;
}
-(void)doneClicked:(id) sender
{
    /*
     if(self.txtActiveTextField.tag == 0 ||
     self.txtActiveTextField.tag == 1 ||
     self.txtActiveTextField.tag == 4)
     {
     self.txtActiveTextField.text = [self.pickerDataArray objectAtIndex:self.selectedIndex];
     [self.txtActiveTextField resignFirstResponder]; //hides the pickerView
     }
     */
    
    self.txtActiveTextField.text = self.pickerDataArray.count>0? [self.pickerDataArray objectAtIndex:self.selectedIndex]:self.txtActiveTextField.text;
    [self.txtActiveTextField resignFirstResponder];
    [self.txtActiveTextField setEnabled:YES];
    self.navigationItem.rightBarButtonItem = nil;
    
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    /*
     if(textField.tag == 0 || textField.tag == 1)
     {
     textField.text = [textField.text isEqualToString:@""]?@"0":textField.text;
     [textField resignFirstResponder];
     }
     */
    return NO;
}

- (IBAction)showPicker:(id)sender
{
    self.pickerView = [[UIPickerView alloc]init]; // initWithFrame:CGRectMake(0.0, 500.0, [UIScreen mainScreen].bounds.size.width, 216.0)];
    
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerDataArray = [[NSMutableArray alloc] init];
    
    UILabel *pickerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 350, 44)];
    [pickerTitle setBackgroundColor:[UIColor clearColor]];
    [pickerTitle setTextColor:[UIColor whiteColor]];
    [pickerTitle setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20]];
    

    
    if([sender tag] == 5000)
    {
        int min = 1;
        int max = 24;
        for (int i =min; i<=max;)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
            i ++;
        }
        [self.pickerDataArray addObject:@"All Hours"];
        pickerTitle.text = @"Table Hour No.:";
    }
    
    else if([sender tag] == 5001)
    {
        int min = 0;
        int max = 1;
        for (int i =min; i<=max;)
        {
            [self.pickerDataArray addObject:[NSString stringWithFormat:@"%d",i]];
            i ++;
        }
        pickerTitle.text = @"Table Flag:";
    }

    
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 56)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    [toolbar sizeToFit];
    
    //to make the done button aligned to the right
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    /*UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
     style:UIBarButtonItemStyleDone target:self
     action:@selector(doneClicked:)];
     */
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:pickerTitle];
    
    
    [toolbar setItems:[NSArray arrayWithObjects:title, flexibleSpaceLeft, nil]];
    
    //custom input view
    //textField.inputView = pickerView;
    if(self.pickerDataArray.count >0)
    {
        self.selectedIndex = ([self.pickerDataArray indexOfObject:[sender text]]> [self.pickerDataArray count]) || ((int)[self.pickerDataArray indexOfObject:[sender text]]) <0?0:(int)[self.pickerDataArray indexOfObject:[sender text]];
        [self.pickerView selectRow:self.selectedIndex  inComponent:0 animated:NO];
        [sender setText:[self.pickerDataArray objectAtIndex:self.selectedIndex]];
    }
    [sender setInputView:self.pickerView];
    [sender setInputAccessoryView:toolbar];
    
}

- (IBAction)updateTable:(UIButton *)sender
{
    //((StepTable*)self.selectedField.objectValue).tableHourFlag
    
    if([self.textfieldHourNo.text isEqualToString:@"All Hours"])
    {
        if([self.textfieldFlagValue.text intValue])
        {
            ((StepTable*)self.selectedField.objectValue).tableHourFlag = 16777215;
        }
        else
        {
            ((StepTable*)self.selectedField.objectValue).tableHourFlag =0;
        }
    }
    else
    {
        if([self.textfieldFlagValue.text intValue])
        {
            ((StepTable*)self.selectedField.objectValue).tableHourFlag |= (1 << ([self.textfieldHourNo.text intValue]-1));
        }
        else
        {
            ((StepTable*)self.selectedField.objectValue).tableHourFlag &= ~(1 << ([self.textfieldHourNo.text intValue]-1));
        }
    }
    
    
    NSMutableDictionary* updateInfo = [NSMutableDictionary dictionary];
    [updateInfo setObject:self.selectedField forKey:@"field"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSelectedField" object:self userInfo:updateInfo];
}
@end
