//
//  AboutViewController.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/4/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btnDone.layer.borderWidth = 1.0f;
    self.btnDone.layer.borderColor = [UIColor grayColor].CGColor;
    self.btnDone.layer.cornerRadius = 10.0f;
    
    
    NSString * appVersionString = [[NSBundle mainBundle]
                                   objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    self.labelVersionNo.text  = [NSString stringWithFormat:@"Version No: %@", appVersionString];
    // Do any additional setup after loading the view.
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

- (IBAction)dismiss:(UIButton *)sender
{
     [self dismissViewControllerAnimated:YES completion:nil];
}
@end
