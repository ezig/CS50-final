//
//  AutocompleteTextField.m
//  BudgetBuddy
//
//  Created by Ezra Zigmond on 12/2/14.
//
//

#import "AutocompleteTextField.h"

@interface AutocompleteTextField ()
{
    
}
@end

@implementation AutocompleteTextField

// Overwrites how text insertion is handled. Whenever text is inserted, first remove
// the autocompletion, then insert the character, then update userString which keeps
// track of what text the user has actually entered, and then attempt to complete
// the string again with the new user text
- (void)insertText:(NSString *)text
{
    [self uncomplete];
    
    [super insertText:text];
    self.userString = self.text;
    
    [self complete];
}

// If the string is autocompleted and the user pressed enter, fill the text with
// the autocompleted text.
- (void)handleReturn
{
    if(self.autocompleted) {
        // overwrite self attributed text with self text to eliminate the highlighting
        self.attributedText = [[NSAttributedString alloc] initWithString:self.text];
        self.userString = [self.attributedText string];
        self.autocompleted = NO;
    }
}

// Ask the delegate for a suggestion for the autocompletion and, if there is a suggestion,
// show it as highlighted text in the field
- (void)complete
{
    // ask delegate for a suggestion for the current user input
    NSString *endString = [self.delegate suggestionForString:self.userString];

    // if there's a suggestion, use it to fill in the field
    if (endString != nil)
    {
        self.autocompleted = YES;
        
        // set up the highlight color and highlight the suggestion string so
        // that it is clearly distinct from the user input text
        UIColor *hightlightColor = [UIColor colorWithRed:0.702 green:0.847 blue:0.992 alpha:1];
        NSRange highlightRange = NSMakeRange(self.userString.length, endString.length);
        NSMutableAttributedString *completion = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", self.userString, endString]];
        [completion addAttribute:NSBackgroundColorAttributeName value:hightlightColor range:highlightRange];
        self.attributedText = completion;
    } else
    {
        self.autocompleted = NO;
    }
}

// Remove the completion selection from the field
- (void)uncomplete
{
    self.attributedText = [[NSAttributedString alloc] initWithString:@""];
    self.text = self.userString;
    self.autocompleted = NO;
}

// If there is currently an autocomplete suggestion, do not display a caret cursor
- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    if (self.autocompleted)
    {
       return CGRectZero;
    }
    return [super caretRectForPosition:position];
}

//Prevent the user from using cut, copy, and paste because they behave badly with
// the autocomplete functionality
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    [UIMenuController sharedMenuController].menuVisible = NO;
    return NO;
}


@end
