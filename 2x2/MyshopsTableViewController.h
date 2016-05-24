//
//  MyshopsTableViewController.h
//  2x2
//
//  Created by aDb on 4/19/16.
//  Copyright © 2016 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyshopsTableViewController : UITableViewController
@property (strong, nonatomic)  NSMutableDictionary *competitionDictionary;
@property (strong, nonatomic)  NSMutableArray *competitionList;
@property (strong ,nonatomic) NSMutableDictionary *cachedImages;
@property (nonatomic,retain)NSString *organizationID;
@end
