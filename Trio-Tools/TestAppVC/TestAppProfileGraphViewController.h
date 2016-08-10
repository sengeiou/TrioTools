//
//  ProfileGraphViewController.h
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/20/15.
//  Copyright © 2015 Fortify Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMSimpleLineGraphView.h"


@interface TestAppProfileGraphViewController : UIViewController<BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property(strong, nonatomic)NSDictionary* dictionary;



@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *myGraph;

@end
