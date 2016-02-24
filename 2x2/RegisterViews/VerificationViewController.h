//
//  VerificationViewController.h
//  2x2
//
//  Created by aDb on 2/24/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMaskTextField.h"

@interface VerificationViewController : UIViewController
{
        IBOutlet UIButton *continueButton;
}
@property (weak,nonatomic) IBOutlet VMaskTextField * verificationCodeUiTextField;
@property (strong, nonatomic)  NSString *phoneNumber;
-(IBAction)continueButton:(id)sender;
@end
