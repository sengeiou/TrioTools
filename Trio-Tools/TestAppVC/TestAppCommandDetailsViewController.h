//
//  TestAppCommandDetailsViewController.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/13/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommandFields.h"

@interface TestAppCommandDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedReadWriteCommand;
- (IBAction)segmentedControlSelectedIndexChange:(UISegmentedControl *)sender;


@property (weak, nonatomic) IBOutlet UIButton *btnReadWrite;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextView *textViewRawData;
@property (assign)BOOL isReceivingResponse;

- (IBAction)startSendCommand:(UIButton *)sender;
-(void)updateDeviceCmdFieldsValuesWithCurrentDateTime;

@property(strong, nonatomic)CommandFields *cmdFields;
@end
