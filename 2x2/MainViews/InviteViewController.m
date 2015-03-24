//
//  InviteViewController.m
//  2x2
//
//  Created by aDb on 3/11/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "InviteViewController.h"
#import "DBManager.h"
#import "Status.h"
#import "DataDownloader.h"

@interface InviteViewController ()
{
    Settings *st;
}
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
   
    
    

    
}

-(IBAction)continueButton:(id)sender
{
  
    
    if ([numberUiTextField.text isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"خطا"
                                                        message:@"لطفا شماره ی خود را وارد کنید"
                                                       delegate:self
                                              cancelButtonTitle:@"خب"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [activityView startAnimating];
        
        RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
            if (wasSuccessful) {
                
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                                message:@"انجام شد!"
                                                               delegate:self
                                                      cancelButtonTitle:@"خب"
                                                      otherButtonTitles:nil];
                [alert show];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [activityView stopAnimating];
                    [continueButton setEnabled:YES];
                });
            }
            
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                                message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                               delegate:self
                                                      cancelButtonTitle:@"خب"
                                                      otherButtonTitles:nil];
                [alert show];
                
                
                NSLog( @"Unable to fetch Data. Try again.");
            }
        };
        
          [continueButton setEnabled:NO];
        [self.getData Invite:st.settingId Password:st.password contactNumber:[NSString stringWithFormat:@"%@",numberUiTextField.text] withCallback:callback];
    
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //    [nameUiTextField resignFirstResponder];
    //    [familyCodeUiTextField resignFirstResponder];
    [self.view endEditing:YES];
    
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
