//
//  GWQuestionnaireItem.h
//
//  Created by Grzegorz Wójcik on 07.03.2014.
//
//

#import <Foundation/Foundation.h>

typedef enum {
	GWQuestionnaireSingleChoice,
	GWQuestionnaireMultipleChoice,
	GWQuestionnaireOpenQuestion,
	GWQuestionnaireRateQuestion,
} GWQuestionnaireItemType;

@interface GWQuestionnaireItem : NSObject

@property (nonatomic, strong) NSString *questionId;
// Question text
@property (nonatomic, strong) NSString *question;

// Possible choices 
@property (nonatomic, strong) NSArray *answers;
// Open answer text
@property (nonatomic, strong) NSString *userAnswer;


@property (assign) GWQuestionnaireItemType type;

-(id)initWithQuestion:(NSString*)question answers:(NSArray*)answers type:(GWQuestionnaireItemType)type questionId:(NSString*)questionId;
@end
// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net