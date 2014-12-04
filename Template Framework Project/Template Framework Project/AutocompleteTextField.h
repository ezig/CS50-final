//
//  AutocompleteTextField.h
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 12/2/14.
//
//

#import <UIKit/UIKit.h>

@class AutocompleteTextField;

@protocol AutocompleteTextFieldDelegate <UITextFieldDelegate>
@required
- (NSString *)suggestionForString:(NSString *)inputString;
@end

@interface AutocompleteTextField : UITextField

@property(nonatomic,assign) id delegate;
@property (nonatomic, retain) NSString *userString;
@property (nonatomic, retain) NSString *completionString;
@property (nonatomic, assign) BOOL autocompleted;

- (void)complete;
- (void)uncomplete;

@end
