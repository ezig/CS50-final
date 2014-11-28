//
//  ReceiptDetails.h
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 11/28/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ReceiptInfo.h"

@interface ReceiptDetails : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * payment;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) ReceiptInfo *info;

@end
