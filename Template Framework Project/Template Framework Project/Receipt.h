//
//  Receipt.h
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 11/27/14.
//
//

#import <Foundation/Foundation.h>

@interface Receipt : NSObject

@property (weak, nonatomic) UIImage *img;
@property (weak, nonatomic) NSDate *date;
@property (weak, nonatomic) NSString *payment;
@property (weak, nonatomic) NSString *category;
@property (weak, nonatomic) NSString *payee;
@property (assign, nonatomic) double amount;
@property (weak, nonatomic) NSString *expenseType;


@end
