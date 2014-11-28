//
//  ViewController.m
//  Budget Buddy
//
//  Last modified by Ezra on 11/27/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//

#import "AddReceiptViewController.h"

// Constants for different alert views
#define CAMERA_ALERT 1
#define CANCEL_ALERT 2
#define INVALID_ALERT 3

@interface AddReceiptViewController ()
{
    NSArray *categoryData;
    NSArray *paymentData;
}
@end

@implementation AddReceiptViewController

// TODO: make this less bad
-(id)init {
    if (self = [super init])  {
        self.receiptIdx = -1;
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.payeeField.delegate = self;
    self.amountField.delegate = self;
    self.paymentPicker.delegate = self;
    self.categoryPicker.delegate = self;
    
    // Set gesture recognize to dismiss keyboards
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    // Set data for pickers
    paymentData = @[@"Cash", @"Credit", @"Debit", @"Check"];
    categoryData = @[@"Entertainment", @"Pharmacy", @"Clothing", @"Bananas", @"Cats"];

    // Connect data to pickers
    self.paymentPicker.dataSource = self;
    self.categoryPicker.dataSource = self;
    
    // Hide the default back button so we can use custom cancel behavior
    [self.navigationItem setHidesBackButton:YES];

    // If the receipt property is set, that means we are editing an existing receipt,
    // so set the fields to the previous properties of the receipt we are editing
    if (self.receipt != nil) {
        self.imageView.image = self.receipt.img;
        
        if ([self.receipt.expenseType isEqualToString:@"Inflow"]) {
            [self.expenseType setSelectedSegmentIndex:0];
        } else {
            [self.expenseType setSelectedSegmentIndex:1];
        }
        
        self.amountField.text = [NSString stringWithFormat:@"%.2f", self.receipt.amount];
        self.payeeField.text = self.receipt.payee;
        
        NSUInteger categoryIdx = [categoryData indexOfObject:self.receipt.category];
        [self.categoryPicker selectRow:categoryIdx inComponent:0 animated:YES];

        NSUInteger paymentIdx = [paymentData indexOfObject:self.receipt.payment];
        [self.paymentPicker selectRow:paymentIdx inComponent:0 animated:YES];
        
        self.datePicker.date = self.receipt.date;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Called by gesture recognizer when user touches outside of keyboard.
// Dismisses keyboard when user touches outside.
-(void)dismissKeyboard
{
    [self.view endEditing:YES];
}

// Opens up camera interface
- (void)takePhoto
{
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

// Opens up photo library interface
- (void)choosePhoto
{
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

// Given string from Tesseract, extracts the dollar amount.
-(void)parseText:(NSString *)text
{
    // Break up string into "words" wherever there is a space or a newline
    NSArray* wordArray = [text componentsSeparatedByCharactersInSet:
                          [NSCharacterSet characterSetWithCharactersInString:@" \n"]];
    
    // Iterate backwards through the array of words and find the word nearest
    // to the end that starts with a $
    NSUInteger index = [wordArray indexOfObjectWithOptions:NSEnumerationReverse passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        // Check if word has valid length and first character is $
        if ([obj length] > 0 && [obj characterAtIndex:0] == '$') {
            return YES;
        }
        
        return NO;
    }];
    
    
    // If a valid amount was found, display it.
    // Otherwise, don't change the text field
    if (index != NSNotFound) {
        self.amountField.text = wordArray[index];
    }
}

// Displays an error alert message with the message passed in as apology
-(void)apologize:(NSString *)apology
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Input" message:apology delegate:self cancelButtonTitle:@"Sorry" otherButtonTitles:nil];
    alert.tag = INVALID_ALERT;
    [alert show];
}

//TODO: MATT JIANG
// Ensures that the submitted receipt is valid
-(BOOL)validateInput
{
    if ([self.amountField.text length] == 0) {
        [self apologize:@"Invalid Amount"];
        return NO;
    } else if ([self.payeeField.text length] == 0) {
        [self apologize:@"Invalid Payee"];
        return NO;
    }
    return YES;
}

#pragma mark - IBActions

// Called when the button on the add pictue is pressed
// Creates alert asking for which photo source to use for image
- (IBAction)addPhoto:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Choose Photo Source" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Camera",@"Photo Library",nil];
    alert.tag = CAMERA_ALERT;
    [alert show];
}

// Extracts information form user input fields and returns data to root controller
// Pops view back to root view controller
- (IBAction)done:(id)sender {
    if ([self validateInput]) {
        Receipt* receipt = [[Receipt alloc] init];
        receipt.img = self.imageView.image;
        receipt.date = self.datePicker.date;
        receipt.payment = [paymentData objectAtIndex:[self.paymentPicker selectedRowInComponent:0]];
        receipt.category= [categoryData objectAtIndex:[self.categoryPicker selectedRowInComponent:0]];
        receipt.payee = self.payeeField.text;
        receipt.amount = [self.amountField.text doubleValue];
        receipt.expenseType = [self.expenseType titleForSegmentAtIndex:[self.expenseType selectedSegmentIndex]];
        
        [self.delegate getData:receipt index:self.receiptIdx];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

// Custom cancel behavior for when the user tries to go back.
// Makes sure that the user really wants to go back
- (IBAction)cancel:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning: Everything unsaved will be lost." message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok",nil];
    alert.tag = CANCEL_ALERT;
    [alert show];
}

#pragma mark - TeseractDelegate

// Extracts text and calls parseText from image passed as img
-(void)recognizeImageWithTesseract:(UIImage *)img
{
    // set language
    Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    tesseract.delegate = self;

    // Limit characters to search
    [tesseract setVariableValue:@"$.,0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" forKey:@"tessedit_char_whitelist"];
    
    // this line produces a weird error and I don't know why
    [tesseract setImage:[img blackAndWhite]];
    [tesseract recognize];
    
    // parse the text from the image
    [self parseText:[tesseract recognizedText]];
    
    tesseract = nil;
}

//TODO: What does this do anyway?
- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract
{
    //NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

#pragma mark - UIImagePickerController Delegate

// Called when the image picker controller, either the camera or the photo library
// Calls recognizeImageWithTesseract on the chosen image and disables
// user interaction with the view while the OCR is taking place
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the image from the picker and dismiss the picker
    UIImage *img = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.imageView.image = img;

    // Show the activity indicator and disable interaction
    [self.activityView startAnimating];
    [self.view setUserInteractionEnabled:NO];
    
    // Create gray cover for screen so that it is clear that user interaction is disabled
    UIView *grayView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    grayView.backgroundColor = [UIColor blackColor];
    grayView.alpha = 0.5;
    // Present view
    [[UIApplication sharedApplication].keyWindow addSubview:grayView];
    
    // Recognize image on seperate thread so that the UI will update before
    // the recognition finishes
    dispatch_async(dispatch_get_main_queue(), ^{
        [self recognizeImageWithTesseract:img];
        [self.activityView stopAnimating];
        [grayView removeFromSuperview];
        [self.view setUserInteractionEnabled:YES];
    });
}

#pragma mark - UIAlertView Delegate

// Respond to the alertview button press depending on which alert view
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // photo source choice alert
    if (alertView.tag == CAMERA_ALERT) {
        // camera selected
        if (buttonIndex == 1) {
            [self takePhoto];
        }
        // photo library selected
        else if (buttonIndex == 2) {
            [self choosePhoto];
        }
    }
    // cancel alert
    else if (alertView.tag == CANCEL_ALERT) {
        // pressed ok
        if (buttonIndex == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UITextField Delegate

// Close the keyboard if you press the "done" button on the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIPickerViewDataSource Delegate

// Each picker view only has one component
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// Returns the number of elements of the pickerdata for the appropriate picker view
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.categoryPicker])
    {
        return categoryData.count;
    }
    
    return paymentData.count;
}

#pragma mark - UIPickerView Delegate

// Gets the data entry from the appropriate data set to display in pickerview
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.categoryPicker])
    {
        return categoryData[row];
    }
    
    return paymentData[row];
}
@end
