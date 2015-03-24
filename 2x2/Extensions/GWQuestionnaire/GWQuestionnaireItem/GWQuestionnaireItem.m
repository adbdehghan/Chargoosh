//
//  GWQuestionnaireItem.m
//
//  Created by Grzegorz Wójcik on 07.03.2014.
//
//

#import "GWQuestionnaireItem.h"

@implementation GWQuestionnaireItem
-(id)initWithQuestion:(NSString*)question answers:(NSArray*)answers type:(GWQuestionnaireItemType)type questionId:(NSString*)questionId
{
    self = [super init];
    if (self) {
        [self setQuestion:question];
        [self setAnswers:answers];
        [self setType:type];
        [self setQuestionId:questionId];
    }
    return self;
}

-(void)dealloc
{
    self.question = nil;
    self.answers = nil;
    self.userAnswer = nil;
}
@end
// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net