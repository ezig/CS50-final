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
    [dateFormatter setDateFormat:@"y MM"];
    return [dateFormatter stringFromDate:self.date];
}

-(NSString *) tableText
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    
    NSString *toFrom;
    if ([self.expenseType isEqualToString:@"Inflow"]) {
        toFrom = @"from";
    } else {
        toFrom = @"to";
    }
    
    return [NSString stringWithFormat:@"%@ \t\t $%.2f %@ %@", [dateFormatter stringFromDate:self.date],
            [self.amount doubleValue], toFrom, self.payee];
}

@end
