//
//  ViewController.h
//  Budget Buddy
//
//  Last modified by Ezra on 11/27/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>
#import "ReceiptInfo.h"
#import "ReceiptDetails.h"
#import "AutocompleteTextField.h"

@interface AddReceiptViewController : UIViewController <TesseractDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, AutocompleteTextFieldDelegate>

@property (strong) ReceiptInfo *info;
@property (strong) ReceiptDetails *details;
@property(assign, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *paymentPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet AutocompleteTextField *payeeField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *expenseType;

- (IBAction)addPhoto:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
