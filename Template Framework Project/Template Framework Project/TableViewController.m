//
//  TableViewController.m
//  BudgetBuddy
//
//  Last modified by Ezra on 11/27/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//

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
    
}

//TODO: decide if we want the user to see the animation
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self reloadTable];
//    NSLog(@"%@", [tableDict description]);
//    NSLog(@"%@", [[tableDict allKeys] description]);
    
    // Reloads the table with an animation
    //[self.tableView reloadData];
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
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
    return [sectionTitles objectAtIndex:section];
}

//TODO: implement month breaks
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
    cell.textLabel.text = [receiptInfo tableText];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Deletes appropriate data entry when the item is deleted from the table in edit mode
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSArray* arr = [tableDict objectForKey:[sectionTitles objectAtIndex:indexPath.section]];
        [context deleteObject:[[arr objectAtIndex:indexPath.row] details]];
        [context deleteObject:[arr objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't delete %@ %@", error, [error localizedDescription]);
            return;
        }

        //[self reloadTable];
        //[tableData removeObjectAtIndex:indexPath.row];
        if ([[tableDict objectForKey:[sectionTitles objectAtIndex:indexPath.section]] count] == 1) {
            [tableDict removeObjectForKey:[sectionTitles objectAtIndex:[indexPath section]]];
            [sectionTitles removeObjectAtIndex:indexPath.section];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [[tableDict objectForKey:[sectionTitles objectAtIndex:[indexPath section]]]
             removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
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
    
    tableData = [[context executeFetchRequest:request error:nil] mutableCopy];
    
    tableDict = [[NSMutableDictionary alloc] init];
    for (id obj in tableData) {
        if([tableDict objectForKey:[obj sectionTitle]] != nil) {
            [[tableDict objectForKey:[obj sectionTitle]] addObject:obj];
        } else {
            [tableDict setValue:[[NSMutableArray alloc] initWithObjects:obj, nil] forKey:[obj sectionTitle]];
        }
    }
    sectionTitles = [[NSMutableArray alloc] initWithArray:[[tableDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    
    [self.tableView reloadData];
    
    //http://stackoverflow.com/questions/419472/have-a-reloaddata-for-a-uitableview-animate-when-changing
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setDuration:.3];
    [[self.tableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
    
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [sectionTitles count])] withRowAnimation:UITableViewRowAnimationFade];
}

@end
