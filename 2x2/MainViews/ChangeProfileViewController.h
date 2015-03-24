//
//  ChangeProfileViewController.h
//  2x2
//
//  Created by aDb on 3/11/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChangeProfileViewController : UIViewController
{
    IBOutlet UITextField *birthdayTextField;
    IBOutlet UITextField  *nameTextField;
    IBOutlet UITextField  *lastNameTextField;
    IBOutlet UISegmentedControl  *genderSegment;
    IBOutlet UIButton *applyChangeButton;
    IBOutlet UIActivityIndicatorView *activityView;
}

@property(weak,nonatomic) IBOutlet UITextField  *provinceTextField;
@property(weak,nonatomic) IBOutlet UITextField  *cityTextField;
@property(weak,nonatomic) IBOutlet UIActivityIndicatorView *provinceActivity;
@property(weak,nonatomic) IBOutlet UIActivityIndicatorView *cityActivity;

-(IBAction)ApplyChanges:(id)sender;
@end
