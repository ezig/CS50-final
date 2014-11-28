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
    
    //TODO: Move this
    // Allow user to edit the list of receipts
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReceiptInfo"];
    tableData = [[context executeFetchRequest:request error:nil] mutableCopy];
    
    [self.tableView reloadData];
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

//        // Insert the receipt so that ascending date order is preserved
//        for (i = 0; i < len; i++) {
//            if ([[[tableData objectAtIndex:i] date] compare:receipt.date] == NSOrderedDescending)
//            {
//                break;
//            }
//        }


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
    cell.textLabel.text = [NSString stringWithFormat:@"$%.2f to %@", [receiptInfo.amount doubleValue], receiptInfo.payee];
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
