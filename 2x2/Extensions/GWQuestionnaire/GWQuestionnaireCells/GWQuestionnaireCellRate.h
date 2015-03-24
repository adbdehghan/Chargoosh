//
//  GWQuestionnaireCellRate.h
//
//  Created by Grzegorz Wójcik on 10.03.2014.
//
//

#import <UIKit/UIKit.h>
#import "GWQuestionnaireItem.h"
#import "GWQuestionnaire.h"
@interface GWQuestionnaireCellRate : UITableViewCell
@property (nonatomic, weak) IBOutlet UIView *container;

-(void)setContent:(GWQuestionnaireItem*)item row:(int)r parentWidth:(int)width;
-(void)setOwner:(GWQuestionnaire*)val;
@end
// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net