//
//  CompetitionDetailViewController.m
//  2x2
//
//  Created by aDb on 3/1/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "CompetitionDetailViewController.h"
#import "StrechyParallaxScrollView.h"
#import "Masonry.h"
#import "UIView+Shadow.h"
#import "TWPhotoPickerController.h"
#import "ShareViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"

#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface CompetitionDetailViewController ()
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation CompetitionDetailViewController
{
    UIImage *imageToSend;
    UIScrollView *scrollView;
    StrechyParallaxScrollView *strechy;
    UIActivityIndicatorView *activityIndicator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeNavigationBar];
    [self configureNotification:YES];
    
    
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [activityIndicator startAnimating];
    
    
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 150)];
    
    [topView setBackgroundColor:RGBCOLOR(53, 52, 52)];
    [topView setClipsToBounds:YES];

    // [topView makeInsetShadowWithRadius:7 Alpha:.4];
    
    
    UIImageView *circle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 45, 80, 80)];
    [circle setImage:self.coverImage];
    [circle setCenter:topView.center];
    [circle.layer setMasksToBounds:YES];
    [circle.layer setCornerRadius:40];
    [topView addSubview:circle];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, width, 20)];
    [label setText:self.competitionTitle];
    
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setFont:[UIFont fontWithName:@"B Yekan+" size:19]];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setTextColor:[UIColor whiteColor]];
    [topView addSubview:label];
    //masonary constraints for parallax view subviews (optional)
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo (circle.mas_bottom).offset (5);
        make.centerX.equalTo (topView);
    }];
    [circle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo ([NSValue valueWithCGSize:CGSizeMake(80, 80)]);
        make.center.equalTo (topView);
    }];
    
    
    //create strechy parallax scroll view
    strechy = [[StrechyParallaxScrollView alloc] initWithFrame:self.view.frame andTopView:topView];
    [self.view addSubview:strechy];
    
    //add dummy scroll view items
    float itemStartY = topView.frame.size.height + 10;
    
    
    self.competitionDictionary = [[NSMutableDictionary alloc]init];
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.competitionDictionary = data;
            
            self.content =[self.competitionDictionary valueForKey:@"html"];
            self.canParticipate = [[self.competitionDictionary valueForKey:@"canPartipiateLimit"]boolValue];
            self.timeLimitParticipate =[[self.competitionDictionary valueForKey:@"canPartipiateDate"]boolValue];
            [activityIndicator stopAnimating];
            
            [strechy addSubview:[self scrollViewItem:itemStartY andContent:self.content]];
            
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
    
    [self.getData GetCompetition:st.settingId Password:st.password CompetitionId:self.competitionId
                    withCallback:callback];
    
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}

- (UITextView *)scrollViewItemWithY:(CGFloat)y andContent:(NSString*)content {
    
    
    UITextView *item = [[UITextView alloc] initWithFrame:CGRectMake(10, y, [UIScreen mainScreen].bounds.size.width-20, self.view.bounds.size.height)];

    
    [item setBaseWritingDirection:UITextWritingDirectionRightToLeft forRange:[item textRangeFromPosition:[item beginningOfDocument] toPosition:[item endOfDocument]]];
    
    [item setTextAlignment:NSTextAlignmentJustified];
    [item setFont:[UIFont fontWithName:@"B Yekan+" size:19]];
    [item setText:[NSString stringWithFormat:@"%@", content]];
    [item setEditable:NO];
    [item setSelectable:NO];
    //[item sizeToFit];
    [item layoutIfNeeded];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(Participate:)
     forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat size =item.contentSize.height;
    
    
    CGRect newFrame = item.frame;
    newFrame.size.height = item.contentSize.height+105;
    item.frame = newFrame;
    
    
    button.frame = CGRectMake(self.view.bounds.size.width/2-50,size, 100, 47);
    [button setTitle:@"شرکت" forState:UIControlStateNormal];
    button.titleLabel.font =[UIFont fontWithName:@"B Yekan+" size:20];
    [button setBackgroundColor:RGBCOLOR(255, 238, 51)];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 6;
   // [item addSubview:button];
    
    
    
    [strechy setContentSize:CGSizeMake(self.view.bounds.size.width , item.contentSize.height*2)];
    
    return item;
}

