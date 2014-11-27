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
    NSArray *tableData;
}
@end

@implementation TableViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Initialize table data
    tableData = [NSArray arrayWithObjects:@"Welcome to Budget Buddy!", nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addReceipt"]) {
        NSLog(@"Logger");
    }
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
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    return cell;
}

@end
