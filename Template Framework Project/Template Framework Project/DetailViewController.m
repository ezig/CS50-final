//
//  DetailViewController.m
//  BudgetBuddy
//
//  Last modified by Ezra on 11/27/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Populate fields with receipt information
    self.imageView.image = [UIImage imageWithData:self.details.imageData];
    self.expenseType.text = self.info.expenseType;
    self.amount.text = [NSString stringWithFormat:@"%.2f", [self.info.amount doubleValue]];
    self.payee.text = self.info.payee;
    self.category.text = self.details.category;
    self.payment.text = self.details.payment;
    self.date.text = [self.info.date description];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    // Populate fields with receipt information
//    self.imageView.image = [UIImage imageWithData:self.details.imageData];
//    self.expenseType.text = self.info.expenseType;
//    self.amount.text = [NSString stringWithFormat:@"%.2f", [self.info.amount doubleValue]];
//    self.payee.text = self.info.payee;
//    self.category.text = self.details.category;
//    self.payment.text = self.details.payment;
//    self.date.text = [self.info.date description];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// Passes the receipt information and the index from the original table view
// on to the edit receipt form
 -(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     if ([segue.identifier isEqualToString:@"editReceipt"]) {
         AddReceiptViewController* view = segue.destinationViewController;
         view.info = self.info;
         view.details = self.details;
     }
}

@end
