//
//  EnterNumberViewController.h
//  2x2
//
//  Created by aDb on 2/24/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerificationViewController.h"

@interface EnterNumberViewController : UIViewController
{
    IBOutlet UITextField *numberUiTextField;
    IBOutlet UIButton *continueButton;
    IBOutlet UIActivityIndicatorView *activityView;
    IBOutlet UIImageView *imageView;
}
-(IBAction)continueButton:(id)sender;

@end
