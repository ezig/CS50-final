//
//  TableViewController.m
//  BudgetBuddy
//
//  Last modified by Ezra on 11/27/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()
{
    NSMutableArray *tableData;
}
@end

@implementation TableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //TODO: Move this
    // Allow user to edit the list of receipts
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
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
        // Tell add receipt controller that this is a new insertion
        view.receiptIdx = -1;
    } else if ([segue.identifier isEqualToString:@"showDetail"]) {
        DetailViewController* view = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        view.receipt = tableData[indexPath.row];
        view.receiptIdx = (int) indexPath.row;
    }
}

#pragma mark - ReceiptDelegate

// Create a new receipt entry or update an existing entry
-(void)getData:(Receipt *)receipt index:(int)idx
{
    // Initialize data for table if it doesn't exist
    if (tableData == nil) {
        tableData = [[NSMutableArray alloc] init];
    }
    
    // If idx != -1, editing an existing receipt
    if (idx != -1) {
        // replace the old receipt with the new information
        [tableData replaceObjectAtIndex:idx withObject:receipt];
    }
    // Otherwise, adding a new receipt
    else {
        int len = (int) tableData.count;
        int i;
        
        // Insert the receipt so that ascending date order is preserved
        for (i = 0; i < len; i++) {
            if ([[[tableData objectAtIndex:i] date] compare:receipt.date] == NSOrderedDescending)
            {
                break;
            }
        }
        
        [tableData insertObject:receipt atIndex:i];
    }

    // refresh the table with the updated
    [self.tableView reloadData];
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
    Receipt *receipt = [tableData objectAtIndex:indexPath.row];
    //TODO: Include the date
    cell.textLabel.text = [NSString stringWithFormat:@"$%.2f to %@", receipt.amount, receipt.payee];
    return cell;
}

//TODO: Make month breaks not editable
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Deletes appropriate data entry when the item is deleted from the table in edit mode
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableData removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
