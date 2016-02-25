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

- (void)GetCompetitions:(NSString *)orgId token:(NSString*)token withCallback:(RequestCompleteBlock)callback
{
        NSString *sample =[NSString stringWithFormat: @"%s/api/register/GETCompetitions",URLaddress];
    
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

- (void)GetCompetitionsForTopUsers:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/register/GECompetitionsForTop?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
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

- (void)GetTopParticipates:(NSString *)competitionid withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/register/GetTopParticipates?competitionid=%@",URLaddress,competitionid]]];
    
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
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/api/register/GetPolls?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
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
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/api/register/GetPoll?phoneNumber=%@&id=%@",URLaddress,phoneNumber,pollId]]];
    
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

- (void)GetProfilePicInfo:(NSString *)phoneNumber Password:(NSString*)password withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/register/GetPicture?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
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
    NSString *sample =[NSString stringWithFormat: @"%s/api/register/SetSetting?phoneNumber=%@&pass=%@&city=%@&Gender=%@&name=%@&lastname=%@&birhtday_Day=%@&birhtday_month=%@&birhtday_year=%@",URLaddress,phoneNumber,password,city,gender,name,lastName,birthdayDay,birhtdayMonth,birhtdayYear];
    
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

- (void)GetCity:(NSString*)cityId withCallback:(RequestCompleteBlock)callback
{
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%s/api/register/GetCities?provienceID=%@",URLaddress,cityId]]];
    
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
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%s/api/register/GetSetting?phoneNumber=%@&pass=%@",URLaddress,phoneNumber,password]]];
    
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
