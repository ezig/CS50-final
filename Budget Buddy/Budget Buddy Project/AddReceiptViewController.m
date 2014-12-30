//
//  ViewController.m
//  Budget Buddy
//
//  Last modified by Ezra on 12/6/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//
//  Form for adding or editing receipts. Can be reached directly from the log to add a receipt
//  or from the show detail screen in order to edit an existing receipt, in which case the calling
//  view controller should pass na existing receipt info and details to prepopulate the fields of the form
//
#import "AddReceiptViewController.h"
#import "ReceiptInfo.h"
#import "ReceiptDetails.h"

// Constants for different alert view tags
#define CAMERA_ALERT 1
#define CANCEL_ALERT 2
#define INVALID_ALERT 3

// Tag to keep track of the autocompletion payee field
#define PAYEE_FIELD 1
@interface AddReceiptViewController ()
{
    NSArray *categoryData;
    NSArray *paymentData;
}
@end

@implementation AddReceiptViewController

// get the managed object context from the app delegate
- (NSManagedObjectContext *)managedObjectContext
{
    id delegate = [[UIApplication sharedApplication] delegate];
    return [delegate managedObjectContext];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.payeeField.delegate = self;
    self.amountField.delegate = self;
    self.paymentPicker.delegate = self;
    self.categoryPicker.delegate = self;
    
    self.payeeField.userString = @"";
    
    // Set gesture recognize to dismiss keyboards
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    // Set data for pickers
    paymentData = @[@"Cash", @"Check", @"Credit", @"Debit"];
    categoryData = @[@"Clothing", @"Entertainment", @"Food", @"Household", @"Income", @"Miscellaneous", @"Pharmacy", @"Travel"];

    // Connect data to pickers
    self.paymentPicker.dataSource = self;
    self.categoryPicker.dataSource = self;
    
    // Hide the default back button so we can use custom cancel behavior
    [self.navigationItem setHidesBackButton:YES];

    // If the info and detail properties iare set, that means we are editing an existing receipt,
    // so set the fields to the previous properties of the receipt we are editing
    if (self.info && self.details)
    {
        
        //Populate fields with receipt information
        self.imageView.image = [UIImage imageWithData:self.details.imageData];
        
        if ([self.info.expenseType isEqualToString:@"Inflow"])
        {
            [self.expenseType setSelectedSegmentIndex:0];
        } else
        {
            [self.expenseType setSelectedSegmentIndex:1];
        }
        
        self.amountField.text = [NSString stringWithFormat:@"%.2f", [self.info.amount doubleValue]];
        self.payeeField.text = self.info.payee;
        
        NSUInteger categoryIdx = [categoryData indexOfObject:self.details.category];
        [self.categoryPicker selectRow:categoryIdx inComponent:0 animated:YES];

        NSUInteger paymentIdx = [paymentData indexOfObject:self.details.payment];
        [self.paymentPicker selectRow:paymentIdx inComponent:0 animated:YES];
        
        self.datePicker.date = self.info.date;
        
        self.navigationItem.title = @"Edit Receipt";
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
        if ([obj length] > 0 && [obj characterAtIndex:0] == '$')
        {
            return YES;
        }
        
        return NO;
    }];
    
    
    // If a valid amount was found, display it.
    // Otherwise, don't change the text field
    if (index != NSNotFound) {
        self.amountField.text = [wordArray[index] substringFromIndex:1];
    }
}

// Displays an error alert message with the message passed in as apology
-(void)apologize:(NSString *)apology
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Input" message:apology delegate:self cancelButtonTitle:@"Sorry" otherButtonTitles:nil];
    alert.tag = INVALID_ALERT;
    [alert show];
}

