//
//  competitionListTableViewController.h
//  2x2
//
//  Created by aDb on 3/4/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString *CollectionViewCellIdentifier = @"iconCell";
@interface competitionListTableViewController : UICollectionViewController
@property (strong, nonatomic)  NSMutableDictionary *competitionDictionary;
@property (strong, nonatomic)  NSMutableArray *competitionList;
@property (strong ,nonatomic) NSMutableDictionary *cachedImages;
@property (nonatomic,retain)NSString *organizationID;
@end
