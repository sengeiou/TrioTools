//
//  TestAppUpdateStepTableViewController.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/25/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Field.h"

@interface TestAppUpdateStepTableViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate>

@property (strong, nonatomic)Field *selectedField;

@property (strong, nonatomic) UIPickerView* pickerView;
@property (strong, nonatomic) NSMutableArray *pickerDataArray;
@property (assign) int selectedIndex;
@property (assign) BOOL isFraud;
@property (weak, nonatomic) IBOutlet UITextField *txtActiveTextField;

@property (weak, nonatomic) IBOutlet UILabel *labelTableDate;
@property (weak, nonatomic) IBOutlet UITextField *textfieldHourNo;
@property (weak, nonatomic) IBOutlet UITextField *textfieldFlagValue;

@property (weak, nonatomic) IBOutlet UILabel *labelTableType;
@property (weak, nonatomic) IBOutlet UITextView *textviewRawData;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdate;
- (IBAction)updateTable:(UIButton *)sender;

@end
