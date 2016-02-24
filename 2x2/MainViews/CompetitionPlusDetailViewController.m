//
//  CompetitionPlusDetailViewController.m
//  2x2
//
//  Created by aDb on 3/5/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "CompetitionPlusDetailViewController.h"
#import "GWQuestionnaire.h"
#import "DataDownloader.h"
#import "CompetitionPlusDetail.h"
#import "Poll.h"
#import "AFNetworking.h"
#import "Settings.h"
#import "DBManager.h"
#import "PollAnswers.h"
#define URLaddress "http://www.app.chargoosh.ir/api/ProfileManager/ParticipatePoll"
#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface CompetitionPlusDetailViewController ()
{
    GWQuestionnaire *surveyController;
    CompetitionPlusDetail *competitionPlusDetail;
    Poll *poll;
    GWQuestionnaireItem *questionItem;
    NSMutableArray *pollList;
    NSMutableArray *pollAnswers;
    UIButton *btn;
    Settings *st ;
    UIActivityIndicatorView *activityIndicator;
    
}
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation CompetitionPlusDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the previous view controller
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
    
    // Associate the barButtonItem to the previous view
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [activityIndicator startAnimating];
    
    st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
 
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=self.competitionTitle;
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font = [UIFont fontWithName:@"B Yekan+" size:17];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView=label;
    
    
    self.competitionDictionary = [[NSMutableDictionary alloc]init];
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            self.competitionDictionary = data;
            
            competitionPlusDetail = [CompetitionPlusDetail alloc];
            
            competitionPlusDetail.data = data;
            
            competitionPlusDetail = [competitionPlusDetail init];
            
            pollList = [[NSMutableArray alloc]init];
            
            for (NSMutableDictionary *item in competitionPlusDetail.pollQuestions) {
                
                
                poll = [Poll alloc];
                
                poll.dataDictionary = item;
                
                poll = [poll init];
                
                [pollList addObject:poll];
                
            }
            
            
            [activityIndicator stopAnimating];
            [self addSurvey];
        }
        
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                            message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
            
            
            NSLog( @"Unable to fetch Data. Try again.");
        }
    };
    
    
    [self.getData GetPoll:self.competitionId phoneNumber:st.settingId withCallback:callback];
    
    
    // Do any additional setup after loading the view.
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}

-(void)addSurvey
{
    
    
    NSMutableArray *questions = [NSMutableArray array];
    
    
    for (Poll *question in pollList) {
        
        NSMutableArray *answers = [[NSMutableArray alloc]init];
        for (NSString *answer in question.pollAnswers ) {
            
            
            NSDictionary *answerItem = [NSDictionary dictionaryWithObjectsAndKeys:answer,@"text",[NSNumber numberWithBool:NO],@"marked", nil];
            [answers addObject:answerItem];
            
        }
        
        questionItem = [[GWQuestionnaireItem alloc] initWithQuestion:question.question
                                                             answers:answers
                                                                type:GWQuestionnaireSingleChoice questionId:questionItem.questionId];
        questionItem.questionId = question.questionId;
        [questions addObject:questionItem];
        
    }
    
    
    questionItem = [[GWQuestionnaireItem alloc] initWithQuestion:@"توضیحات تکمیلی"
                                                         answers:nil
                                                            type:GWQuestionnaireOpenQuestion questionId:@""];
    [questions addObject:questionItem];
    
    surveyController = [[GWQuestionnaire alloc] initWithItems:questions];
    surveyController.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-20);
    [self.view addSubview:surveyController.view];
    
    
    // add button
    btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:NSLocalizedString(@"بفرست", nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(getAnswersPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:RGBCOLOR(255, 240, 0)];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font =[UIFont fontWithName:@"B Yekan+" size:15];
    btn.layer.cornerRadius = 4;
    
    int btnW = 100;
    int btnX = (self.view.frame.size.width - btnW)/2;
    [btn setFrame:CGRectMake(btnX, surveyController.tableView.contentSize.height-40, btnW, 35)];
    
    
  //  [surveyController.view addSubview:btn];

    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"شرکت" style:UIBarButtonItemStyleDone target:self action:@selector(getAnswersPressed:)];
    
    [self.navigationItem setRightBarButtonItem:backButton];
    

    
}


-(void)getAnswersPressed:(id)sender
{
    pollAnswers = [[NSMutableArray alloc]init];
    if(![surveyController isCompleted])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢" message:@"لطفا به تمامی سوالات پاسخ دهید!" delegate:nil cancelButtonTitle:@"خب" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // NSLog answers
    for(GWQuestionnaireItem *item in surveyController.surveyItems)
    {
        
        PollAnswers *answers = [[PollAnswers alloc]init];
        NSLog(@"-----------------");
        NSLog(@"%@",item.question);
        NSLog(@"-----------------");
        if(item.type == GWQuestionnaireOpenQuestion)
        {
            NSLog(@"Answer: %@", item.userAnswer);
            self.exAnswer = [[NSString alloc]init];
            self.exAnswer = item.userAnswer;
        }
        else
            for(NSDictionary *dict in item.answers)
            {
                
                answers.questionId = item.questionId;
                
                if ([[dict objectForKey:@"marked"]boolValue]) {
                    
                    answers.answer =[dict objectForKey:@"text"];
                    
                    [pollAnswers addObject:answers.dictionary];
                }
                
                NSLog(@"%d - %@",[[dict objectForKey:@"marked"]boolValue], [dict objectForKey:@"text"]);
            }
    }
    
    [self SubmitPoll];
}


-(void)SubmitPoll{
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setColor:[UIColor redColor]];
    [btn addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(btn.frame.size.width / 2, btn.frame.size.height / 2);
    [activityIndicator startAnimating];
    
    NSDictionary *parameters = @{@"phoneNumber": st.settingId,
                                 @"pass": st.password,
                                 @"pollid": self.competitionId,
                                 @"answers":pollAnswers,
                                 @"ExAnswer":[NSString stringWithFormat:@" %@",self.exAnswer]};
    
    btn.enabled = NO;
    

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    
    NSString *URLString = @URLaddress;
    
    
    [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                        message:[NSString stringWithFormat:@"%@",responseObject]
                                                       delegate:self
                                              cancelButtonTitle:@"خب"
                                              otherButtonTitles:nil];
        [alert show];
        
        btn.enabled = YES;
        [activityIndicator stopAnimating];
        
        if ([[NSString stringWithFormat:@"%@",responseObject] length]<20) {
            [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:@"⚡︎"];
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        btn.enabled = YES;
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
