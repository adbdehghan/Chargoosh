//
//  PaymentViewController.h
//  2x2
//
//  Created by aDb on 4/21/16.
//  Copyright © 2016 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMaskTextField.h"
@interface PaymentViewController : UIViewController
{
    IBOutlet UITextField *costUiTextField;
    IBOutlet UITextField *descriptionUiTextField;
    IBOutlet UIButton *doneButton;
}
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic)  NSMutableDictionary *competitionDictionary;
@property (strong, nonatomic) UIImage *backgroundImage;
@end
