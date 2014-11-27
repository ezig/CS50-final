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
    }
}

-(void)getData:(Receipt *)receipt
{
    if (tableData == nil) {
        tableData = [[NSMutableArray alloc] init];
    }
    [tableData addObject:receipt];
    NSLog(@"%lu", (unsigned long)tableData.count);
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

@end
