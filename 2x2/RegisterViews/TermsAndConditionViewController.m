//
//  TermsAndConditionViewController.m
//  2x2
//
//  Created by aDb on 3/8/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "TermsAndConditionViewController.h"

@interface TermsAndConditionViewController ()

@end

@implementation TermsAndConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width-20, self.view.bounds.size.height)];

    [textView setFont:[UIFont fontWithName:@"B Yekan+" size:19]];
    
    [textView setEditable:NO];
    [textView setSelectable:NO];
    //[item sizeToFit];
    [textView layoutIfNeeded];
    [textView setText:[NSString stringWithContentsOfFile:@"terms.txt" encoding:NSUTF8StringEncoding error:nil]];
    UITextPosition *beginning = textView.beginningOfDocument;
    UITextPosition *start = [textView positionFromPosition:beginning offset:0];
    UITextPosition *end = [textView positionFromPosition:start offset:[textView.text length]];
    
    UITextRange *textRange = [textView textRangeFromPosition:start toPosition:end];
    [textView setBaseWritingDirection:UITextWritingDirectionRightToLeft forRange:textRange];
    
    
    textView.textAlignment = NSTextAlignmentJustified;
    
    
    
//    [textView setBaseWritingDirection:UITextWritingDirectionRightToLeft forRange:[textView textRangeFromPosition:[textView beginningOfDocument] toPosition:[textView endOfDocument]]];
    
//    [textView setTextAlignment:NSTextAlignmentJustified];
  
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
