//
//  TableViewController.m
//  BudgetBuddy
//
//  Last modified by Ezra on 11/27/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//
//  Root view for the log tab. Displays all of the existing transactions in chronological order
//  Can reach detail view controller by clicking on an existing transaction, or you can add
//  a new receipt through the AddReceipt form by clicking the plus in the upper right hand corner
#import "TableViewController.h"
#import "ReceiptInfo.h"

@interface TableViewController ()
{
    NSMutableArray *sectionTitles;
    NSMutableArray *tableData;
    NSMutableDictionary *tableDict;
}
@end

@implementation TableViewController

- (NSManagedObjectContext *)managedObjectContext
{
    id delegate = [[UIApplication sharedApplication] delegate];
    return [delegate managedObjectContext];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // make sure that the status bar is white
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    // add the edit button to allow deletion
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self reloadTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

// Open up add receipt view if + buton is pressed
// Pass on the selected receipt to the show detail view if receipt data selected
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addReceipt"]) {
        AddReceiptViewController* view = segue.destinationViewController;
        view.delegate = self;
    } else if ([segue.identifier isEqualToString:@"showDetail"]) {
        DetailViewController* view = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        // Get the appropriate datum
        NSArray* arr = [tableDict objectForKey:[sectionTitles objectAtIndex:indexPath.section]];
        view.info = [arr objectAtIndex:indexPath.row];
        view.details = [[arr objectAtIndex:indexPath.row] details];
    }
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionTitles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // convert the section title in the YYYY MM form to Month YYYY which is more natural
    NSArray* months = @[@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"];
    
    // get the name of the section
    NSString *sectionName = [sectionTitles objectAtIndex:section];
    
    // break the name into the year (components[0]) and the month components[1]
    NSArray *components = [sectionName componentsSeparatedByString:@" "];
    
    // turn the numeric month into a string from the months array and put that together with the year
    return [NSString stringWithFormat:@"%@ %@",[months objectAtIndex:([components[1] intValue]-1)], components[0]];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiptCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ReceiptCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    // Get the appropriate datum
    NSArray* arr = [tableDict objectForKey:[sectionTitles objectAtIndex:indexPath.section]];
    ReceiptInfo *receiptInfo = [arr objectAtIndex:indexPath.row];
    cell.textLabel.attributedText = [receiptInfo tableText];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Deletes appropriate data entry when the item is deleted from the table in edit mode
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *title = [sectionTitles objectAtIndex:indexPath.section];
        ReceiptInfo *info = [[tableDict objectForKey:title] objectAtIndex:indexPath.row];
        
        // execute deletion from core data model
        NSManagedObjectContext *context = [self managedObjectContext];
        [context deleteObject:[info details]];
        [context deleteObject:info];
        
        // update data model and save
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't delete %@ %@", error, [error localizedDescription]);
            return;
        }

        // if the item is the very last in the section, we need to delete the section
        if ([[tableDict objectForKey:title] count] == 1)
        {
            // remove the section from the data
            [tableDict removeObjectForKey:title];
            
            // remove the section name and remove the section from the table
            // WITH A COOL ANIMATION
            [sectionTitles removeObjectAtIndex:indexPath.section];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationFade];
        }
        // otherwise, just remove the item from the section
        else
        {
            // remove the object from the table data
            [[tableDict objectForKey:[sectionTitles objectAtIndex:[indexPath section]]]
             removeObjectAtIndex:indexPath.row];
            // remove the row from the table with a cool animation
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

// executes a fetch request and updates the the data in the table
-(void)reloadTable
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Sort results of fetch request in ascending date order
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReceiptInfo"];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray* descriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:descriptors];
    
    // execute request
    tableData = [[context executeFetchRequest:request error:nil] mutableCopy];
    
    // create a dictionary to store the data
    // sort the data based on the section title returned by the receipt
    // which is in the form YYYY MM (e.g. 2014 12) so that the dates can be
    // sorted by a case insensitive string compare (this is sloppy but we don't have time to improve it
    
    tableDict = [[NSMutableDictionary alloc] init];
    
    // iterate through the array from the fetch request
    for (id obj in tableData)
    {
        // if an entry from the same year month combination is already
        // in the dictionary, we can just append to the existing array in the dictionary
        if([tableDict objectForKey:[obj sectionTitle]] != nil) {
            [[tableDict objectForKey:[obj sectionTitle]] addObject:obj];
        }
        // otherwise, we need to initialize a new array
        else
        {
            [tableDict setValue:[[NSMutableArray alloc] initWithObjects:obj, nil] forKey:[obj sectionTitle]];
        }
    }
    
    // get all of the section titles (year month combinations) and sort them by string compare
    // the titles are such that this will order them by chronological order
    sectionTitles = [[NSMutableArray alloc] initWithArray:[[tableDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    
    [self.tableView reloadData];
    
    // Display a cool animation when the table reloads.
    // source: http://stackoverflow.com/questions/419472/have-a-reloaddata-for-a-uitableview-animate-when-changing
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setDuration:.3];
    [[self.tableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
}

@end
