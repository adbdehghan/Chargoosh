//
//  MyStatusViewController.h
//  2x2
//
//  Created by aDb on 2/24/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyStatusViewController : UIViewController
{
    IBOutlet UIView *chartContainer;
    IBOutlet UILabel *name;
    IBOutlet UIButton *coinImage;
    IBOutlet UIImageView *profileImage;
    IBOutlet UIActivityIndicatorView *activityView;
}
@property (strong, nonatomic)  NSMutableDictionary *statusDictionary;
@end
