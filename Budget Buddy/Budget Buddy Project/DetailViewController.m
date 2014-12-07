//
//  DetailViewController.m
//  BudgetBuddy
//
//  Last modified by Ezra on 11/27/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//
//  Reached from the log table view. Parent view should pass receipt info and details
//  so that the view can display the details. Clicking on the edit button will  allow you
//  to change the details of the existing receipt, and clicking on the image will make it appear larger

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Populate fields with receipt information passed from the table
    self.imageView.image = [UIImage imageWithData:self.details.imageData];
    self.expenseType.text = self.info.expenseType;
    self.amount.text = [NSString stringWithFormat:@"%.2f", [self.info.amount doubleValue]];
    self.payee.text = self.info.payee;
    self.category.text = self.details.category;
    self.payment.text = self.details.payment;
    
    // get date string from the date object
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"LLLL d y"];
    self.date.text = [dateFormatter stringFromDate:self.info.date];
}

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
    // pass the current receipt information to the addreceipt view controller
    // so that the entry can be editted
     if ([segue.identifier isEqualToString:@"editReceipt"]) {
         AddReceiptViewController* view = segue.destinationViewController;
         view.info = self.info;
         view.details = self.details;
     }
    
    // let the user click on an image to see it in greater detail
    if ([segue.identifier isEqualToString:@"showImage"]) {
        // get the destination view
        UIViewController *viewController = segue.destinationViewController;
        UIView *view = viewController.view;
        
        // create an image view and fill the view with the image of the current receipt
        UIImage *image = [UIImage imageWithData:self.details.imageData];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.frame];
        [imageView setImage:image];
        [view addSubview:imageView];
    }
}

@end
