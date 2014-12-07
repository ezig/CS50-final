//
//  ReceiptInfo.m
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 11/28/14.
//
//  Contains getter methods for the receipt info class that return the data in useful string form
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

// Returns the title used for sorting
-(NSString *) sectionTitle
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"y MM"];
    return [dateFormatter stringFromDate:self.date];
}

// Returns the month as a string
-(NSString *) month
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"LLLL"];
    return [dateFormatter stringFromDate:self.date];
}

// Returns the year of the date as a string
-(NSString *) year
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"y"];
    return [dateFormatter stringFromDate:self.date];
}

// Returns string to use in table
-(NSAttributedString *) tableText
{
    // Set text based on expense type
    NSString *toFrom;
    if ([self.expenseType isEqualToString:@"Inflow"]) {
        toFrom = @"from";
    } else {
        toFrom = @"to";
    }
    
    // Convert the day into a number with a suffix (e.g. 1st, 5th
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    
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
    
    // if the day is single digit, add in an extra space
    if ([dateString intValue] < 10)
    {
        [dateString appendString:@"\t"];
    }
    
    // Make the amount totals for outflows red and inflows green
    UIColor *amountColor;
    if ([self.expenseType isEqualToString:@"Outflow"]) {
        amountColor = [UIColor colorWithRed:.888 green:.140 blue:.024 alpha:1];
    }
    else {
        amountColor = [UIColor colorWithRed:0.305 green:0.809 blue:.316 alpha:1];
    }
    
    // set up text with the date bolded
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:dateString attributes:[NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica-Bold" size:15.0] forKey:NSFontAttributeName]];
    
    // Set up attributed string with the appropriate color
    NSMutableAttributedString *amountText = [[NSMutableAttributedString alloc] initWithString:[[NSString alloc] initWithFormat:@"\t\t $%.2f ", [self.amount doubleValue]] attributes:[NSDictionary dictionaryWithObject:amountColor forKey:NSForegroundColorAttributeName]];
    
    // Add the amount text to the output text
    [text appendAttributedString:amountText];
    
    // add the expense type and payee information
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", toFrom, self.payee]]];
    
    return text;
}

@end
