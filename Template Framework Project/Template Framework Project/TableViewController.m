//
//  UIViewController+TableViewController.m
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 11/26/14.
//
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
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    // Initialize table data
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addReceipt"]) {
        AddReceiptViewController* view = segue.destinationViewController;
        view.delegate = self;
        view.receiptIdx = -1;
    } else if ([segue.identifier isEqualToString:@"showDetail"]) {
        DetailViewController* view = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        view.receipt = tableData[indexPath.row];
        view.receiptIdx = (int) indexPath.row;
    }
}

-(void)getData:(Receipt *)receipt index:(int)idx
{
    if (tableData == nil) {
        tableData = [[NSMutableArray alloc] init];
    }
    
    if (idx != -1)
    {
        [tableData replaceObjectAtIndex:idx withObject:receipt];
    } else {
        int len = (int) tableData.count;
        int i =0;
        for (i = 0; i < len; i++) {
            if ([[[tableData objectAtIndex:i] date] compare:receipt.date] == NSOrderedDescending)
            {
                break;
            }
        }
        [tableData insertObject:receipt atIndex:i];
    }

    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiptCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ReceiptCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    Receipt *receipt = [tableData objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"$%.2f to %@", receipt.amount, receipt.payee];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableData removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
