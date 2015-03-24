//
//  GWQuestionnaire.h
//
//  Created by Grzegorz Wójcik on 07.03.2014.
//
//
#import <UIKit/UIKit.h>
#import "GWQuestionnaireItem.h"
@interface GWQuestionnaire : UITableViewController
// contains GWQuestionnaireItem (questions with answers)
@property (nonatomic, strong) NSMutableArray *surveyItems;

- (id)initWithItems:(NSMutableArray*)items;
-(BOOL)isCompleted;
@end
// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net