//
//  PollAnswers.h
//  2x2
//
//  Created by aDb on 3/7/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PollAnswers : NSObject
{
    NSString *questionId_;
    NSString *answer_;
}
@property (strong, nonatomic) NSString *questionId;
@property (strong, nonatomic) NSString *answer;


-(NSDictionary *)dictionary;

@end
