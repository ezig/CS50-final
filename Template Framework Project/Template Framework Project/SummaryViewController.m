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
    double inflow;
    double outflow;
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
    
    self.navigationItem.title = [[NSString alloc] initWithFormat:@"%@ %@", self.month, self.year];
    // Do any additional setup after loading the view.
    // We need a hostview, you can create one in IB (and create an outlet) or just do this:
    
    CGRect frame = self.view.frame;
    frame.size.height /= 3;
    frame.origin.y = frame.size.height;

    
    CPTGraphHostingView* monthPieView = [[CPTGraphHostingView alloc] initWithFrame:frame];
    [self.view addSubview: monthPieView];
    
    
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reload];
}


- (void)reload
{
    for (int i = 0; i < 7; i++) {
        pieData[i] = 0;
    }
    
    inflow = 0;
    outflow = 0;
    
    // forget about leap years
    NSDictionary *daysInMonth = [[NSDictionary alloc] initWithObjects:@[@31,@28,@31,@30,@31,@30,@31,@31,@30,@31,@30,@31]forKeys:@[@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"]];
    
    NSString *dateString = [[NSString alloc] initWithFormat:@"%@ 01 %@", self.month, self.year];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM dd yyyy"];
    NSDate *dateFrom = [dateFormat dateFromString:dateString];
    
    dateString = [[NSString alloc] initWithFormat:@"%@ %d %@", self.month, [[daysInMonth objectForKey:self.month] intValue], self.year];
    NSDate *dateTo = [dateFormat dateFromString:dateString];
    
    NSArray *data = [self entriesfromDate:dateFrom toDate:dateTo];
    
    titles = @[@"Entertainment", @"Clothing", @"Food", @"Household", @"Miscellaneous", @"Pharmacy", @"Travel"];
    
    for (id obj in data) {
        if ([[obj expenseType] isEqualToString:@"Outflow"]) {
            ReceiptDetails* details = [obj details];
            pieData[[titles indexOfObject:[details category]]] += [[obj amount] doubleValue];
            outflow += [[obj amount] doubleValue];
        } else {
            inflow += [[obj amount] doubleValue];
        }
    }
    
    [pieGraph reloadData];
    

    self.outflowLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%2.f", outflow] attributes:[NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName]];
    self.inflowLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%2.f", inflow] attributes:[NSDictionary dictionaryWithObject:[UIColor greenColor] forKey:NSForegroundColorAttributeName]];
    UIColor *netColor;
    
    if (outflow > inflow) {
        netColor = [UIColor redColor];
    }
    else {
        netColor = [UIColor greenColor];
    }
    
    self.netLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%2.f", inflow-outflow] attributes:[NSDictionary dictionaryWithObject:netColor forKey:NSForegroundColorAttributeName]];
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

    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"date >= %@ && date <= %@", fromDate, toDate];
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
