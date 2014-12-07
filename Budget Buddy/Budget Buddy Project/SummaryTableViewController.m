//
//  SummaryTableViewController.m
//  BudgetBuddy
//
//  Last modified by Ezra on 12/6/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//
//  Root view of the summary tab. Displays the list of months for which receipt data exists
//  Can reach the summary pie chart view by clicking on one of the months
//

#import "SummaryTableViewController.h"
#import "ReceiptInfo.h"
#import "SummaryViewController.h"

@interface SummaryTableViewController ()
{
    NSMutableArray *sectionTitles;
    NSMutableArray *tableData;
    NSMutableDictionary *tableDict;
}
@end

@implementation SummaryTableViewController

// get the managed context object from the delegate for core data requests
- (NSManagedObjectContext *)managedObjectContext
{
    id delegate = [[UIApplication sharedApplication] delegate];
    return [delegate managedObjectContext];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // make sure that the status bar is white to match the overall theme
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
}

// refresh the table whenever the view appears
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // refresh data and reload table
    [self reloadTable];
}

#pragma mark - Navigation

// Open up add receipt view if + buton is pressed
// Pass on the selected receipt to the show detail view if receipt data selected
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // if a month is clicked, pass the month and the year of the cell to
    // the show summary view so that the analytics can be shown
    if ([segue.identifier isEqualToString:@"showSummary"]) {
        // get destination controller
        SummaryViewController* view = segue.destinationViewController;
        
        // get the month and year and pass to child view controller
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        view.year = [sectionTitles objectAtIndex:indexPath.section];
        view.month = [[tableDict objectForKey:view.year] objectAtIndex:indexPath.row];
    }
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionTitles count];
}

// returns title of section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionTitles objectAtIndex:section];
}

// Returns number of rows in each section
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[tableDict objectForKey:[sectionTitles objectAtIndex:section]] count];
}

// Minimizes memory usage by reusing table cells.
// Creates new cells to display only when necessary
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Try to reuse cells when possible, otherwise create a new one
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Summary"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Summary"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Get the appropriate datum
    NSArray* arr = [tableDict objectForKey:[sectionTitles objectAtIndex:indexPath.section]];
    //ReceiptInfo *receiptInfo = [arr objectAtIndex:indexPath.row];
    cell.textLabel.text = [arr objectAtIndex:indexPath.row];
    return cell;
}

// prevent users from deleting entries
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// terrible horrible no good very bad hack

-(void)reloadTable
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Sort results of fetch request in ascending date order
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReceiptInfo"];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray* descriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:descriptors];
    
    // get data from model
    tableData = [[context executeFetchRequest:request error:nil] mutableCopy];
    
    tableDict = [[NSMutableDictionary alloc] init];
    
    // for every receipt info object from the fetch request, we want to find out
    // all of the years and months that have receipt entries. We create a dictionary tableDict
    // that has years as the keys and contains arrays of months.
    for (ReceiptInfo* info in tableData) {
        // if the year of the receipt already exists in the dictionary
        if([tableDict objectForKey:[info year]] != nil)
        {
            // if the month does not already exist, add the month to the dictionary
            if([[tableDict objectForKey:[info year]] indexOfObject:[info month]] == NSNotFound)
            {
                [[tableDict objectForKey:[info year]] addObject:[info month]];
            }
        }
        // if the year does not already exist, add the year to the dictionary and initialize an
        // array containing the month
        else
        {
            [tableDict setValue:[[NSMutableArray alloc] initWithObjects:[info month], nil] forKey:[info year]];
        }
    }
    
    // get the list of the sections, which will be year, and sort them in chronological order
    // which can be done with a basic string compare
    sectionTitles = [[NSMutableArray alloc] initWithArray:[[tableDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    
    [self.tableView reloadData];
    
    // Display a cool animation when the table reloads.
    //http://stackoverflow.com/questions/419472/have-a-reloaddata-for-a-uitableview-animate-when-changing
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setDuration:.3];
    [[self.tableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];

}

@end
