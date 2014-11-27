//
//  Receipt.h
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 11/27/14.
//
//

#import <Foundation/Foundation.h>

@interface Receipt : NSObject

@property (strong, nonatomic) UIImage *img;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *payment;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *payee;
@property (assign, nonatomic) double amount;
@property (strong, nonatomic) NSString *expenseType;


@end
