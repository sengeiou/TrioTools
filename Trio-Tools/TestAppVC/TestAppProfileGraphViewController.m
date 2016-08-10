//
//  ProfileGraphViewController.m
//  Trio-Tools
//
//  Created by Berkley Bernales on 9/20/15.
//  Copyright © 2015 Fortify Technologies. All rights reserved.
//

#import "TestAppProfileGraphViewController.h"
//#import "GraphView.h"

@interface TestAppProfileGraphViewController ()

@property(strong,nonatomic)UILabel *labelConnectionStatus;

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (nonatomic, strong)NSArray *xAxis;
@property (nonatomic, strong)NSArray *yAxis;
@property (nonatomic, strong)NSArray *zAxis;

@property (nonatomic, strong)NSMutableArray *arrayOfmagnitude;
@property (nonatomic, strong)NSMutableArray *arrayOfProfileCount;

@end



@implementation TestAppProfileGraphViewController

@synthesize myGraph;
@synthesize myTableView;
@synthesize xAxis,yAxis,zAxis;

@synthesize arrayOfProfileCount,arrayOfmagnitude;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Results";
    self.myGraph.frame = CGRectMake(0, 84, self.view.frame.size.width, 245);
    self.myTableView.frame = CGRectMake(0, 331, self.view.frame.size.width, self.view.frame.size.height-331);
    self.labelConnectionStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 20)];
    self.labelConnectionStatus.text = @"Connected";
    self.labelConnectionStatus.textAlignment = NSTextAlignmentCenter;
    self.labelConnectionStatus.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.labelConnectionStatus];
    
    // Create a gradient to apply to the bottom portion of the graph
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeConnectionState:)
                                                 name:@"ConnectionState"
                                               object:nil];
    
    // Apply the gradient to the bottom portion of the graph
    self.myGraph.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    // Apply the gradient to the bottom portion of the graph
    self.myGraph.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    // Enable and disable various graph properties and axis displays
    self.myGraph.enableTouchReport = YES;
    self.myGraph.enablePopUpReport = YES;
    self.myGraph.enableYAxisLabel = YES;
    self.myGraph.autoScaleYAxis = YES;
    self.myGraph.alwaysDisplayDots = NO;
    self.myGraph.enableReferenceXAxisLines = YES;
    self.myGraph.enableReferenceYAxisLines = YES;
    self.myGraph.enableReferenceAxisFrame = YES;
    
    // Draw an average line
    self.myGraph.averageLine.enableAverageLine = YES;
    self.myGraph.averageLine.alpha = 0.6;
    self.myGraph.averageLine.color = [UIColor darkGrayColor];
    self.myGraph.averageLine.width = 2.5;
    self.myGraph.averageLine.dashPattern = @[@(2),@(2)];
    
    // Set the graph's animation style to draw, fade, or none
    self.myGraph.animationGraphStyle = BEMLineAnimationDraw;
    
    // Dash the y reference lines
    self.myGraph.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    
    // Show the y axis values with this format string
    self.myGraph.formatStringForValues = @"%.1f";
    
    // Setup initial curve selection segment
    //self.curveChoice.selectedSegmentIndex = self.myGraph.enableBezierCurve;

}

