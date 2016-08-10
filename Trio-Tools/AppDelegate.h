//
//  AppDelegate.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 7/2/15.
//  Copyright (c) 2015 Fortify Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign) int selectedModel;
@property (assign) float connectedFirmwareVersion;

@end

