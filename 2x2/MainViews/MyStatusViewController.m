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
#import <QuartzCore/QuartzCore.h>
#import "MypicsCollectionViewController.h"
#import "MyCompetitionsTableViewController.h"
#import "MyshopsTableViewController.h"
#import "MXRefreshHeaderView.h"
#import "UIImage+MDQRCode.h"
#import "KLCPopup.h"

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
    Settings *st ;

}
@property (strong, nonatomic) DataDownloader *getData;

@end

@implementation MyStatusViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *barcodeButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *barcodeImage = [UIImage imageNamed:@"m_scan.png"];
    
    [barcodeButton setImage:barcodeImage forState:UIControlStateNormal];
    
    [barcodeButton addTarget:self action:@selector(ShowQR)forControlEvents:UIControlEventTouchUpInside];
    [barcodeButton setFrame:CGRectMake(0, 0, 20, 20)];
    
    
    UIBarButtonItem *barcodeBarButton = [[UIBarButtonItem alloc] initWithCustomView:barcodeButton];
    
    self.navigationItem.rightBarButtonItem = barcodeBarButton;
    
    self.segmentedPager.parallaxHeader.view = [MXRefreshHeaderView instantiateFromNib];
    self.segmentedPager.parallaxHeader.mode = MXParallaxHeaderModeFill;
    self.segmentedPager.parallaxHeader.height = 240;
    self.segmentedPager.parallaxHeader.minimumHeight = 190;
    
    // Segmented Control customization
    self.segmentedPager.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedPager.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedPager.segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    self.segmentedPager.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:74/255.f green:144/255.f blue:226/255.f alpha:1.f]};
    self.segmentedPager.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedPager.segmentedControl.type = HMSegmentedControlTypeImages;

    self.segmentedPager.segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:74/255.f green:144/255.f blue:226/255.f alpha:1.f];
    
    self.segmentedPager.segmentedControlEdgeInsets = UIEdgeInsetsMake(0, 0, 1, 0);

    
    ///
    UIView *layer = [[UIView alloc]init];
    layer.backgroundColor = [UIColor blackColor];
    layer.alpha = .5f;
    [layer setFrame:self.view.frame];
    
    UIImageView *backImage =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.jpg"]];
    [backImage setFrame:CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height-110 )];
    
    UIView *container = [[UIView alloc]init];
    [container setFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-110 )];
    
    [container addSubview:backImage];
    [container addSubview:layer];
    
//    [backGroundContainer addSubview:container];
    ///
    
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
 //   [activityIndicator startAnimating];
    
    
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"👻"
                                                            message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
            
            
            NSLog( @"Unable to fetch Data. Try again.");
        }
    };
    
    st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
//    [self.getData GetSummarize:st.settingId Password:st.password
//                  withCallback:callback];
//    
    
    
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"👻"
                                                            message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
            
            
            NSLog( @"Unable to fetch Data. Try again.");
        }
    };
    
    
//    [self.getData GetProfilePicInfo:st.accesstoken withCallback:callback];
    // Parallax Header
    
}

-(void)ShowQR
{
    CGFloat imageSize = ceilf(self.view.bounds.size.width * 0.6f);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(floorf(self.view.bounds.size.width * 0.5f - imageSize * 0.5f), floorf(self.view.bounds.size.height * 0.5f - imageSize * 0.5f), imageSize, imageSize)];
    
    imageView.image = [UIImage mdQRCodeForString:st.settingId size:imageView.bounds.size.width fillColor:[UIColor blackColor]];
    imageView.backgroundColor = [UIColor whiteColor];
    
    UIView* contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor orangeColor];
    contentView.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
    
    KLCPopup* popup = [KLCPopup popupWithContentView:imageView];
    [popup show];
    
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

#pragma mark Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(MXPageSegue *)segue sender:(id)sender {
//    MXNumberViewController *numberViewController = segue.destinationViewController;
//    numberViewController.number = segue.pageIndex;
}

#pragma mark <MXSegmentedPagerControllerDataSource>

- (NSInteger)numberOfPagesInSegmentedPager:(MXSegmentedPager *)segmentedPager {
    return 3;
}

//- (NSString *)segmentedPager:(MXSegmentedPager *)segmentedPager titleForSectionAtIndex:(NSInteger)index {
//    return @[@"Table", @"Web", @"Text"][index];
//}

- (UIImage*) segmentedPager:(MXSegmentedPager*)segmentedPager imageForSectionAtIndex:(NSInteger)index
{
    return @[[UIImage imageNamed:@"gallery"],[UIImage imageNamed:@"scoreListD@2x"],[UIImage imageNamed:@"transactionD@2x"]][index];
}

- (UIImage*) segmentedPager:(MXSegmentedPager*)segmentedPager selectedImageForSectionAtIndex:(NSInteger)index{
    return @[[UIImage imageNamed:@"galleryS@2x"],[UIImage imageNamed:@"scoreList@2x"],[UIImage imageNamed:@"transaction@2x"]][index];

}

- (NSString *)segmentedPager:(MXSegmentedPager *)segmentedPager segueIdentifierForPageAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @"pic";
            break;
            case 1:
            return @"comp";
            break;
            case 2:
            return @"shop";
            break;
        default:
            break;
    }
    return @"pic";
}

@end
