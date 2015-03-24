//
//  PollQuestion.m
//  2x2
//
//  Created by aDb on 3/6/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "Poll.h"

@implementation Poll
-(id)init
{
    self = [super init];
    if (self)
    {
        // superclass successfully initialized, further
        _questionId =[self.dataDictionary valueForKey:@"id"];
        _pollAnswers = [self.dataDictionary valueForKey:@"answerTemplate"];
        _question = [self.dataDictionary valueForKey:@"question"];
        
    }
    return self;
    
}
@end
