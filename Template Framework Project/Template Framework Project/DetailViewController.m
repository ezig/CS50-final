//
//  DetailViewController.m
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 11/27/14.
//
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView.image = self.receipt.img;
    self.expenseType.text = self.receipt.expenseType;
    self.amount.text = [NSString stringWithFormat:@"%.2f", self.receipt.amount];
    self.payee.text = self.receipt.category;
    self.category.text = self.receipt.payment;
    self.date.text = [self.receipt.date description];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
