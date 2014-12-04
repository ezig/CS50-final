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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        //hightlightColor = [UIColor colorWithRed:0.8f green:0.87f blue:0.93f alpha:1.f];
    }
    
    return self;
}

- (void)insertText:(NSString *)text
{
    [self uncomplete];
    
    [super insertText:text];
    self.userString = self.text;
    
    [self complete];
}


- (void)complete
{
    NSString *endString = [self.delegate suggestionForString:self.userString];

    if (endString != nil)
    {
        self.autocompleted = YES;
        UIColor *hightlightColor = [UIColor colorWithRed:0.8f green:0.87f blue:0.93f alpha:1.f];
        NSRange highlightRange = NSMakeRange(self.userString.length, endString.length);
        NSMutableAttributedString *completion = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", self.userString, endString]];
        [completion addAttribute:NSBackgroundColorAttributeName value:hightlightColor range:highlightRange];
        self.attributedText = completion;
    } else {
        self.autocompleted = NO;
    }
}

- (void)uncomplete
{
    self.attributedText = [[NSAttributedString alloc] initWithString:@""];
    self.text = self.userString;
    self.autocompleted = NO;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    return [super caretRectForPosition:position];
}

//http://stackoverflow.com/questions/1426731/how-disable-copy-cut-select-select-all-in-uitextview
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    [UIMenuController sharedMenuController].menuVisible = NO;
    return NO;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
