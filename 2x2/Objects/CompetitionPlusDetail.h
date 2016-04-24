//
//  CopetitionPlusDetail.h
//  2x2
//
//  Created by aDb on 3/6/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompetitionPlusDetail : NSObject
@property(strong, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *competitionId;
@property (strong, nonatomic) NSString *score;
@property (strong, nonatomic) NSMutableDictionary *pollQuestions;
@property (strong, nonatomic) NSString *canParticipate;
@property (strong, nonatomic) NSString *endTime;
@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSString *whyCant;
@property (strong, nonatomic) NSString *exAnswer;

@end
