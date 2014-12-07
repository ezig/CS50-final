//
//  DetailViewController.h
//  BudgetBuddy
//
//  Last modified by Ezra on 11/27/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReceiptInfo.h"
#import "ReceiptDetails.h"
#import "AddReceiptViewController.h"

@interface DetailViewController : UIViewController

@property (strong) ReceiptInfo *info;
@property (strong) ReceiptDetails *details;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *expenseType;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *payee;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *payment;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end
