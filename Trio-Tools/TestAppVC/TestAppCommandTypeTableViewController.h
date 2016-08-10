//
//  TestAppCommandTypeTableViewController.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 8/11/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeatureGroup.h"
#import "CommandList.h"

@interface TestAppCommandTypeTableViewController : UITableViewController
@property(strong,nonatomic)FeatureGroup *features;
@property(strong, nonatomic)CommandList *cmdList;
@property(assign)BOOL isConnected;

@end
