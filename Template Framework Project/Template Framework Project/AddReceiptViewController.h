//
//  ViewController.h
//  Budget Buddy
//
//  Last modified by Ezra on 11/23/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>

@interface AddReceiptViewController : UIViewController <TesseractDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *paymentPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet UITextField *payeeField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)addReceipt:(id)sender;
- (IBAction)done:(id)sender;

@end
