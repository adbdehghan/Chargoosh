//
//  InfoViewController.m
//  2x2
//
//  Created by aDb on 4/20/16.
//  Copyright © 2016 aDb. All rights reserved.
//

#import "InfoViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "UIImage+Blur.h"
#import "Competition.h"
#import "PaymentViewController.h"
#define URLaddressFav "http://www.newapp.chargoosh.ir/"
@interface InfoViewController ()
{
 
    UIActivityIndicatorView *activityIndicator;
    Settings *st ;
    UIImage *blurredImage;

}
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=self.qrData;
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font = [UIFont fontWithName:@"B Yekan" size:17];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView=label;
    
    // Get the previous view controller
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
    
    
    // Associate the barButtonItem to the previous view
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.competitionDictionary = data;
            
            if (data.count > 0) {
                
            
            Competition *competition = [[Competition alloc]init];
            competition.title =[self.competitionDictionary valueForKey:@"name"];
            competition.score =[self.competitionDictionary valueForKey:@"score"];
            competition.limit =[self.competitionDictionary valueForKey:@"lastname"];
            competition.startTime =[NSString stringWithFormat: @"%@",[self.competitionDictionary valueForKey:@"isSeller"]];
            //                    competition.startTime =[item valueForKey:@"date"];
            competition.competitionUrl =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddressFav,[self.competitionDictionary valueForKey:@"pic"]]];
            
                
                if ([competition.startTime isEqualToString:@"1"]) {
                    
                    [UIView animateWithDuration:1
                                          delay:0
                                        options: UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         self.buyButton.alpha = 1.f;
                                     }
                                     completion:^(BOOL finished){
                                         NSLog(@"Done!");
                                     }];
                }
                
            
            self.score.text =[NSString stringWithFormat:@"%@",competition.score];
            self.nameLabel.text =[NSString stringWithFormat:@"%@ %@",competition.title,competition.limit];;
            
            //
            
            [self downloadImageWithURL:competition.competitionUrl completionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded) {
                    
                    self.avatarImageView.image = image;
                    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width /2 ;
                    self.avatarImageView.clipsToBounds = YES;
                    NSData *imageData = UIImageJPEGRepresentation(image,  .00001f);
                    blurredImage = [[UIImage imageWithData:imageData] blurredImage:.5f];
                    
                    self.backgroundImageView.image = blurredImage;
                    
                    [self.activityView stopAnimating];
                    
                }
            }];
            }
            
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
    
    [self.getData GetDataQR:st.accesstoken Number:self.qrData withCallback:callback];

    
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
- (IBAction)BuyAction:(id)sender {
    [self performSegueWithIdentifier:@"buy" sender:self];
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"buy"]) {
        PaymentViewController *destination = [segue destinationViewController];
        destination.backgroundImage = blurredImage;
        
    }
}

@end
