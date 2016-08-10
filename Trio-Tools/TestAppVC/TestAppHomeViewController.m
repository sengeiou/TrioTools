//
//  TestAppHomeViewController.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 7/10/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "TestAppHomeViewController.h"
#import "TestAppDeviceDiscoveryTableViewController.h"

#import "SupportedModelXmlParser.h"
#import "SupportedModelList.h"
#import "Model.h"
#import "AppDelegate.h"

#import "Definitions.h"

@interface TestAppHomeViewController ()

@property(strong,nonatomic)TestAppDeviceDiscoveryTableViewController* testAppTrioDiscoveryVC;
@property(strong, nonatomic)SupportedModelList *supportedModels;
@property (strong, nonatomic)AppDelegate * myDelegate;
@end

@implementation TestAppHomeViewController

@synthesize supportedModels;


@synthesize testAppTrioDiscoveryVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.testAppTrioDiscoveryVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"testAppTrioDiscoveryVC"];
    
    self.title = @"Test App";
    self.textfieldTrioModels.delegate = self;

    self.btnGo.layer.borderWidth = 1.0f;
    self.btnGo.layer.borderColor = [UIColor grayColor].CGColor;
    self.btnGo.layer.cornerRadius = 10.0f;
    self.pickerDataArray = [[NSMutableArray alloc] init];
    
    self.textfieldTrioModels.layer.borderWidth = 1.0f;
    self.textfieldTrioModels.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textfieldTrioModels.layer.cornerRadius = 10.0f;
    
    self.supportedModels = [SupportedModelXmlParser parseSupportedTrioModelXml];
    for(Model *model in self.supportedModels.supportedModelList)
    {
        [self.pickerDataArray addObject:model.modelName];
    }
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
    
    NSString *imageFilename = [NSString stringWithFormat:@"%d.png",[[self.supportedModels.supportedModelList objectAtIndex:row] modelNumber]];
    self.trioImageView.image = [UIImage imageNamed:imageFilename]?[UIImage imageNamed:imageFilename]:[UIImage imageNamed:@"missing.png"];
    
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
    self.txtActiveTextField.text = self.pickerDataArray.count>0? [self.pickerDataArray objectAtIndex:self.selectedIndex]:self.txtActiveTextField.text;
    [self.txtActiveTextField resignFirstResponder];
    [self.txtActiveTextField setEnabled:YES];
    self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

- (IBAction)showPicker:(id)sender
{
    self.pickerView =  [[UIPickerView alloc]initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 216)];
    
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;

    UILabel *pickerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 350, 44)];
    [pickerTitle setBackgroundColor:[UIColor clearColor]];
    [pickerTitle setTextColor:[UIColor whiteColor]];
    [pickerTitle setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:20]];

    if([sender tag] == 100)
    {
         pickerTitle.text = @"Trio Models";
    }
    
    UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    toolbar.barStyle = UIBarStyleBlackOpaque;
    [toolbar sizeToFit];
    
    //to make the done button aligned to the right
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:pickerTitle];
    [toolbar setItems:[NSArray arrayWithObjects:title, flexibleSpaceLeft, nil]];
    
    //custom input view
    //textField.inputView = pickerView;
    if(self.pickerDataArray.count >0)
    {
        self.selectedIndex = ((int)[self.pickerDataArray indexOfObject:[sender text]]> (int) [self.pickerDataArray count]) || ( (int) [self.pickerDataArray indexOfObject:[sender text]]) < 0?0:(int)[self.pickerDataArray indexOfObject:[sender text]];
        [self.pickerView selectRow:self.selectedIndex  inComponent:0 animated:NO];
        [sender setText:[self.pickerDataArray objectAtIndex:self.selectedIndex]];
    }

    [sender setInputView:self.pickerView];
    [sender setInputAccessoryView:toolbar];
    
}


- (IBAction)StartTesting:(UIButton *)sender
{
    [self doneClicked:sender];
    self.testAppTrioDiscoveryVC.SelectedTrioModel = [[self.supportedModels.supportedModelList objectAtIndex:self.selectedIndex] modelNumber];
    

    self.testAppTrioDiscoveryVC.selectedModel = [self.supportedModels.supportedModelList objectAtIndex:self.selectedIndex];
    self.myDelegate.selectedModel = self.testAppTrioDiscoveryVC.selectedModel.modelNumber;
    [self.navigationController pushViewController:self.testAppTrioDiscoveryVC animated:YES];
    
    
    [self.testAppTrioDiscoveryVC.tableView reloadData];

}


@end
