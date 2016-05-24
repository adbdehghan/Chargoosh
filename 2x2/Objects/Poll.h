//
//  PollQuestion.h
//  2x2
//
//  Created by aDb on 3/6/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Poll : NSObject

@property (strong, nonatomic) NSMutableDictionary *dataDictionary;
@property (strong, nonatomic) NSString *question;
@property (strong, nonatomic) NSArray *pollAnswers;
@property (strong, nonatomic) NSString *questionId;
@property (strong, nonatomic) NSString *yourAns;
@property (strong, nonatomic) NSString *exAnswer;
@property (strong, nonatomic) NSString *answerTemplate;


@end
