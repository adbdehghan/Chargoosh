//
//  PersonalInfoViewController.h
//  2x2
//
//  Created by aDb on 2/24/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalInfoViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITextField *nameUiTextField;
    IBOutlet UITextField *familyNameUiTextField;
    IBOutlet UISegmentedControl *genderSegment;
    IBOutlet UIButton *doneButton;
}
-(IBAction)Done:(id)sender;
@end
