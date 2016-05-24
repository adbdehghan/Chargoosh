//
//  PersonalInfoViewController.m
//  2x2
//
//  Created by aDb on 2/24/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import <QuartzCore/QuartzCore.h>

@interface PersonalInfoViewController ()
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation CALayer (Additions)

- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

@end

@implementation PersonalInfoViewController
CGFloat animatedDistance;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

-(IBAction)Done:(id)sender
{
        doneButton.enabled = NO;
        
        RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
            if (wasSuccessful)
            {
                [self performSegueWithIdentifier:@"PersonalToMain" sender:self];
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                               delegate:self
                                                      cancelButtonTitle:@"خب"
                                                      otherButtonTitles:nil];
                [alert show];
                
                doneButton.enabled = YES;
                
                NSLog( @"Unable to fetch Data. Try again.");
            }
        };
        
        Settings *st = [[Settings alloc]init];
        
        st = [DBManager selectSetting][0];
        
        [self.getData RegisterProfile:st.accesstoken  Name:nameUiTextField.text LastName:familyNameUiTextField.text  withCallback:callback];

    
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
