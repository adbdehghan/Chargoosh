//
//  DataDownloader.m
//  2x2
//
//  Created by aDb on 2/25/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "DataDownloader.h"
#import "JCDHTTPConnection.h"
#import "SBJsonParser.h"
#define URLaddress "http://www.app.chargoosh.ir/"

@implementation DataDownloader
NSMutableDictionary *receivedData;

- (void)requestVerificationCode:(NSString *)params withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/GetVerificationCode?phoneNumber=%@",URLaddress,params]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             // NSDictionary *XML = [self serializedData:data];
             //receivedData = [XML valueForKey:@"row"];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetVerificationCode:(NSString *)param1 Param2:(NSString*)param2 withCallback:(RequestCompleteBlock)callback
{
    receivedData = [[NSMutableDictionary alloc]init];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/GetPassword?phoneNumber=%@&verificationCode=%@",URLaddress,param1,param2]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             
             if (![newStr isEqualToString:@"\"CodeWrong\""]) {
                 
                 NSString * password= @"";
                 
                 for (int i = 0; i< [newStr length]; i++) {
                     
                     if (i>9)
                     {
                         NSString *current =[NSString stringWithFormat:@"%c",[newStr characterAtIndex:i]];
                         if (![current isEqualToString:@""]) {
                             
                             
                             password = [password stringByAppendingString:[NSString stringWithFormat:@"%c",[newStr characterAtIndex:i]]];
                             password = [password stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                         }
                     }
                 }
                 
                 [receivedData setObject:password forKey:@"password"];
             }
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)RegisterProfile:(NSString *)phoneNumber Password:(NSString*)password Name:(NSString*)name LastName:(NSString*)lastName Gender:(NSString*)gender withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/ProfileManager/RegisterProfileT?phoneNumber=%@&pass=%@&profileName=%@&profileLastName=%@&profileGender=%@",URLaddress,phoneNumber,password,name,lastName,gender];
    
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[sample stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetVersion:(NSString *)params withCallback:(RequestCompleteBlock)callback
{
    receivedData = [[NSMutableDictionary alloc]init];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/GetVersion",URLaddress]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             
             [receivedData setObject: newStr forKey:@"version"];
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetCompetitions:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/GECompetitions?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetCompetitionsForTopUsers:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/GECompetitionsForTop?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetCompetition:(NSString *)phoneNumber Password:(NSString*)password CompetitionId:(NSString*)Id withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/GECompetition?phoneNumber=%@&pass=%@&CompetitionId=%@",URLaddress,phoneNumber,password,Id]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}


- (void)GetMessages:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/GetMessage?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetTopParticipates:(NSString *)competitionid withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/GetTopParticipates?competitionid=%@",URLaddress,competitionid]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetPolls:(NSString*)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/api/ProfileManager/GetPolls?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetPoll:(NSString*)pollId phoneNumber:(NSString *)phoneNumber withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/api/ProfileManager/GetPoll?phoneNumber=%@&id=%@",URLaddress,phoneNumber,pollId]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetHome:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/GetHome?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetSummarize:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/GetSummarize?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetProfilePicInfo:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/GetPicture?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)SetSetiing:(NSString *)phoneNumber Password:(NSString*)password Name:(NSString*)name LastName:(NSString*)lastName Gender:(NSString*)gender city:(NSString*)city birthdayDay:(NSString*) birthdayDay birhtdayMonth:(NSString*)birhtdayMonth birhtdayYear:(NSString*)birhtdayYear withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/ProfileManager/SetSetting?phoneNumber=%@&pass=%@&city=%@&Gender=%@&name=%@&lastname=%@&birhtday_Day=%@&birhtday_month=%@&birhtday_year=%@",URLaddress,phoneNumber,password,city,gender,name,lastName,birthdayDay,birhtdayMonth,birhtdayYear];
    
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[sample stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)ClearME:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/ClearME?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetProviences:(NSString*)param withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/api/ProfileManager/GetProviences",URLaddress]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetCity:(NSString*)cityId withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/api/ProfileManager/GetCities?provienceID=%@",URLaddress,cityId]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)GetSetting:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/GetSetting?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}

- (void)Invite:(NSString *)phoneNumber Password:(NSString*)password contactNumber:(NSString*)contactNumber withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/ProfileManager/Invite?phoneNumber=%@&pass=%@&number=%@",URLaddress,phoneNumber,password,contactNumber]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             SBJsonParser *sbp = [SBJsonParser new];
             
             receivedData = [sbp objectWithString:newStr];
             
             callback(YES,receivedData);
         } else {
             callback(NO,nil);
         }
     } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
         callback(NO,nil);
     } didSendData:nil];
}
@end
