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
    double pieData[7];
    NSArray *titles;
    CPTGraph *pieGraph;
}

@end

@implementation SummaryViewController

- (NSManagedObjectContext *)managedObjectContext
{
    id delegate = [[UIApplication sharedApplication] delegate];
    return [delegate managedObjectContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    // We need a hostview, you can create one in IB (and create an outlet) or just do this:
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scroll.pagingEnabled = YES;
    
    CGRect frame = self.view.frame;
    frame.size.height /= 4;
    UIView *monthInfo = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview: monthInfo];
    
    frame.origin.y = frame.size.height;
    frame.size.height *= 2;
    
    CPTGraphHostingView* monthPieView = [[CPTGraphHostingView alloc] initWithFrame:frame];
    [self.view addSubview: monthPieView];
    
    [scroll addSubview: monthInfo];
    [scroll addSubview: monthPieView];
    
    scroll.contentSize = CGSizeMake(self.view.frame.size.width, 3/2.0*self.view.frame.size.height);
    [self.view addSubview:scroll];
    
    pieGraph = [[CPTXYGraph alloc] initWithFrame:monthPieView.bounds];
    pieGraph.axisSet = nil;
    pieGraph.plotAreaFrame.borderLineStyle = nil;
    monthPieView.hostedGraph = pieGraph;
    
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = self;
    pieChart.pieRadius = 75.0;
    pieChart.identifier = @"PieChart1";
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionCounterClockwise;
    
    [pieGraph addPlot:pieChart];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    for (int i = 0; i < 7; i++) {
        pieData[i] = 0;
    }
    
    NSArray *data = [self entriesfromDate:[NSDate dateWithTimeIntervalSince1970:0.0] toDate:[NSDate date]];
    
    titles = @[@"Entertainment", @"Clothing", @"Food", @"Household", @"Miscellaneous", @"Pharmacy", @"Travel"];

    for (id obj in data) {
        ReceiptDetails* details = [obj details];
        pieData[[titles indexOfObject:[details category]]] += [[obj amount] doubleValue];
    }
    

    
    [pieGraph reloadData];
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.11 green:0.55 blue:0.40+0.1*index alpha:1]];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    if (pieData[index] != 0) {
        NSString *title = [titles[index] length] > 5 ? [titles[index] substringToIndex:5]:titles[index];
        return [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%@ $%.2f", title, pieData[index]]];
    }
    return [[CPTTextLayer alloc] initWithText:@""];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 7;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    return [NSNumber numberWithDouble:pieData[index]];
}

-(NSArray*)entriesfromDate:(NSDate*)fromDate toDate:(NSDate*)toDate{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"ReceiptInfo"];

    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"date >= %@ && date <= %@ && expenseType LIKE 'Outflow'", fromDate, toDate];
    request.predicate = predicate;
    
    NSArray *data = [context executeFetchRequest:request error:nil];
    
    return data;
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
