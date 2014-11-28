//
//  TableViewController.h
//  BudgetBuddy
//
//  Last modified by Ezra on 11/27/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddReceiptViewController.h"
#import "DetailViewController.h"

@interface TableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, ReceiptDelegate>

@end