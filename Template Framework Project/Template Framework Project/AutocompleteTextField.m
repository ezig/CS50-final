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

- (void)deleteBackward
{
    [self uncomplete];
    self.userString = [self.userString substringToIndex:[self.userString length] - 1];
    [super deleteBackward];
}


- (void)complete
{
    [self uncomplete];
    NSString *endString = [self.delegate suggestionForString:self.text];
    if (endString != nil)
    {
        UIColor *hightlightColor = [UIColor colorWithRed:0.8f green:0.87f blue:0.93f alpha:1.f];
        NSRange highlightRange = NSMakeRange(self.text.length, endString.length - self.userString.length);
        NSMutableAttributedString *completion = [[NSMutableAttributedString alloc] initWithString:endString];
        [completion addAttribute:NSBackgroundColorAttributeName value:hightlightColor range:highlightRange];
        self.attributedText = completion;
    }
}

- (void)uncomplete
{
    self.text = self.userString;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



@end
