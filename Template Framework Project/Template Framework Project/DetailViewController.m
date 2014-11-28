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

// There HAS to be a better way to do this
-(id)init {
    if (self = [super init])  {
        self.receiptIdx = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Populate fields with receipt information
    self.imageView.image = self.receipt.img;
    self.expenseType.text = self.receipt.expenseType;
    self.amount.text = [NSString stringWithFormat:@"%.2f", self.receipt.amount];
    self.payee.text = self.receipt.payee;
    self.payment.text = self.receipt.payment;
    self.category.text = self.receipt.category;
    self.date.text = [self.receipt.date description];
}

- (void)didReceiveMemoryWarning {
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
         view.receipt = self.receipt;
         view.delegate = [self.navigationController.viewControllers objectAtIndex:0];
         if (self.receiptIdx != -1) {
             view.receiptIdx = self.receiptIdx;
         }
     }
}

@end
