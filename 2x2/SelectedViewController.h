//
//  SecondViewController.h
//  2x2
//
//  Created by aDb on 2/23/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectedViewController : UITableViewController

@property (strong, nonatomic)  NSMutableDictionary *competitionDictionary;
@property (strong, nonatomic)  NSMutableArray *topParticipateList;
@property (strong ,nonatomic) NSMutableDictionary *cachedImages;
@property (strong, nonatomic)  NSString *competitionId;

@end

