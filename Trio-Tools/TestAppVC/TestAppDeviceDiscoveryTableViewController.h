//
//  TestAppDeviceDiscoveryTableViewController.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 7/10/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface TestAppDeviceDiscoveryTableViewController : UITableViewController

@property(assign)int SelectedTrioModel;
@property(strong, nonatomic)Model *selectedModel;

@end
