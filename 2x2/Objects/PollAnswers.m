//
//  PollAnswers.m
//  2x2
//
//  Created by aDb on 3/7/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "PollAnswers.h"

@implementation PollAnswers
@synthesize questionId = questionId_;
@synthesize answer = answer_;

-(NSDictionary *)dictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:self.questionId,@"questionId",self.answer,@"answer", nil];
}
@end
