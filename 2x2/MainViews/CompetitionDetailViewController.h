//
//  CompetitionDetailViewController.h
//  2x2
//
//  Created by aDb on 3/1/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCNavigationController.h"

@interface CompetitionDetailViewController : UIViewController<SCNavigationControllerDelegate>

@property (strong, nonatomic)  NSMutableDictionary *competitionDictionary;
@property(nonatomic,strong) NSString *content;
@property(nonatomic,strong) UIImage *coverImage;
@property(nonatomic,strong) NSString *competitionTitle;
@property(nonatomic,strong) NSString *competitionId;
@property(nonatomic) BOOL canParticipate;
@property(nonatomic) BOOL timeLimitParticipate;
@end