- (UIWebView *)scrollViewItem:(CGFloat)y andContent:(NSString*)content {
    
    
    UIWebView *webViewContent = [[UIWebView alloc]initWithFrame:CGRectMake(10, y, [UIScreen mainScreen].bounds.size.width-20, self.view.bounds.size.height)];
    webViewContent.opaque = NO;
    webViewContent.backgroundColor = [UIColor clearColor];
    
    
    NSString *css = [NSString stringWithFormat:
                     @"<html><head><style>body {direction:rtl; background-color: transparent; text-align: %@; font-family:B Yekan;} a { color: #172983; } </style></head><span>",
                     @"justify"];

    
    NSMutableString *desc = [NSMutableString stringWithFormat:@"%@%@%@",
                             css,content,
                             @"</span></html>"];
    
    
    
    [webViewContent loadHTMLString:desc baseURL:nil];
    
    
//    UITextView *item = [[UITextView alloc] initWithFrame:CGRectMake(10, y, [UIScreen mainScreen].bounds.size.width-20, self.view.bounds.size.height)];
//    
//    
//    [item setBaseWritingDirection:UITextWritingDirectionRightToLeft forRange:[item textRangeFromPosition:[item beginningOfDocument] toPosition:[item endOfDocument]]];
//    
//    [item setTextAlignment:NSTextAlignmentJustified];
//    [item setFont:[UIFont fontWithName:@"B Yekan" size:19]];
//    [item setText:[NSString stringWithFormat:@"%@", content]];
//    [item setEditable:NO];
//    [item setSelectable:NO];
//    //[item sizeToFit];
//    [item layoutIfNeeded];
//    
//    
//    CGRect newFrame = item.frame;
//    newFrame.size.height = item.contentSize.height+105;
//    item.frame = newFrame;
//    
// 
//    
//    [strechy setContentSize:CGSizeMake(self.view.bounds.size.width , item.contentSize.height*2)];
    
    return webViewContent;
}


-(void)Participate:(id)sender
{
    
    if (!self.canParticipate) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                        message:@"شما از تمام شانس شرکت در مسابقه خود استفاده کرده اید!"
                                                       delegate:self
                                              cancelButtonTitle:@"خب"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
    else if(!self.timeLimitParticipate)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                        message:@"زمان شرکت در مسابقه هنوز نرسیده یا تمام شده!"
                                                       delegate:self
                                              cancelButtonTitle:@"خب"
                                              otherButtonTitles:nil];
        [alert show];
    
    }
    else
    {
        SCNavigationController *nav = [[SCNavigationController alloc] init];
        nav.scNaigationDelegate = self;
        [nav showCameraWithParentController:self];
        
    }
    
}

+ (CGFloat)heightForText:(NSString*)text font:(UIFont*)font withinWidth:(CGFloat)width {
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:font}];
    CGFloat area = size.height * size.width;
    CGFloat height = roundf(area / width);
    return ceilf(height / font.lineHeight) * font.lineHeight;
}



- (void)CustomizeNavigationBar {
    // Do any additional setup after loading the view.
    
    
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=self.competitionTitle;
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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"شرکت" style:UIBarButtonItemStyleDone target:self action:@selector(Participate:)];
    
    [self.navigationItem setRightBarButtonItem:backButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureNotification:(BOOL)toAdd {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationTakePicture object:nil];
    if (toAdd) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callbackNotificationForFilter:) name:kNotificationTakePicture object:nil];
    }
}

- (void)didTakePicture:(SCNavigationController *)navigationController image:(UIImage *)image {
    
    imageToSend = image;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self performSelector:@selector(GotoPicker) withObject:nil afterDelay:.9];
    
    // [self GotoPicker];
}


-(void)GotoPicker
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissShareViewController)
                                                 name:@"ShareViewControllerDismissed"
                                               object:nil];
    
    [self performSegueWithIdentifier:@"goToShare" sender:self];
}

-(void)didDismissShareViewController {
    
    [activityIndicator startAnimating];
    
    self.competitionDictionary = [[NSMutableDictionary alloc]init];
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.competitionDictionary = data;
            
            self.content =[self.competitionDictionary valueForKey:@"content"];
            self.canParticipate = [[self.competitionDictionary valueForKey:@"canPartipiate"]boolValue];
            
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
    
    [self.getData GetCompetition:st.settingId Password:st.password CompetitionId:self.competitionId
                    withCallback:callback];
    
    [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:@"⚡︎"];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"goToShare"]) {
        
        ShareViewController *destination = [segue destinationViewController];
        
        destination.imageToSend = imageToSend;
        destination.competetitionId = self.competitionId;
    }
    
}

@end
