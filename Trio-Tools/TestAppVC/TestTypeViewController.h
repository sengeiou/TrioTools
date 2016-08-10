//
//  TestTypeViewController.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/11/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestTypeViewController : UIViewController


@property (weak, nonatomic) IBOutlet UILabel *labelConnectionStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnManualTest;
@property (weak, nonatomic) IBOutlet UIButton *btnAutoTest;

- (IBAction)performManualTest:(UIButton *)sender;
- (IBAction)performAutoTest:(UIButton *)sender;


@end
