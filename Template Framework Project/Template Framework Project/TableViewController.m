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
    NSMutableArray *tableData;
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
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Sort results of fetch request in ascending date order
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReceiptInfo"];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray* descriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:descriptors];
    
    tableData = [[context executeFetchRequest:request error:nil] mutableCopy];
    
    // Reloads the table with an animation
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
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
        view.info = tableData[indexPath.row];
        view.details = [tableData[indexPath.row] details];
    }
}

#pragma mark - UITableView Delegate

//TODO: implement month breaks
// Returns number of rows in each section
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableData.count;
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
    ReceiptInfo *receiptInfo = [tableData objectAtIndex:indexPath.row];
    //TODO: Include the date
    cell.textLabel.text = [receiptInfo tableText];
    return cell;
}

//TODO: Make month breaks not editable
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Deletes appropriate data entry when the item is deleted from the table in edit mode
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self managedObjectContext];
        [context deleteObject:[tableData objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't delete %@ %@", error, [error localizedDescription]);
            return;
        }

        [tableData removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
