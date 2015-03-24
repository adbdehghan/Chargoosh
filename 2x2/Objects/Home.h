//
//  Home.h
//  2x2
//
//  Created by aDb on 3/9/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Home : NSObject
@property (strong, nonatomic) NSMutableDictionary *dataDictionary;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) NSString *weekDay;
@property (strong, nonatomic) NSMutableArray *icon;
@property (strong, nonatomic) NSMutableArray *homeIconList;

@end
