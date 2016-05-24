//
//  CompetitionPlusDetailViewController.h
//  2x2
//
//  Created by aDb on 3/5/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompetitionPlusDetailViewController : UIViewController
@property(nonatomic,strong) NSString *competitionTitle;
@property(nonatomic,strong) NSString *competitionId;
@property(nonatomic,strong)  NSMutableDictionary *competitionDictionary;
@property (strong, nonatomic) IBOutlet UILabel *whyCantLabel;
@property (strong, nonatomic) IBOutlet UIView *whyCantView;
@property (strong, nonatomic) NSString *exAnswer;
@end
