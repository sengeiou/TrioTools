//
//  AboutViewController.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/4/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *labelVersionNo;
- (IBAction)dismiss:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@end
