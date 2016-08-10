//
//  TestAppHomeViewController.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 7/10/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestAppHomeViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate>

@property (strong, nonatomic) UIPickerView* pickerView;
@property (strong, nonatomic) NSMutableArray *pickerDataArray;
@property (assign) int selectedIndex;
@property (weak, nonatomic) IBOutlet UITextField *txtActiveTextField;

@property (weak, nonatomic) IBOutlet UITextField *textfieldTrioModels;

@property (weak, nonatomic) IBOutlet UIImageView *trioImageView;

@property (weak, nonatomic) IBOutlet UIButton *btnGo;
- (IBAction)StartTesting:(UIButton *)sender;

@end
