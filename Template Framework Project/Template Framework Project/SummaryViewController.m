//
//  SummaryViewController.m
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 12/3/14.
//
//

#import "SummaryViewController.h"

@interface SummaryViewController ()
{
    NSMutableArray *pieData;
}

@end

@implementation SummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // We need a hostview, you can create one in IB (and create an outlet) or just do this:
    CGRect frame = self.view.frame;
    frame.size.height /= 2;
    CPTGraphHostingView* hostView = [[CPTGraphHostingView alloc] initWithFrame:frame];
    [self.view addSubview: hostView];
    
    frame.origin.y = frame.size.height;
    CPTGraphHostingView* hostView2 = [[CPTGraphHostingView alloc] initWithFrame:frame];
    [self.view addSubview: hostView2];
    
    CPTGraph* graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    graph.axisSet = nil;
    graph.plotAreaFrame.borderLineStyle = nil;
    hostView.hostedGraph = graph;
    
    CPTGraph* graph2 = [[CPTXYGraph alloc] initWithFrame:hostView2.bounds];
    graph2.axisSet = nil;
    graph2.plotAreaFrame.borderLineStyle = nil;
    hostView2.hostedGraph = graph2;
    
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = self;
    pieChart.pieRadius = 100.0;
    pieChart.identifier = @"PieChart1";
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionCounterClockwise;
        
    pieData=  [NSMutableArray arrayWithObjects:[NSNumber numberWithDouble:90.0],
                    [NSNumber numberWithDouble:20.0],
                    [NSNumber numberWithDouble:30.0],
                    [NSNumber numberWithDouble:40.0],
                    [NSNumber numberWithDouble:50.0], [NSNumber numberWithDouble:60.0], nil];
    
    CPTPieChart *pieChart2 = [[CPTPieChart alloc] init];
    pieChart2.dataSource = self;
    pieChart2.pieRadius = 100.0;
    pieChart2.identifier = @"PieChart1";
    pieChart2.startAngle = M_PI_4;
    pieChart2.sliceDirection = CPTPieDirectionCounterClockwise;
    
    
    [graph addPlot:pieChart];
    [graph2 addPlot:pieChart2];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [pieData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    return [pieData objectAtIndex:index];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
