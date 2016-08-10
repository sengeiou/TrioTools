//
//  KeyboardBar.m
//  KeyboardInputView
//
//  Created by Brian Mancini on 10/4/14.
//  Copyright (c) 2014 iOSExamples. All rights reserved.
//

#import "KeyboardBar.h"

@implementation KeyboardBar

@synthesize maxLen;

- (id)initWithDelegate:(id<KeyboardBarDelegate>)delegate {
    self = [self init];
    self.delegate = delegate;
    return self;
}

- (id)init {
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0,0, CGRectGetWidth(screen), 80);
    self = [self initWithFrame:frame];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if(self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.75f alpha:1.0f];
        
        //self.textView = [[UITextView alloc]initWithFrame:CGRectMake(5, 5, frame.size.width - 70, frame.size.height - 10)];
        //self.textView.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
        self.labelFieldCaption = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, frame.size.width - 95, frame.size.height/2)];
        self.labelFieldCaption.textColor = [UIColor blueColor];
        self.labelFieldCaption.text = @"Test";
        self.labelFieldCaption.tag = 100;
        [self addSubview:self.labelFieldCaption];
        
        self.textField = [[UITextField alloc]initWithFrame:CGRectMake(5, 35, frame.size.width - 95, frame.size.height/2)];
        self.textField.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
        self.textField.layer.borderWidth = 2.0f;
        self.textField.layer.borderColor = [UIColor blackColor].CGColor;
        self.textField.layer.cornerRadius = 3.0f;
        self.textField.tag = 200;
        self.textField.delegate = self;
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        [self addSubview:self.textField];
        
        self.actionButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 85, 10, 80, frame.size.height - 15)];
        self.actionButton.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
        self.actionButton.layer.cornerRadius = 3.0;
        self.actionButton.layer.borderWidth = 2.0;
        self.textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.actionButton.layer.borderColor = [[UIColor colorWithWhite:0.45 alpha:1.0f] CGColor];
        [self.actionButton setTitle:@"DONE" forState:UIControlStateNormal];
        [self.actionButton addTarget:self action:@selector(didTouchAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.actionButton];
        
    }
    return self;
}

- (void) didTouchAction
{
    [self.delegate keyboardBar:self sendText:self.textField.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    long long maxValue = [self getMaxValue:self.maxLen];
    NSString *newValue = [NSString stringWithFormat:@"%@%@",textField.text,string];
    if([string length] == 0)
    {
        NSLog(@"backspace");
    }
    else if([newValue longLongValue] > maxValue)
    {
        return NO;
    }
    else if ([textField.text length] >= self.maxLen && ![string isEqualToString:@""] )
    {
        textField.text = [textField.text substringToIndex:self.maxLen];
        return NO;
    }

    
    return YES;

}


-(long long)getMaxValue:(int)len
{
    long long maxValue = 255;
    switch (len)
    {
        case 2:
            maxValue = 15;
            break;
        case 4:
            maxValue = 31;
            break;
        case 5:
            maxValue = 65535;
            break;
        case 7:
            maxValue = 127;
            break;
        case 8:
            maxValue = 16777215;
            break;
        case 10:
            maxValue = 9999999999;
            break;
        default:
            maxValue = maxValue;
            break;
    }
    
    return maxValue;
}


@end
