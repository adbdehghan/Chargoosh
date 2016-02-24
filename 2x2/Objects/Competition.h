//
//  Competition.h
//  2x2
//
//  Created by aDb on 3/5/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Competition : NSObject
{
}

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *competitionId;
@property (strong, nonatomic) NSString *score;
@property (strong, nonatomic) NSString *scorePerPic;
@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSString *endTime;
@property (strong, nonatomic) NSString *limit;
@property (strong, nonatomic) NSString *userParticipationCount;
@property (strong, nonatomic) NSURL *competitionUrl;
@property (strong, nonatomic) UIImage *image;

@end
