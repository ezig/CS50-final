//
//  SummaryViewController.m
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 12/3/14.
//
//  Reached form the summary table view to display the pie chart for all
//  of the entries in a given month based on what is clicked. Also displays the
//  total inflow, outflows, and net for the month. The pie chart only displays outflows
//  The parent view controller should pass a month and year as strings so that
//  a fetch request can be executed to get the appropriate data
//

#import "SummaryViewController.h"

#define NUM_CATEGORIES 7

@interface SummaryViewController ()
{
    double pieData[NUM_CATEGORIES];
    double inflow;
    double outflow;
    NSArray *titles;
    CPTGraph *pieGraph;
}

@end

@implementation SummaryViewController

// Gets managed context object to use for core data fetched requests
- (NSManagedObjectContext *)managedObjectContext
{
    id delegate = [[UIApplication sharedApplication] delegate];
    return [delegate managedObjectContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the title of the screen based on the month and year being viewed
    
    self.navigationItem.title = [[NSString alloc] initWithFormat:@"%@ %@", self.month, self.year];
    
    // Set up a frame for a the graph that is 1/3 of the way down the string
    CGRect frame = self.view.frame;
    frame.size.height /= 3;
    frame.origin.y = frame.size.height;

    // Add view to the screen to host the graph
    CPTGraphHostingView* monthPieView = [[CPTGraphHostingView alloc] initWithFrame:frame];
    [self.view addSubview: monthPieView];
    
    // Create a graph and add it to the host view
    pieGraph = [[CPTXYGraph alloc] initWithFrame:monthPieView.bounds];
    pieGraph.axisSet = nil;
    pieGraph.plotAreaFrame.borderLineStyle = nil;
    monthPieView.hostedGraph = pieGraph;
    
    // Create a plot and add it to the graph
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = self;
    pieChart.pieRadius = 65.0;
    pieChart.identifier = @"PieChart1";
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionCounterClockwise;
    
    [pieGraph addPlot:pieChart];
}

// Reloads the pie chart whenever the view appears
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reload];
}

// Get the data from the core data model and update the pie plot
- (void)reload
{
    // Zero out the pie data array
    for (int i = 0; i < NUM_CATEGORIES; i++) {
        pieData[i] = 0;
    }
    
    inflow = 0;
    outflow = 0;
    
    // still looking for a better method than hardcording here
    NSDictionary *daysInMonth = [[NSDictionary alloc] initWithObjects:@[@31,@28,@31,@30,@31,@30,@31,@31,@30,@31,@30,@31]forKeys:@[@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"]];
    
    // Create a date representing the first of the given month
    NSString *dateString = [[NSString alloc] initWithFormat:@"%@ 01 %@", self.month, self.year];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM dd yyyy"];
    NSDate *dateFrom = [dateFormat dateFromString:dateString];
    
    // Create a date representing the last day of the month based on the harccoded month lengths
    dateString = [[NSString alloc] initWithFormat:@"%@ %d %@", self.month, [[daysInMonth objectForKey:self.month] intValue], self.year];
    NSDate *dateTo = [dateFormat dateFromString:dateString];
    
    // Get data from core data model between the first and last day of the month
    NSArray *data = [self entriesfromDate:dateFrom toDate:dateTo];
    
    titles = @[@"Entertainment", @"Clothing", @"Food", @"Household", @"Miscellaneous", @"Pharmacy", @"Travel"];
    
    // For every receipt in data array, add the total to either the inflow or the outflow total
    // depending on the expense type. Additionally, add the total to the appr
    for (id obj in data) {
        if ([[obj expenseType] isEqualToString:@"Outflow"])
        {
            ReceiptDetails* details = [obj details];
            
            // determine the category of the receipt and increment the index of that category
            // in the pieData array
            pieData[[titles indexOfObject:[details category]]] += [[obj amount] doubleValue];
            
            // update the outflow total
            outflow += [[obj amount] doubleValue];
        } else
        {
            //update inflow total
            inflow += [[obj amount] doubleValue];
        }
    }
    
    // update the graph with new data
    [pieGraph reloadData];
    
    // color
    UIColor *red = [UIColor colorWithRed:.888 green:.140 blue:.024 alpha:1];
    UIColor *green = [UIColor colorWithRed:0.305 green:0.809 blue:.316 alpha:1];
    
    // Display the inflow and the outplow text
    self.outflowLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%2.f", outflow] attributes:[NSDictionary dictionaryWithObject:red forKey:NSForegroundColorAttributeName]];
    self.inflowLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%2.f", inflow] attributes:[NSDictionary dictionaryWithObject:green forKey:NSForegroundColorAttributeName]];
    
    // If the net spending is positive, display it as green, else red
    UIColor *netColor;
    if (outflow < inflow)
    {
        netColor = green;
    }
    else
    {
        netColor = red;
    }
    
    self.netLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"%2.f", inflow-outflow] attributes:[NSDictionary dictionaryWithObject:netColor forKey:NSForegroundColorAttributeName]];
}

// Calculate a color value between blue and green to shade the section of the pie chart
// based on the slice index
-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.11 green:0.55 blue:0.40+0.1*index alpha:1]];
}

// Label the slices of the pie chart
-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    if (pieData[index] != 0) {
        NSString *title = [titles[index] length] > 5 ? [titles[index] substringToIndex:5]:titles[index];
        return [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%@ $%.2f", title, pieData[index]]];
    }
    return [[CPTTextLayer alloc] initWithText:@""];
}

// Count the number of slices
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return NUM_CATEGORIES;
}

// Get the pie chart value from the pieData
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    return [NSNumber numberWithDouble:pieData[index]];
}

// Given a start date and an end date, get all of the receipt info form the core
// data model between the given dates
-(NSArray*)entriesfromDate:(NSDate*)fromDate toDate:(NSDate*)toDate{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"ReceiptInfo"];

    // limit the fetch request by date
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"date >= %@ && date <= %@", fromDate, toDate];
    request.predicate = predicate;
    
    // execute fetch request
    NSArray *data = [context executeFetchRequest:request error:nil];
    return data;
}

@end
