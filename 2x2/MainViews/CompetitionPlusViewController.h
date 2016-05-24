//
//  CompetitionPlusViewController.h
//  2x2
//
//  Created by aDb on 2/24/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompetitionPlusViewController : UITableViewController
@property (strong, nonatomic)  NSMutableDictionary *competitionPlusDictionary;
@property (strong, nonatomic)  NSMutableArray *competitionPlusList;
@property (nonatomic,retain)NSString *organizationID;
@end
