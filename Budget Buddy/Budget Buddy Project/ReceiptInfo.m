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

-(NSString *) month
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"LLLL"];
    return [dateFormatter stringFromDate:self.date];
}

-(NSString *) year
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"y"];
    return [dateFormatter stringFromDate:self.date];
}

-(NSAttributedString *) tableText
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    
    NSString *toFrom;
    if ([self.expenseType isEqualToString:@"Inflow"]) {
        toFrom = @"from";
    } else {
        toFrom = @"to";
    }
    
    NSMutableString *dateString = [[NSMutableString alloc] initWithString:[dateFormatter stringFromDate:self.date]];
    if ([dateString intValue] % 10 == 1)
    {
        [dateString appendString:@"st"];
    }
    else if ([dateString intValue] % 10 == 2)
    {
        [dateString appendString:@"nd"];
    }
    else if ([dateString intValue] % 10 == 3)
    {
        [dateString appendString:@"rd"];
    }
    else
    {
        [dateString appendString:@"th"];
    }
    
    if ([dateString intValue] < 11)
    {
        [dateString appendString:@"\t"];
    }
    
    UIColor *amountColor;
    if ([self.expenseType isEqualToString:@"Outflow"]) {
        amountColor = [UIColor colorWithRed:.888 green:.140 blue:.024 alpha:1];
    }
    else {
        amountColor = [UIColor colorWithRed:0.305 green:0.809 blue:.316 alpha:1];
    }
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:dateString attributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica-Bold" size:15.0] forKey:NSFontAttributeName]];
    
    NSMutableAttributedString *amountText = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"\t\t $%2.f ", [self.amount doubleValue]] attributes:[NSDictionary dictionaryWithObject:amountColor forKey:NSForegroundColorAttributeName]];
    
    [text appendAttributedString:amountText];
    
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", toFrom, self.payee]]];
    
    return text;
}

@end
