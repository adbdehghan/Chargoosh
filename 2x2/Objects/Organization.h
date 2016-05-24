//
//  Organization.h
//  2x2
//
//  Created by aDb on 2/27/16.
//  Copyright © 2016 aDb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Organization : NSObject
@property (strong, nonatomic) NSMutableDictionary *dataDictionary;
@property (strong, nonatomic) NSString *iconId;
@property (strong, nonatomic) NSURL *iconURL;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *mine;

@end
