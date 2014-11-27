//
//  ViewController.m
//  Budget Buddy
//
//  Last modified by Ezra on 11/23/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//

#import "AddReceiptViewController.h"
#define CAMERA_ALERT 1
#define CANCEL_ALERT 2
#define INVALID_ALERT 3

@interface AddReceiptViewController ()
{
    NSArray *_categoryData;
    NSArray *_paymentData;
}
@end

@implementation AddReceiptViewController

/****README****/
/*
 Tessdata folder is into the template project..
 TesseractOCR.framework is linked into the template project under the Framework group. It's builded by the main project.
 
 If you are using iOS7 or greater, import libstdc++.6.0.9.dylib (not libstdc++)!!!!!
 
 Follow the readme at https://github.com/gali8/Tesseract-OCR-iOS for first step.
 */



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.payeeField.delegate = self;
    self.amountField.delegate = self;
    self.paymentPicker.delegate = self;
    self.categoryPicker.delegate = self;
    
    // Set gesture recognize to dismiss keyboards
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    // Set data for pickers
    _paymentData = @[@"Cash", @"Credit", @"Debit", @"Check"];
    _categoryData = @[@"Entertainment", @"Pharmacy", @"Clothing", @"Bananas", @"Cats"];

    // Connect data to pickers
    self.paymentPicker.dataSource = self;
    self.categoryPicker.dataSource = self;
    
    // Overwrite the default back button behavior to implement custom cancel behavior
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = backButton;
}

// Custom cancel behavior for when the user tries to go back.
// Makes sure that the user really wants to go back
-(void)cancel
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning: Everything unsaved will be lost." message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok",nil];
    alert.tag = CANCEL_ALERT;
    [alert show];
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
    NSArray* wordArray = [text componentsSeparatedByCharactersInSet:
                          [NSCharacterSet characterSetWithCharactersInString:@" \n"]];
    
    NSUInteger index = [wordArray indexOfObjectWithOptions:NSEnumerationReverse passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj length] > 0 && [obj characterAtIndex:0] == '$') {
            return YES;
        }
        
        return NO;
    }];
    
    if (index != NSNotFound) {
        self.amountField.text = wordArray[index];
    }
}

-(void)apologize:(NSString *)apology
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Input" message:apology delegate:self cancelButtonTitle:@"Sorry" otherButtonTitles:nil];
    alert.tag = INVALID_ALERT;
    [alert show];
}

//TODO: MATT JIANG

-(BOOL)validateInput
{
    NSLog(@"%d", (int) self.amountField.text.length);
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

- (IBAction)addReceipt:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Choose Photo Source" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Camera",@"Photo Library",nil];
    alert.tag = CAMERA_ALERT;
    [alert show];
}

- (IBAction)done:(id)sender {
    if ([self validateInput]) {
         [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - TeseractDelegate

-(void)recognizeImageWithTesseract:(UIImage *)img
{
    Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    tesseract.delegate = self;

    [tesseract setVariableValue:@"$.,0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" forKey:@"tessedit_char_whitelist"]; //limit search
    
    // this line produces a weird error and I don't know why
    [tesseract setImage:[img blackAndWhite]]; //image to check
    [tesseract recognize];
    
    [self parseText:[tesseract recognizedText]];
    
    tesseract = nil; //deallocate and free all memory
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract
{
    //NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.imageView.image = img;

    [self.activityView startAnimating];
    [self.view setUserInteractionEnabled:NO];
    
    UIView *grayView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    grayView.backgroundColor = [UIColor blackColor];
    grayView.alpha = 0.5;
    
    [[UIApplication sharedApplication].keyWindow addSubview:grayView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the UI
        [self recognizeImageWithTesseract:img];
        [self.activityView stopAnimating];
        [grayView removeFromSuperview];
        [self.view setUserInteractionEnabled:YES];
    });
}

#pragma mark - UIAlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CAMERA_ALERT) {
        if (buttonIndex == 1) {
            [self takePhoto];
        } else if (buttonIndex == 2) {
            [self choosePhoto];
        }
    } else if (alertView.tag == CANCEL_ALERT) {
        if (buttonIndex == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIPickerViewDataSource Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.categoryPicker])
    {
        return _categoryData.count;
    }
    
    return _paymentData.count;
}

#pragma mark - UIPickerView Delegate

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.categoryPicker])
    {
        return _categoryData[row];
    }
    
    return _paymentData[row];
}
@end
