//
//  ReceiptInfo.m
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 11/28/14.
//
//

#import "ReceiptInfo.h"
#import "ReceiptDetails.h"


@implementation ReceiptInfo

@dynamic tableText;
@dynamic sectionTitle;
@dynamic amount;
@dynamic date;
@dynamic payee;
@dynamic expenseType;
@dynamic details;

-(NSString *) sectionTitle
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"LLLL y"];
    return [dateFormatter stringFromDate:self.date];
}

-(NSString *) tableText
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    return [NSString stringWithFormat:@"%@ \t\t $%.2f to %@", [dateFormatter stringFromDate:self.date],
            [self.amount doubleValue], self.payee];
}

@end
