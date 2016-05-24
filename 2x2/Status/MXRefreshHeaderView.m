// MXRefreshHeaderView.m
//
// Copyright (c) 2015 Maxime Epain
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MXRefreshHeaderView.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "AppDelegate.h"
#import "UIImage+Blur.h"
#import "Competition.h"
#define URLaddress "http://www.new.chargoosh.ir/"
#define URLaddressFav "http://www.newapp.chargoosh.ir/"

@interface MXRefreshHeaderView ()
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation MXRefreshHeaderView

+ (instancetype)instantiateFromNib {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil];
    
    return [views firstObject];
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        self.organizationID = app.organizationID;
        RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
            if (wasSuccessful) {
                
                self.competitionDictionary = data;
                
              
                    Competition *competition = [[Competition alloc]init];
//                    competition.title =[item valueForKey:@"detail"];
                    competition.score =[self.competitionDictionary valueForKey:@"score"];
                    competition.limit =[self.competitionDictionary valueForKey:@"shopcnt"];
//                    competition.startTime =[item valueForKey:@"date"];
                    competition.competitionUrl =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddressFav,[self.competitionDictionary valueForKey:@"picture"]]];
               
              
                self.score.text = competition.score;
                self.shops.text = competition.limit;
                
                //
                
                [self downloadImageWithURL:competition.competitionUrl completionBlock:^(BOOL succeeded, UIImage *image) {
                    if (succeeded) {
                        
                        self.avatar.image = image;
                        self.avatar.layer.cornerRadius = self.avatar.frame.size.width /2 ;
                        self.avatar.clipsToBounds = YES;
                        self.avatar.layer.borderColor = [UIColor whiteColor].CGColor;
                        self.avatar.layer.borderWidth = 2;
                        
                        NSData *imageData = UIImageJPEGRepresentation(image,  .00001f);
                        UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:.5f];
                        
                        self.background.image = blurredImage;
                        
                        [self.activityView stopAnimating];
                        
                    }
                }];

            }
            
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"👻"
                                                                message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                               delegate:self
                                                      cancelButtonTitle:@"خب"
                                                      otherButtonTitles:nil];
                [alert show];
                
                
                NSLog( @"Unable to fetch Data. Try again.");
            }
        };
        
        Settings *st = [[Settings alloc]init];
        
        st = [DBManager selectSetting][0];
        
        [self.activityView startAnimating];
        
        [self.getData GetStatusParams:st.accesstoken orgId:self.organizationID withCallback:callback];
        
    }
    return self;
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}

@end
