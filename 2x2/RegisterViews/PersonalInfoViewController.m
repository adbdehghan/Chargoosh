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


@interface PersonalInfoViewController ()
@property (strong, nonatomic) DataDownloader *getData;
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
    if ([nameUiTextField.text length]>0 && [familyNameUiTextField.text length]>0) {
        
        doneButton.enabled = NO;
        
        RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
            if (wasSuccessful)
            {
                [self performSegueWithIdentifier:@"PersonalToMain" sender:self];
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"خطا"
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
        
        NSInteger selectedSegment = genderSegment.selectedSegmentIndex;
        NSString *gender = @"";
        if (selectedSegment == 0)
        {
            gender = @"مرد";
            
        }
        else
            gender = @"زن";
        
        
        [self.getData RegisterProfile:st.settingId Password:st.password Name:nameUiTextField.text LastName:familyNameUiTextField.text Gender:gender
         
                         withCallback:callback];
    }
    else
    {
        if (![nameUiTextField.text length]>0) {
            doneButton.enabled = YES;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"خطا"
                                                            message:@"لطفا نام خود را وارد نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            doneButton.enabled = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"خطا"
                                                            message:@"لطفا نام خانوادگی خود را وارد نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
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