-(void)didChangeConnectionState:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    
    self.labelConnectionStatus.text = [[userInfo objectForKey:@"status"] boolValue]?@"Connected":@"Disconnected";
    self.labelConnectionStatus.textColor = [[userInfo objectForKey:@"status"] boolValue]?[UIColor blackColor]:[UIColor whiteColor];
    self.labelConnectionStatus.backgroundColor =[[userInfo objectForKey:@"status"] boolValue]?[UIColor greenColor]:[UIColor redColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.xAxis = [self.dictionary objectForKey:@"xaxis"];
    self.yAxis = [self.dictionary objectForKey:@"yaxis"];
    self.zAxis = [self.dictionary objectForKey:@"zaxis"];
    
    [self computeMagnitudeValues];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];

    
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)computeMagnitudeValues
{
    if(self.arrayOfmagnitude)
    {
        [self.arrayOfmagnitude removeAllObjects];
    }
    else
    {
        self.arrayOfmagnitude = [[NSMutableArray alloc] init];
    }
    if(self.arrayOfProfileCount)
    {
        [self.arrayOfProfileCount removeAllObjects];
    }
    else
    {
        self.arrayOfProfileCount = [[ NSMutableArray alloc] init];
    }
    
    for (int i=0; i< [self.xAxis count]; i++)
    {
        int x = (int)[[self.xAxis objectAtIndex:i] intValue]>127? (int)[[self.xAxis objectAtIndex:i] intValue]-256: (int)[[self.xAxis objectAtIndex:i] intValue];
        int y = (int)[[self.yAxis objectAtIndex:i] intValue]>127? (int)[[self.yAxis objectAtIndex:i] intValue]-256: (int)[[self.yAxis objectAtIndex:i] intValue];
        int z = (int)[[self.zAxis objectAtIndex:i] intValue]>127? (int)[[self.zAxis objectAtIndex:i] intValue]-256: (int)[[self.zAxis objectAtIndex:i] intValue];
        
        int magnitude = (x*x) + (y*y) + (z*z);
        
        [self.arrayOfmagnitude addObject:[NSNumber numberWithInt:magnitude]];
        [self.arrayOfProfileCount addObject:[NSNumber numberWithInt:i+1]];
    }
    
    [self.myGraph reloadGraph];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    UILabel *labelHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 40)];
    labelHeader.text = @"Profile Data Details";
    labelHeader.textColor = [UIColor blueColor];
    labelHeader.font = [UIFont fontWithName:@"Arial-BoldMT" size:20.0];
    labelHeader.textAlignment = NSTextAlignmentCenter;
    
    UILabel *labelAxis = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 40)];
    labelAxis.text = @"x-Axis    y-Axis    z-Axis    Magnitude";
    labelAxis.textAlignment = NSTextAlignmentCenter;
    labelAxis.textColor = [UIColor magentaColor];
    labelHeader.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0];
    
    [headerView addSubview:labelHeader];
    [headerView addSubview:labelAxis];
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.

    return  [[self.dictionary objectForKey:@"xaxis"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"Cell"];
    BOOL cellIsPreviouslyNil = NO;
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cellIsPreviouslyNil = YES;
    }
    
    if ([cell.contentView subviews])
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        for (UIView *subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
    
    
    UILabel *axisValues = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 40)];
    axisValues.textAlignment = NSTextAlignmentCenter;
    axisValues.text = [NSString stringWithFormat:@"%.3d       %.3d       %.3d      %.5d",[[self.xAxis objectAtIndex:indexPath.row] intValue], [[self.yAxis objectAtIndex:indexPath.row] intValue], [[self.zAxis objectAtIndex:indexPath.row] intValue], [[self.arrayOfmagnitude objectAtIndex:indexPath.row] intValue]];
    
    [cell.contentView addSubview:axisValues];
    
    
    return cell;
}

- (NSString *)labelForDateAtIndex:(NSInteger)index {
    
    /*
    NSDate *date = [NSDate date];//self.arrayOfProfileCount[index];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MM/dd";
    NSString *label = [df stringFromDate:date];
    */
    NSString *label = [NSString stringWithFormat:@"%d", [self.arrayOfProfileCount[index] intValue]];
    return label;
}

#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return (int)[self.arrayOfmagnitude count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[self.arrayOfmagnitude objectAtIndex:index] intValue];
}

#pragma mark - SimpleLineGraph Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 2;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    
    NSString *label = [self labelForDateAtIndex:index];
    return label;//[label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    //self.labelValues.text = [NSString stringWithFormat:@"%@", [self.arrayOfValues objectAtIndex:index]];
    //self.labelDates.text = [NSString stringWithFormat:@"in %@", [self labelForDateAtIndex:index]];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    /*
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.labelValues.alpha = 0.0;
        self.labelDates.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.labelValues.text = [NSString stringWithFormat:@"%i", [[self.myGraph calculatePointValueSum] intValue]];
        self.labelDates.text = [NSString stringWithFormat:@"between %@ and %@", [self labelForDateAtIndex:0], [self labelForDateAtIndex:self.arrayOfDates.count - 1]];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.labelValues.alpha = 1.0;
            self.labelDates.alpha = 1.0;
        } completion:nil];
    }];*/
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
    //self.labelValues.text = [NSString stringWithFormat:@"%i", [[self.myGraph calculatePointValueSum] intValue]];
    //self.labelDates.text = [NSString stringWithFormat:@"between %@ and %@", [self labelForDateAtIndex:0], [self labelForDateAtIndex:self.arrayOfDates.count - 1]];
}

/* - (void)lineGraphDidFinishDrawing:(BEMSimpleLineGraphView *)graph {
 // Use this method for tasks after the graph has finished drawing
 } */

- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return @" magnitude";
}

@end
