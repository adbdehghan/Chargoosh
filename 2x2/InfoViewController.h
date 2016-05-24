//
//  InfoViewController.h
//  2x2
//
//  Created by aDb on 4/20/16.
//  Copyright © 2016 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *buyButton;
@property (strong, nonatomic)  NSMutableDictionary *competitionDictionary;
@property (nonatomic)IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic)IBOutlet UILabel *score;
@property (nonatomic,retain)NSString *qrData;
@end
