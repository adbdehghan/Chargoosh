//
//  DataDownloader.h
//  2x2
//
//  Created by aDb on 2/25/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataDownloader : NSObject

typedef void (^RequestCompleteBlock) (BOOL wasSuccessful,NSMutableDictionary *recievedData);
typedef void (^ImageRequestCompleteBlock) (BOOL wasSuccessful,UIImage *image);

- (void)requestVerificationCode:(NSString *)params withCallback:(RequestCompleteBlock)callback;

- (void)GetVerificationCode:(NSString *)param1 Param2:(NSString*)param2 withCallback:(RequestCompleteBlock)callback;

- (void)RegisterProfile:(NSString*)token  Name:(NSString*)name LastName:(NSString*)lastName  withCallback:(RequestCompleteBlock)callback;
- (void)GetVersion:(NSString *)params withCallback:(RequestCompleteBlock)callback;
- (void)GetCompetitions:(NSString *)orgId token:(NSString*)token withCallback:(RequestCompleteBlock)callback;
- (void)GetCompetition:(NSString*)token CompetitionId:(NSString*)Id withCallback:(RequestCompleteBlock)callback;
- (void)GetCompetitionsForTopUsers:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback;
- (void)GetMessages:(NSString*)token  withCallback:(RequestCompleteBlock)callback;
- (void)GetTopParticipates:(NSString *)competitionid withCallback:(RequestCompleteBlock)callback;
- (void)GetPolls:(NSString*)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback;
- (void)GetPoll:(NSString*)pollId phoneNumber:(NSString *)phoneNumber withCallback:(RequestCompleteBlock)callback;
- (void)GetOrganizations:(NSString*)token  withCallback:(RequestCompleteBlock)callback;
- (void)GetAllOrganizations:(NSString*)token  withCallback:(RequestCompleteBlock)callback;
- (void)SetOrganizations:(NSString*)token Orgs:(NSMutableArray*)orgs withCallback:(RequestCompleteBlock)callback;
- (void)GetHome:(NSString *)orgId token:(NSString*)token withCallback:(RequestCompleteBlock)callback;
- (void)GetSummarize:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback;
- (void)GetProfilePicInfo:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback;
- (void)SetSetiing:(NSString *)phoneNumber Password:(NSString*)password Name:(NSString*)name LastName:(NSString*)lastName Gender:(NSString*)gender city:(NSString*)city birthdayDay:(NSString*) birthdayDay birhtdayMonth:(NSString*)birhtdayMonth birhtdayYear:(NSString*)birhtdayYear withCallback:(RequestCompleteBlock)callback;
- (void)ClearME:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback;
- (void)GetProviences:(NSString*)param withCallback:(RequestCompleteBlock)callback;
- (void)GetCity:(NSString*)cityId withCallback:(RequestCompleteBlock)callback;
- (void)GetSetting:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback;
- (void)Invite:(NSString *)phoneNumber Password:(NSString*)password contactNumber:(NSString*)contactNumber withCallback:(RequestCompleteBlock)callback;
- (void)GetToken:(NSString *)phoneNumber password:(NSString*)password withCallback:(RequestCompleteBlock)callback;
@end
