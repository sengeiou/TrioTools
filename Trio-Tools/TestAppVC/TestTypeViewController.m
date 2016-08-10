//
//  TestTypeViewController.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/11/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import "TestTypeViewController.h"
#import "TestAppCommandTypeTableViewController.h"

@interface TestTypeViewController ()
@property(strong, nonatomic)TestAppCommandTypeTableViewController *testCommandTypeVC;
@end

@implementation TestTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Test Type";
    
    self.testCommandTypeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"commandTypeVC"];
    
    self.btnManualTest.layer.borderWidth = 1.0f;
    self.btnManualTest.layer.borderColor = [UIColor grayColor].CGColor;
    self.btnManualTest.layer.cornerRadius = 10.0f;
    
    self.btnAutoTest.layer.borderWidth = 1.0f;
    self.btnAutoTest.layer.borderColor = [UIColor grayColor].CGColor;
    self.btnAutoTest.layer.cornerRadius = 10.0f;
    
    self.labelConnectionStatus.layer.borderWidth = 1.0f;
    self.labelConnectionStatus.layer.borderColor = [UIColor grayColor].CGColor;
    self.labelConnectionStatus.layer.cornerRadius = 10.0f;
    
    self.btnAutoTest.enabled = NO;
    

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

- (IBAction)performManualTest:(UIButton *)sender {
    [self.navigationController pushViewController:self.testCommandTypeVC animated:YES];
}

- (IBAction)performAutoTest:(UIButton *)sender {
}
@end
