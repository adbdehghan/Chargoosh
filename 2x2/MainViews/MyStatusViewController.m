//
//  MyStatusViewController.m
//  2x2
//
//  Created by aDb on 2/24/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "MyStatusViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "Status.h"
#define URLaddressPic "http://www.newapp.chargoosh.ir/"
#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
@interface MyStatusViewController ()
{
    NSIndexPath *path;
    Status *status;
    NSMutableArray *dateTimeList;
    NSMutableArray *scoreList;
    NSMutableArray *stringScoreList;
    NSURL *imageURL;
}
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation MyStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
    profileImage.layer.masksToBounds = YES;
    
    
    [self setTitle:@"وضعیت من"];
    
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=self.navigationItem.title;
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font = [UIFont fontWithName:@"B Yekan+" size:17];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView=label;
    
    // Get the previous view controller
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
    
    // Associate the barButtonItem to the previous view
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [activityIndicator startAnimating];
    
    
    UIImage *settingImage = [[UIImage imageNamed:@"status.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [coinImage setImage:settingImage forState:UIControlStateNormal];
    
    coinImage.tintColor = RGBCOLOR(238, 213, 0);
    
    
    dateTimeList = [[NSMutableArray alloc]init];
    scoreList = [[NSMutableArray alloc]init];
    stringScoreList =[[NSMutableArray alloc]init];
    
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            
            self.statusDictionary = data;
            
            status = [Status alloc];
            
            status.dataDictionary = data;
            
            status = [status init];
            
            for (Status *item in status.summarize) {
                
                [dateTimeList addObject:[item valueForKey:@"time"]];
                [scoreList addObject:[NSNumber numberWithInteger:[[item valueForKey:@"score"] integerValue]]];
                [stringScoreList addObject:[NSString stringWithFormat:@"%@",[item valueForKey:@"score"]]];
            }
            
            name.text = [NSString stringWithFormat:@" امتیاز شما: %@",status.score];
            [activityIndicator stopAnimating];

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
    
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    [self.getData GetSummarize:st.settingId Password:st.password
                  withCallback:callback];
    
    
    
    RequestCompleteBlock callback2 = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            if ([data valueForKey:@"picture"] != nil) {
                
                imageURL =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddressPic,[data valueForKey:@"picture"]]];
                [activityView startAnimating];
                
                [self downloadImageWithURL:imageURL completionBlock:^(BOOL succeeded, UIImage *image) {
                    if (succeeded) {
                        // change the image in the cell
                        profileImage.image = image;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [activityView stopAnimating];
                            
                        });
                    }
                }];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [activityView stopAnimating];
                    
                });
            }
            
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
    
    
    [self.getData GetProfilePicInfo:st.accesstoken withCallback:callback];
    
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)CreateNavigationBarButtons {
    
    UIButton *statusButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [statusButton addTarget:self action:@selector(statusButtonAction:)forControlEvents:UIControlEventTouchUpInside];
    [statusButton setFrame:CGRectMake(0, 0, 24, 24)];
    
    UIImage *image = [[UIImage imageNamed:@"status.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [statusButton setImage:image forState:UIControlStateNormal];
    statusButton.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:statusButton];
    self.navigationItem.leftBarButtonItem = barButton;
    
    UIButton *settingButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *settingImage = [[UIImage imageNamed:@"setting.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [settingButton setImage:settingImage forState:UIControlStateNormal];
    
    settingButton.tintColor = [UIColor whiteColor];
    [settingButton addTarget:self action:@selector(settingButtonAction:)forControlEvents:UIControlEventTouchUpInside];
    [settingButton setFrame:CGRectMake(0, 0, 24, 24)];
    
    
    UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    self.navigationItem.rightBarButtonItem = settingBarButton;
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
