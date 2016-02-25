//
//  ShareViewController.m
//  2x2
//
//  Created by aDb on 3/3/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "ShareViewController.h"
#import "UIKit+AFNetworking.h"
#import "AFNetworking.h"
#import "Settings.h"
#import "DBManager.h"
#import "UIColor+FlatColors.h"
#import "PQFCustomLoaders.h"
#define URLaddress "http://www.newapp.chargoosh.ir/api/register/Participate"
@interface ShareViewController ()
@property (nonatomic, strong) PQFBarsInCircle *barsInCircle;
@end

@implementation ShareViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    imageToView.image = self.imageToSend;
    [imageToView setClipsToBounds:YES];
    containerView.layer.cornerRadius = 7;
//    shareButton.layer.cornerRadius = 3;
    descriptionTextView.layer.cornerRadius = 7;
    
    self.barsInCircle = [[PQFBarsInCircle alloc] initLoaderOnView:self.view];
    self.barsInCircle.center =CGPointMake(self.view.center.x, self.view.center.y+50);
    
    //self.barsInCircle.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
    // Associate the barButtonItem to the previous view
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)backAction:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
//    SCNavigationController *nav = [[SCNavigationController alloc] init];
//    nav.scNaigationDelegate = self;
//    [nav showCameraWithParentController:self];

}

-(void)shareAction:(id)sender
{
    [self upload];
}

- (void)upload {
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    
    
    
    
        [self.barsInCircle show];
   // [activityIndicator startAnimating];
    
    // !!! only JPG, PNG not covered! Have to cover PNG as well
    NSString *fileName = [NSString stringWithFormat:@"%ld%c%c.jpg", (long)[[NSDate date] timeIntervalSince1970], arc4random_uniform(26) + 'a', arc4random_uniform(26) + 'a'];
    
  
    
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    NSDictionary *parameters = @{@"CompetitionID": self.competetitionId,
                                 @"Description": descriptionTextView.text
                                , @"Wimg":fileName};
    
    NSString *URLString = @URLaddress;

    
//    NSURLRequest *request = [[AFHTTPRequestSerializer serializer]
//                             multipartFormRequestWithMethod:
//                             @"POST" URLString:URLString
//                             parameters:parameters
//                             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//                                 [formData
//                                  appendPartWithFileData:UIImageJPEGRepresentation(self.imageToSend, .6)
//                                  name:@"Wimg"
//                                  fileName:fileName
//                                  mimeType:@"jpg"];
//                             } error:(NULL)];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
//                                               id responseObject) {
//
////        [operation.request setValue:[NSString stringWithFormat:@"Bearer %@",st.accesstoken] forHTTPHeaderField:@"Authorization"];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareViewControllerDismissed"
//                                                            object:nil
//                                                          userInfo:nil];
//        [self dismissViewControllerAnimated:YES completion:nil];
//        
//        [self.barsInCircle hide];
////        [activityIndicator stopAnimating];
//       // NSLog(@"Success %@", responseObject);
//           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//               
//               NSLog(@"Failure %@, %@", error, operation.responseString);
//               
//               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
//                                                               message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
//                                                              delegate:self
//                                                     cancelButtonTitle:@"خب"
//                                                     otherButtonTitles:nil];
//               [alert show];
//               
//               progressView.progress = 0;
//               shareButton.enabled = YES;
//               shareButton.titleLabel.text = @"تلاش مجدد";
//               [self.barsInCircle hide];
//               [activityIndicator stopAnimating];
//        ;
//    }];
//    
//    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
//                                        long long totalBytesWritten,
//                                        long long totalBytesExpectedToWrite) {
//        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
//    }];
//    
//    [progressView setProgressWithUploadProgressOfOperation:operation animated:YES];
//
//    [operation start];
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",st.accesstoken] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData
                                           appendPartWithFileData:UIImageJPEGRepresentation(self.imageToSend, .6)
                                           name:@"Wimg"
                                           fileName:fileName
                                           mimeType:@"jpg"];
        
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
            NSLog(@"Success %@", responseObject);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareViewControllerDismissed"
                                                                    object:nil
                                                                  userInfo:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
        
                [self.barsInCircle hide];
        
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       NSLog(@"Failure %@, %@", error, operation.responseString);
            shareButton.enabled = YES;
        }];


    
    shareButton.enabled = NO;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [self.view endEditing:YES];
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
