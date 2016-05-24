//
//  DeviceRegisterer.m
//  2x2
//
//  Created by aDb on 4/25/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "DeviceRegisterer.h"
#import "AFNetworking.h"
#import "Settings.h"
#import "DBManager.h"
#define URLaddress "http://www.newapp.chargoosh.ir"

@implementation DeviceRegisterer
Settings *st ;

- (void)registerDeviceWithToken:(NSString *)token {
    
    st = [[Settings alloc]init];
    
    for (Settings *item in [DBManager selectSetting])
    {
        st =item;
    }
    
    if (st.accesstoken!=nil && token !=nil )
    {
        
        NSDictionary *parameters = @{@"token": token,
                                     @"device":@"ios"};
        
        NSString *sample =[NSString stringWithFormat: @"%s/api/register/addorupdatetoken",URLaddress];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",st.accesstoken] forHTTPHeaderField:@"Authorization"];
        
        [manager POST:sample parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Success %@", responseObject);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {


            NSLog(@"Failure %@, %@", error, operation.responseString);
        }];
        
    }
    
}

@end
