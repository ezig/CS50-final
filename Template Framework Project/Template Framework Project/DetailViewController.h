//
//  DetailViewController.h
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 11/27/14.
//
//

#import <UIKit/UIKit.h>
#import "Receipt.h"

@interface DetailViewController : UIViewController

@property (weak, nonatomic) Receipt* receipt;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *expenseType;
@property (weak, nonatomic) IBOutlet UILabel *amount;
@property (weak, nonatomic) IBOutlet UILabel *payee;
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *payment;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end
