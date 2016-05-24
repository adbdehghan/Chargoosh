//
//  InboxViewController.h
//  2x2
//
//  Created by aDb on 2/24/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxViewController : UITableViewController
@property (strong, nonatomic)  NSMutableDictionary *messageDictionary;
@property (strong, nonatomic)  NSMutableArray *messageList;
@property (strong, nonatomic)  NSMutableArray *messageDateList;
@end
