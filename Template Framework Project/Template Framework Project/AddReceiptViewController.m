//
//  ViewController.m
//  Budget Buddy
//
//  Last modified by Ezra on 11/23/14
//  Copyright (c) 2014 Ezra Zigmond. All rights reserved.
//

#import "AddReceiptViewController.h"

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
    
    self.vendorField.delegate = self;
    self.amountField.delegate = self;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    _paymentData = @[@"Cash", @"Credit", @"Debit", @"Check"];
    _categoryData = @[@"Entertainment", @"Pharmacy", @"Clothing", @"Bananas", @"Cats"];
    
    // Connect data
    self.paymentPicker.dataSource = self;
    self.paymentPicker.delegate = self;
    self.categoryPicker.dataSource = self;
    self.categoryPicker.delegate = self;
    
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    [self addReceipt:nil];
}

-(void)cancel {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Everything will be lost" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok",nil];
    alert.tag = 2;
    [alert show];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(void)recognizeImageWithTesseract:(UIImage *)img
{
    Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    tesseract.delegate = self;

    [tesseract setVariableValue:@"$.,0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" forKey:@"tessedit_char_whitelist"]; //limit search
    
    [tesseract setImage:[img blackAndWhite]]; //image to check
    //[tesseract setRect:CGRectMake(20, 20, 100, 100)]; //optional: set the rectangle to recognize text in the image
    [tesseract recognize];
    
    [self parseText:[tesseract recognizedText]];
    
    tesseract = nil; //deallocate and free all memory
}

-(void)parseText:(NSString *)text
{
    NSArray* wordArray = [text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n"]];
    NSUInteger index = [wordArray indexOfObjectWithOptions:NSEnumerationReverse passingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj length] > 0 && [obj rangeOfString:@"$"].location != NSNotFound) {
            return YES;
        }
        return NO;
    }];
    
    NSLog(@"%@",text);
    if (index != NSNotFound) {
        self.amountField.text = wordArray[index];
    }
    [self.activityView stopAnimating];
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract {
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
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the UI
        [self recognizeImageWithTesseract:img];
    });
}

- (void)addReceipt {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Choose Photo Source" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Camera",@"Photo Library",nil];
    alert.tag = 1;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            [self takePhoto];
        } else if (buttonIndex == 2) {
            [self choosePhoto];
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

}

- (void)takePhoto {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)choosePhoto {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)addReceipt:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Choose Photo Source" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Camera",@"Photo Library",nil];
    [alert show];
}

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

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.categoryPicker])
    {
        return _categoryData[row];
    }
    
    return _paymentData[row];
}

@end
