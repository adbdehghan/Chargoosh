//
//  PaymentViewController.m
//  2x2
//
//  Created by aDb on 4/21/16.
//  Copyright © 2016 aDb. All rights reserved.
//

#import "PaymentViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "UIImage+Blur.h"
#import "Competition.h"
#import "PaymentViewController.h"
#import "DXAlertView.h"
#define URLaddressFav "http://www.newapp.chargoosh.ir/"
#import <QuartzCore/QuartzCore.h>

@implementation CALayer (Additions)

- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

@end

@interface PaymentViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    
    UIActivityIndicatorView *activityIndicator;
    Settings *st ;
    UIImage *blurredImage;
    NSNumberFormatter* numberFormatter;
    
}
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the previous view controller
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
    
    
    // Associate the barButtonItem to the previous view
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
    
    numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumSignificantDigits:12];
    
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=@"ثبت خرید";
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font = [UIFont fontWithName:@"B Yekan+" size:17];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView=label;
    
    
    
    self.backgroundImageView.image = self.backgroundImage;
}



- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -130; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}
- (IBAction)DoShop:(id)sender {
    
    DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"🤔" contentText:@"آیا مایلید از امتیاز برای خرید استفاده کنید؟" leftButtonTitle:@"خیر" rightButtonTitle:@"بله"];
    [alert show];
    alert.leftBlock = ^() {
        NSLog(@"left button clicked");
        
        if ([costUiTextField.text length] > 0) {
        
            [self DoShopping:@"false"];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                            message:@"لطفا قیمت را وارد نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
        
        }
    };
    alert.rightBlock = ^() {
        NSLog(@"right button clicked");
        
        if ([costUiTextField.text length] > 0) {
            
            [self DoShopping:@"true"];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                            message:@"لطفا قیمت را وارد نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
   

    };
    alert.dismissBlock = ^() {
        NSLog(@"Do something interesting after dismiss block");

    };
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }

}


-(void)DoShopping:(NSString *)isScore
{
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.competitionDictionary = data;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"🤔"
                                                            message:(NSString*)data
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            alert.tag = 1;
            
            [alert show];
            
        }
        
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"👻"
                                                            message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
            
            
            NSLog( @"Unable to fetch Data. Try again.");
        }
    };
    
    st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
        
    [self.getData Doshopping:st.accesstoken Number:st.settingId Detail:descriptionUiTextField.text ReduceScore:isScore Price:costUiTextField.text withCallback:callback];



}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //    [nameUiTextField resignFirstResponder];
    //    [familyCodeUiTextField resignFirstResponder];
    [self.view endEditing:YES];
    
}

@end
