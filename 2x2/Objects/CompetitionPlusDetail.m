//
//  CopetitionPlusDetail.m
//  2x2
//
//  Created by aDb on 3/6/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "CompetitionPlusDetail.h"

@implementation CompetitionPlusDetail

-(id)init
{
    self = [super init];
    if (self)
    {
        // superclass successfully initialized, further
        _competitionId =[self.data valueForKey:@"id"];
        _name = [self.data valueForKey:@"name"];
        _score = [self.data valueForKey:@"score"];
        _pollQuestions = [self.data valueForKey:@"pollQuestions"];
        
    }
    return self;

}

@end
