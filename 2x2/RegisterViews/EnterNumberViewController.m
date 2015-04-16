//
//  EnterNumberViewController.m
//  2x2
//
//  Created by aDb on 2/24/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "EnterNumberViewController.h"
#import "DataDownloader.h"
#import "UIImage+ImageEffects.h"


@interface EnterNumberViewController ()
@property (strong, nonatomic) DataDownloader *getData;
@property (strong, nonatomic)  UIImageView        *blurredOverlayView;
@end

@implementation EnterNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    //self.blurredOverlayView = [[UIImageView alloc]init];
    //[self setBlurredOverlayImage:[UIImage imageNamed:@"iranFlag.png"]];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    
    
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

-(IBAction)continueButton:(id)sender
{
    
    if ([numberUiTextField.text length]!=10 && ![numberUiTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"خطا"
                                                        message:@"شماره ی وارد شده اشتباه است!"
                                                       delegate:self
                                              cancelButtonTitle:@"خب"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    if ([numberUiTextField.text isEqualToString:@""]) {
        
     
    
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"خطا"
                                                        message:@"لطفا شماره ی خود را وارد کنید"
                                                       delegate:self
                                              cancelButtonTitle:@"خب"
                                              otherButtonTitles:nil];
        [alert show];
    
    }
    else if([numberUiTextField.text length]==10 )
    {
        
        continueButton.enabled = NO;
        
        [activityView startAnimating];
        
        RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
            if (wasSuccessful) {
                
                [activityView stopAnimating];
                [self performSegueWithIdentifier:@"Next" sender:self];
                
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
        
        [self.getData requestVerificationCode:numberUiTextField.text
                                 withCallback:callback];
        
        
    }
}


- (void)setBlurredOverlayImage:(UIImage*)image
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        
        
        //  Blur the screen shot
        UIImage *blurred = [image applyBlurWithRadius:20
                                            tintColor:[UIColor colorWithWhite:0.15 alpha:0.5]
                                saturationDeltaFactor:1.5
                                            maskImage:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            //  Set the blurred overlay view's image with the blurred screenshot
            self.blurredOverlayView.image = blurred;
            imageView.image = self.blurredOverlayView.image;
        });
    });
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqual:@"Next"]) {
        VerificationViewController *detination = [segue destinationViewController];
        detination.phoneNumber = numberUiTextField.text;
    }
    
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
