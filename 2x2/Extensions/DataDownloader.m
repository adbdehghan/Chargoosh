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
#import "AFNetworking.h"
#import "Settings.h"
#import "DBManager.h"
#define URLaddress "http://www.newapp.chargoosh.ir/"

@implementation DataDownloader
NSMutableDictionary *receivedData;

- (void)requestVerificationCode:(NSString *)params withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/register/VerificationCode?phoneNumber=%@",URLaddress,params]]];
    
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
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/register/GetPassword?phoneNumber=%@&verificationCode=%@",URLaddress,param1,param2]]];
    
    JCDHTTPConnection *connection = [[JCDHTTPConnection alloc] initWithRequest:request];
    [connection executeRequestOnSuccess:
     ^(NSHTTPURLResponse *response, NSData *data) {
         if (response.statusCode == 200) {
             
             NSString* newStr =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             
             if (![newStr isEqualToString:@"\"CodeWrong\""]) {
                 
                 NSString * password= @"";
                 
                 for (int i = 0; i< [newStr length]; i++) {
                     
                     
                         NSString *current =[NSString stringWithFormat:@"%c",[newStr characterAtIndex:i]];
                         if (![current isEqualToString:@""]) {
                             
                             
                             password = [password stringByAppendingString:[NSString stringWithFormat:@"%c",[newStr characterAtIndex:i]]];
                             password = [password stringByReplacingOccurrencesOfString:@"\"" withString:@""];
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

- (void)GetToken:(NSString *)phoneNumber password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    receivedData = [[NSMutableDictionary alloc]init];
    NSDictionary *parameters = @{@"username": phoneNumber,
                                 @"password": password,
                                 @"grant_type":@"password"};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    NSString *URLString = @"http://www.newapp.chargoosh.ir/token";
    
    
    [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        NSString * password= @"";
        
        password = [responseObject valueForKey:@"access_token"];
        
        [receivedData setObject:password forKey:@"accesstoken"];
        
        callback(YES,receivedData);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];

}

- (void)RegisterProfile:(NSString*)token  Name:(NSString*)name LastName:(NSString*)lastName  withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/SetProfileFields",URLaddress];
   
    NSDictionary *parameters = @{@"Name": name, @"lastname" : lastName};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];

    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
    
   }

//
//- (void)RegisterProfile:(NSString*)token  Name:(NSString*)name LastName:(NSString*)lastName  withCallback:(RequestCompleteBlock)callback
//{
//    NSString *sample =[NSString stringWithFormat: @"%s/api/register/participate",URLaddress];
//    
//    NSDictionary *parameters = @{@"competitionid": name, @"description" : lastName,@"image":@"image"};
//    
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
//    
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
//    
//    [manager POST:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSLog(@"Success %@", responseObject);
//        
//        callback(YES,responseObject);
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        callback(NO,nil);
//        NSLog(@"Failure %@, %@", error, operation.responseString);
//    }];
//    
//}

- (void)GetVersion:(NSString *)params withCallback:(RequestCompleteBlock)callback
{
    receivedData = [[NSMutableDictionary alloc]init];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/register/GetVersion",URLaddress]]];
    
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

- (void)GetCompetitions:(NSString *)orgId token:(NSString*)token Page:(NSString*)page withCallback:(RequestCompleteBlock)callback
{
        NSString *sample =[NSString stringWithFormat: @"%s/api/register/GETCompetitions",URLaddress];
    
        NSDictionary *parameters = @{@"organizationid": orgId , @"page": page};
    
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
        [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
            NSLog(@"Success %@", responseObject);
    
            callback(YES,responseObject);
    
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            callback(NO,nil);
            NSLog(@"Failure %@, %@", error, operation.responseString);
        }];
}

- (void)GetCompetitionsForTopUsers:(NSString *)token orgId:(NSString *)orgId withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/getTopSubjects",URLaddress];
    
    NSDictionary *parameters = @{@"organizationid": orgId};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)GetStatusMyScoreDetail:(NSString *)token orgId:(NSString *)orgId withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GetStatusMyScoreDetail",URLaddress];
    
    NSDictionary *parameters = @{@"organizationid": orgId};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)GetStatusMyShopping:(NSString *)token orgId:(NSString *)orgId withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GetStatusMyShopping",URLaddress];
    
    NSDictionary *parameters = @{@"organizationid": orgId};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)GetStatusParams:(NSString *)token orgId:(NSString *)orgId withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GetStatusParams",URLaddress];
    
    NSDictionary *parameters = @{@"organizationid": orgId};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)GetDataQR:(NSString *)token Number:(NSString *)number withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GetDataQR",URLaddress];
    
    NSDictionary *parameters = @{@"number": number};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)Doshopping:(NSString *)token Number:(NSString *)number Detail:(NSString *)detail ReduceScore:(NSString *)reduceScore Price:(NSString *)price withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/Doshopping",URLaddress];
    
    NSDictionary *parameters = @{@"number": number,@"detail": detail,@"reduceScore": reduceScore,@"price": price};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)GetAllPictures:(NSString *)token orgId:(NSString *)orgId withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GetStatusMyCompetitions",URLaddress];
    
    NSDictionary *parameters = @{@"organizationid": orgId};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)GetCompetition:(NSString*)token CompetitionId:(NSString*)Id withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GETCompetition",URLaddress];
    
    NSDictionary *parameters = @{@"CompetitionId":Id};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}


