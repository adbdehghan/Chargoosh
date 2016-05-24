//
//  HomeIcon.h
//  2x2
//
//  Created by aDb on 3/9/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeIcon : NSObject
@property (strong, nonatomic) NSMutableDictionary *dataDictionary;
@property (strong, nonatomic) NSString *iconId;
@property (strong, nonatomic) NSURL *iconURL;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSString *data;
@property (strong, nonatomic) UIImage *image;

@end
