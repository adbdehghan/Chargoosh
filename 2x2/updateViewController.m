//
//  updateViewController.m
//  2x2
//
//  Created by aDb on 4/22/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "updateViewController.h"

@interface updateViewController ()

@end

@implementation updateViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    
}

-(void)viewDidAppear:(BOOL)animated
{

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"👻"
                                                    message:@"لطفا برنامه را بروزرسانی کنید"
                                                   delegate:self
                                          cancelButtonTitle:@"بروزرسانی"
                                          otherButtonTitles:nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger) buttonIndex{
    
    if (buttonIndex == 1) {
        // Do it!
    } else {
        NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@",@"976614270"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
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
