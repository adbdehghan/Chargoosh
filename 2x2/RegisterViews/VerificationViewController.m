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
#import <QuartzCore/QuartzCore.h>

@interface VerificationViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation CALayer (Additions)

- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

@end

@implementation VerificationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.verificationCodeUiTextField.mask = @"####";
    self.verificationCodeUiTextField.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    VMaskTextField * maskTextField = (VMaskTextField*) textField;
    return  [maskTextField shouldChangeCharactersInRange:range replacementString:string];
}
-(IBAction)continueButton:(id)sender
{
    continueButton.enabled = NO;
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data2) {
        if (wasSuccessful) {
            
            
            if ([data2 count]>0 && ![[data2 valueForKey:@"password"]isEqualToString:@":"]) {
                
              
                
                
                
                RequestCompleteBlock callback2 = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
                    if (wasSuccessful) {
                        
                        Settings *setting = [[Settings alloc]init];
                        setting.settingId = self.phoneNumber;
                        setting.password = [data2 valueForKey:@"password"];
                        setting.accesstoken = [data valueForKey:@"accesstoken"];
                        
                        [DBManager createTable];
                        [DBManager saveOrUpdataSetting:setting];
                        
                        [self performSegueWithIdentifier:@"Next" sender:self];
                        
                    }};
                
                
                
                [self.getData GetToken:self.phoneNumber password:[data2 valueForKey:@"password"] withCallback:callback2];
                
                
                

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
    
    [self.getData GetVerificationCode:self.phoneNumber Param2:self.verificationCodeUiTextField.text
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
