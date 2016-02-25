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
#define URLaddress "http://www.newapp.chargoosh.ir/api/register/addorupdatetoken"

@implementation DeviceRegisterer
Settings *st ;

- (void)registerDeviceWithToken:(NSString *)token {
    
    st = [[Settings alloc]init];
    
    for (Settings *item in [DBManager selectSetting])
    {
        st =item;
    }
    
    if (st.settingId!=nil )
    {
        
        NSDictionary *parameters = @{@"phoneNumber": st.settingId,
                                     @"pass": st.password,
                                     @"token": token,
                                     @"device":@"ios"};
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        
        NSString *URLString = @URLaddress;
        
        
        [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"Success %@", responseObject);
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Failure %@, %@", error, operation.responseString);
        }];
    }
    
}

@end
