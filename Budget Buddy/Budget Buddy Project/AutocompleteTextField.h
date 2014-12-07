//
//  AutocompleteTextField.h
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 12/2/14.
//
//  Custom built autocompleting text field based on standard text field.
//  Must have a delegate that implements the suggestionForString method
//  in order for the autocompletetext field to know what to try to autocomplete with
//
//  Unfortunately, because Apple messed with the way that deletion from text fields works
//  in the iOS8 update, the delegate must also implement changedCharactersinRange to handle
//  how the deletion works in the text field because the convenient deleteBackward function
//  call on text fields is no longer used, so the deletion cannot be handled easily
//  by the custom text field without violating the private API guidelines
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
- (void)handleReturn;

@end
