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
- (void)GetCompetitions:(NSString *)orgId token:(NSString*)token Page:(NSString*)page withCallback:(RequestCompleteBlock)callback;
- (void)GetCompetition:(NSString*)token CompetitionId:(NSString*)Id withCallback:(RequestCompleteBlock)callback;
- (void)GetCompetitionsForTopUsers:(NSString *)token orgId:(NSString *)orgId withCallback:(RequestCompleteBlock)callback;
- (void)GetMessages:(NSString*)token  withCallback:(RequestCompleteBlock)callback;
- (void)GetTopParticipates:(NSString *)competitionid Token:(NSString *)token withCallback:(RequestCompleteBlock)callback;
- (void)GetPolls:(NSString*)token orgID:(NSString*)orgId withCallback:(RequestCompleteBlock)callback;
- (void)GetPoll:(NSString*)pollId token:(NSString *)token withCallback:(RequestCompleteBlock)callback;
- (void)GetOrganizations:(NSString*)token  withCallback:(RequestCompleteBlock)callback;
- (void)GetAllOrganizations:(NSString*)token  withCallback:(RequestCompleteBlock)callback;
- (void)SetOrganizations:(NSString*)token Orgs:(NSMutableArray*)orgs withCallback:(RequestCompleteBlock)callback;
- (void)GetHome:(NSString *)orgId token:(NSString*)token withCallback:(RequestCompleteBlock)callback;
- (void)GetSummarize:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback;
- (void)GetProfilePicInfo:(NSString *)token  withCallback:(RequestCompleteBlock)callback;
- (void)SetSetiing:(NSString *)token Name:(NSString*)name LastName:(NSString*)lastName Gender:(NSString*)gender city:(NSString*)city birthdayDay:(NSString*) birthdayDay birhtdayMonth:(NSString*)birhtdayMonth birhtdayYear:(NSString*)birhtdayYear withCallback:(RequestCompleteBlock)callback;
- (void)ClearME:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback;
- (void)GetProviences:(NSString*)param withCallback:(RequestCompleteBlock)callback;
- (void)GetCity:(NSString*)cityId Token:(NSString *)token withCallback:(RequestCompleteBlock)callback;
- (void)GetSetting:(NSString *)token withCallback:(RequestCompleteBlock)callback;
- (void)Invite:(NSString *)phoneNumber Password:(NSString*)password contactNumber:(NSString*)contactNumber withCallback:(RequestCompleteBlock)callback;
- (void)GetToken:(NSString *)phoneNumber password:(NSString*)password withCallback:(RequestCompleteBlock)callback;
- (void)GetAllPictures:(NSString *)token orgId:(NSString *)orgId withCallback:(RequestCompleteBlock)callback;
- (void)GetStatusMyScoreDetail:(NSString *)token orgId:(NSString *)orgId withCallback:(RequestCompleteBlock)callback;
- (void)GetStatusMyShopping:(NSString *)token orgId:(NSString *)orgId withCallback:(RequestCompleteBlock)callback;
- (void)GetStatusParams:(NSString *)token orgId:(NSString *)orgId withCallback:(RequestCompleteBlock)callback;
- (void)GetDataQR:(NSString *)token Number:(NSString *)number withCallback:(RequestCompleteBlock)callback;
- (void)Doshopping:(NSString *)token Number:(NSString *)number Detail:(NSString *)detail ReduceScore:(NSString *)reduceScore Price:(NSString *)price withCallback:(RequestCompleteBlock)callback;
@end
