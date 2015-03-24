//
//  VerificationViewController.m
//  2x2
//
//  Created by aDb on 2/24/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "VerificationViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"

@interface VerificationViewController ()
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation VerificationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)continueButton:(id)sender
{
    continueButton.enabled = NO;
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            
            if ([data count]>0 && ![[data valueForKey:@"password"]isEqualToString:@":"]) {
                
                Settings *setting = [[Settings alloc]init];
                setting.settingId = self.phoneNumber;
                setting.password = [data valueForKey:@"password"];
                
                
                [DBManager createTable];
                [DBManager saveOrUpdataSetting:setting];
                
                
                [self performSegueWithIdentifier:@"Next" sender:self];
            }
            
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"خطا"
                                                                message:@"کد وارد شده اشتباه است!"
                                                               delegate:self
                                                      cancelButtonTitle:@"خب"
                                                      otherButtonTitles:nil];
                
                [alert show];
                continueButton.enabled = YES;
            }
            
            
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"خطا"
                                                            message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
            
            continueButton.enabled = YES;
            
            NSLog( @"Unable to fetch Data. Try again.");
        }
    };
    
    [self.getData GetVerificationCode:self.phoneNumber Param2:verificationCodeUiTextField.text
                         withCallback:callback];
    
    
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
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
