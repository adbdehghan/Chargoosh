//
//  Status.h
//  2x2
//
//  Created by aDb on 3/10/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Status : NSObject
@property (strong, nonatomic) NSMutableDictionary *dataDictionary;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *summarize;
@property (strong, nonatomic) NSString *score;

@end
