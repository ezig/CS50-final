//
//  ReceiptInfo.h
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 11/28/14.
//
//  Subclass of managed object representing the receipt info enttity.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class ReceiptDetails;

@interface ReceiptInfo : NSManagedObject

@property (nonatomic) NSAttributedString * tableText;
@property (nonatomic) NSString * sectionTitle;
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * payee;
@property (nonatomic, retain) NSString * expenseType;
@property (nonatomic, retain) ReceiptDetails *details;

-(NSString *) month;
-(NSString *) year;

@end