- (void)GetMessages:(NSString*)token  withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GetMessage",URLaddress];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}


- (void)GetOrganizations:(NSString*)token  withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GetOrganizations",URLaddress];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}



- (void)GetAllOrganizations:(NSString*)token  withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GetallOrgans",URLaddress];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)SetOrganizations:(NSString*)token Orgs:(NSMutableArray*)orgs withCallback:(RequestCompleteBlock)callback
{
    NSDictionary *parameters = @{@"myorgs": orgs};
    
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/SetMyOrg",URLaddress];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)GetTopParticipates:(NSString *)competitionid Token:(NSString *)token withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GetTopParticipates",URLaddress];
    
    NSDictionary *parameters = @{@"competitionid": competitionid};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)GetPolls:(NSString*)token orgID:(NSString*)orgId withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GetPolls",URLaddress];
    
    NSDictionary *parameters = @{@"organizationid": orgId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)GetPoll:(NSString*)pollId token:(NSString *)token withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GetPoll",URLaddress];
    
    NSDictionary *parameters = @{@"id": pollId};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}


- (void)GetHome:(NSString *)orgId token:(NSString*)token withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GetHome",URLaddress];
    
    NSDictionary *parameters = @{@"organizationid": orgId};
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)GetSummarize:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/register/GetSummarize?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
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

- (void)GetProfilePicInfo:(NSString *)token  withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/getpicandname",URLaddress];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)SetSetiing:(NSString *)token Name:(NSString*)name LastName:(NSString*)lastName Gender:(NSString*)gender city:(NSString*)city birthdayDay:(NSString*) birthdayDay birhtdayMonth:(NSString*)birhtdayMonth birhtdayYear:(NSString*)birhtdayYear withCallback:(RequestCompleteBlock)callback
{
    
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/SetSetting?city=%@&Gender=%@&name=%@&lastname=%@&birhtday_Day=%@&birhtday_month=%@&birhtday_year=%@",URLaddress,city,gender,name,lastName,birthdayDay,birhtdayMonth,birhtdayYear];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:[sample stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)ClearME:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/register/ClearME?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
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
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/api/register/GetProviences",URLaddress]]];
    
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

- (void)GetCity:(NSString*)cityId Token:(NSString*)token withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat:@"%s/api/register/GetCities?proId=%@",URLaddress,cityId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

- (void)GetSetting:(NSString *)token withCallback:(RequestCompleteBlock)callback
{
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/GetSetting",URLaddress];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:sample parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        callback(YES,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(NO,nil);
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
    
}

- (void)Invite:(NSString *)phoneNumber Password:(NSString*)password contactNumber:(NSString*)contactNumber withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/register/Invite?phoneNumber=%@&pass=%@&number=%@",URLaddress,phoneNumber,password,contactNumber]]];
    
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
