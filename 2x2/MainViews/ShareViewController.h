//
//  ShareViewController.h
//  2x2
//
//  Created by aDb on 3/3/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCNavigationController.h"

@interface ShareViewController : UIViewController
{
    IBOutlet UIImageView *imageToView;
    IBOutlet UIButton *shareButton;
    IBOutlet UITextView *descriptionTextView;
    IBOutlet UIView *containerView;
    IBOutlet UIProgressView *progressView;
 
}

-(IBAction) shareAction:(id)sender;
-(IBAction) backAction:(id)sender;
@property(nonatomic,strong) NSString *competetitionId;
@property(nonatomic,strong) UIImage *imageToSend;


@end
