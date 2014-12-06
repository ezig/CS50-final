//
//  SummaryViewController.h
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 12/3/14.
//
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "ReceiptInfo.h"
#import "ReceiptDetails.h"


@interface SummaryViewController : UIViewController <CPTPlotDataSource>

@property (weak, nonatomic) IBOutlet UILabel *outflowLabel;
@property (weak, nonatomic) IBOutlet UILabel *netLabel;
@property (weak, nonatomic) IBOutlet UILabel *inflowLabel;
@property (nonatomic, retain) NSString *month;
@property (nonatomic, retain) NSString *year;
@end