// Ensures that the submitted receipt is valid
-(BOOL)validateInput
{
    if ([self.amountField.text length] == 0 || [[self.amountField.text componentsSeparatedByString:@"."] count] > 2)
    {
        [self apologize:@"Invalid Amount"];
        return NO;
    } else if ([self.payeeField.text length] == 0)
    {
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

// Extracts information form user input fields and puts data into model
// Pops view back to previous controller
- (IBAction)done:(id)sender
{
    if ([self validateInput])
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        // editing an existing receipt
        if (self.info && self.details)
        {
            [self.info setValue:self.datePicker.date forKey:@"date"];
            [self.info setValue:[[NSNumber alloc] initWithDouble:[self.amountField.text doubleValue]] forKey:@"amount"];
            [self.info setValue:[self.expenseType titleForSegmentAtIndex:[self.expenseType selectedSegmentIndex]] forKey:@"expenseType"];
            [self.info setValue:self.payeeField.text forKey:@"payee"];
            
            [self.details setValue:[categoryData objectAtIndex:[self.categoryPicker selectedRowInComponent:0]] forKey:@"category"];
            [self.details setValue:[paymentData objectAtIndex:[self.paymentPicker selectedRowInComponent:0]] forKey:@"payment"];
            NSData* imageData = UIImagePNGRepresentation(self.imageView.image);
            [self.details setValue:imageData forKey:@"imageData"];
        }
        // creating a new one
        else {
            ReceiptInfo* info = [NSEntityDescription insertNewObjectForEntityForName:@"ReceiptInfo" inManagedObjectContext:context];
            [info setValue:self.datePicker.date forKey:@"date"];
            [info setValue:[[NSNumber alloc] initWithDouble:[self.amountField.text doubleValue]] forKey:@"amount"];
            [info setValue:[self.expenseType titleForSegmentAtIndex:[self.expenseType selectedSegmentIndex]] forKey:@"expenseType"];
            [info setValue:self.payeeField.text forKey:@"payee"];
            
            ReceiptDetails* details = [NSEntityDescription insertNewObjectForEntityForName:@"ReceiptDetails" inManagedObjectContext:context];
            [details setValue:[categoryData objectAtIndex:[self.categoryPicker selectedRowInComponent:0]] forKey:@"category"];
            [details setValue:[paymentData objectAtIndex:[self.paymentPicker selectedRowInComponent:0]]
               forKey:@"payment"];
            NSData* imageData = UIImagePNGRepresentation(self.imageView.image);
            [details setValue:imageData forKey:@"imageData"];
            
            [details setValue:info forKey:@"info"];
            [info setValue:details forKey:@"details"];
        }
        
        NSError *error = nil;
        if (![context save:&error]) {
            //NSLog(@"Can't update CoreData %@ %@", error, [error localizedDescription]);
            return;
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// Custom cancel behavior for when the user tries to go back.
// Makes sure that the user really wants to go back
- (IBAction)cancel:(id)sender
{
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

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract
{
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // If return is pressed on the payee field, have the autocomplete handle it
    if (textField.tag == PAYEE_FIELD)
    {
        [(AutocompleteTextField*)textField handleReturn];
    }
    
    // Hide the keyboard
    [textField resignFirstResponder];
    return YES;
}

// Implements the delete functionality for the autocomplete keyboard (this would normally
// be done by overwriting deleteBackwards in the text field class but the method is broken in iOS8,
// so this less elegant solution must be used.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == PAYEE_FIELD)
    {
        // checks to see if the change is a deletion
        if (range.length == 1  && string.length == 0)
        {
            // if the field is not autocompleted, delete a character
            if (!self.payeeField.autocompleted)
            {
                // keep track of the cursor position
                UITextPosition *cursor = [textField positionFromPosition:
                                          self.payeeField.beginningOfDocument offset:range.location];
                
                // delete a single character
                [self.payeeField uncomplete];
                NSString *oldText = [[NSString alloc] initWithString:self.payeeField.userString];
                self.payeeField.userString = [NSString stringWithFormat:@"%@%@",
                [oldText substringToIndex:range.location], [oldText substringFromIndex:range.location+1]];
                self.payeeField.text = self.payeeField.userString;
                
                // reset the cursor to it's previous position
                [self.payeeField setSelectedTextRange:[self.payeeField textRangeFromPosition:cursor toPosition:cursor]];
            }
            // if the field is autocompleted, delete should uncomplete the field
            else
            {
                [self.payeeField uncomplete];
            }
            
        return NO;
        }
    }
    
    // If it's not the autocomplete payee keyboard, don't interfere
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

#pragma mark - AutocompleteTextField Delegate

// Attempts to find a match for the payee text in the field in the core data model
- (NSString *)suggestionForString:(NSString *)inputString
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReceiptInfo"];
    
    // add wildcard character to allow for completion
    NSString *match = [NSString stringWithFormat:@"%@*", inputString];
    
    // case insensitive like match with wildcard for completion
    [request setPredicate:[NSPredicate predicateWithFormat:@"payee LIKE[cd] %@", match]];
    [request setFetchLimit:1];
    NSArray *data = [context executeFetchRequest:request error:nil];
    
    NSString *completedString = nil;
    
    // if a match is found
    if ([data count] != 0)
    {
        // extract the "completion" string, that is, the part of the string that
        // the user hasn't already entered
        completedString = [data[0] payee];
        completedString = [completedString substringFromIndex:self.payeeField.userString.length];
        
        // if the completion string is empty, that is the user has already entered
        // in the full text of the matching suggestion, there is nothing to suggest
        if ([completedString isEqualToString:@""]) {
            completedString = nil;
        }
        
        // automatically set the category picker to the category of the suggestion payee
        [self.categoryPicker selectRow:[categoryData indexOfObject:[[data[0] details]category]] inComponent:0 animated:YES];
    }

    // return to the text field the appropriate suggestion string
    return completedString;

}
@end
