//
//  MyshopsTableViewController.m
//  2x2
//
//  Created by aDb on 4/19/16.
//  Copyright © 2016 aDb. All rights reserved.
//

#import "MyshopsTableViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "MMCell.h"
#import "CompetitionDetailViewController.h"
#import "Competition.h"
#import "QRCodeReaderViewController.h"
#import "AppDelegate.h"
#define URLaddress "http://new.chargoosh.ir"
#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface MyshopsTableViewController ()
@property (strong, nonatomic) DataDownloader *getData;

@end

@implementation CALayer (Additions)

- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

@end

@implementation MyshopsTableViewController
{
    NSString *competitionTitle;
    NSString *competitionContent;
    NSString *competitionId;
    NSString *competitionScore;
    UIImage *competitionImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    self.organizationID = app.organizationID;
    
    self.cachedImages = [[NSMutableDictionary alloc] init];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [activityIndicator startAnimating];
    
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    self.competitionDictionary = [[NSMutableDictionary alloc]init];
    self.competitionList = [[NSMutableArray alloc]init];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 100;
    
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
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
    
    //self.tableView.backgroundView = container;
    self.tableView.backgroundColor = [UIColor colorWithRed:.94 green:.94 blue:.94 alpha:1];
    
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.competitionDictionary = data;
            
            for (NSString *item in self.competitionDictionary)
            {
                Competition *competition = [[Competition alloc]init];
                competition.title =[item valueForKey:@"description"];
                competition.score =[item valueForKey:@"scoredetail"];
                competition.limit =[item valueForKey:@"price"];
                competition.startTime =[item valueForKey:@"date"];
                [self.competitionList addObject:competition];
            }
            
            [activityIndicator stopAnimating];
            [self.tableView reloadData];
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
    
    [self.getData GetStatusMyShopping:st.accesstoken orgId:self.organizationID withCallback:callback];
    
    
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    self.cachedImages = [[NSMutableDictionary alloc]init];
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.competitionDictionary = data;
            
            [self.competitionList removeAllObjects];
            
            for (NSString *item in self.competitionDictionary)
            {
                Competition *competition = [[Competition alloc]init];
                competition.title =[item valueForKey:@"description"];
                competition.score =[item valueForKey:@"scoredetail"];
                competition.limit =[item valueForKey:@"price"];
                competition.startTime =[item valueForKey:@"date"];
                [self.competitionList addObject:competition];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                [refreshControl endRefreshing];
            });
            
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
    
    [self.getData GetStatusMyShopping:st.accesstoken orgId:self.organizationID withCallback:callback];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.competitionList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView.estimatedRowHeight = 100;
    
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    static NSString *cellIdentifier = @"CellIdentifier";
    
    MMCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        cell = [[MMCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    
    cell.backgroundColor = [UIColor clearColor];
    
    Competition *competition = [self.competitionList objectAtIndex:indexPath.row];
    
    cell.mmlabel.text= competition.title;
    cell.mmlabel.textColor=[UIColor blackColor];
    cell.mmlabel.textAlignment = NSTextAlignmentRight;
    cell.mmimageView.layer.cornerRadius = cell.mmimageView.frame.size.width/3;
    cell.mmimageView.clipsToBounds = YES;
    
    if ([competition.limit isEqualToString:@"cmp"]) {
        cell.mmimageView.image = [UIImage imageNamed:@"competition@2x"];
    }
    else
        cell.mmimageView.image = [UIImage imageNamed:@"plus"];
    
    cell.coinLabel.text = [NSString stringWithFormat:@"%@",competition.score];
    cell.coinLabel.textAlignment = NSTextAlignmentCenter;
    cell.startTimeLabel.text = competition.startTime;
    cell.endTimeLabel.text = competition.limit;
    [cell.activityView startAnimating];
    
    UIImage *coinImage = [[UIImage imageNamed:@"status.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.coinButton setImage:coinImage forState:UIControlStateNormal];
    
    cell.coinButton.tintColor = RGBCOLOR(238, 213, 0);
    
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108;
    
}

- (void)downloadImageWithURL:(NSURL *)url identifier:(NSString*)Identifier completionBlock:(void (^)(BOOL succeeded, NSMutableDictionary *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   
                                   NSMutableDictionary *imageDictionary = [[NSMutableDictionary alloc]init];
                                   [imageDictionary setValue:image forKey:Identifier];
                                   
                                   
                                   completionBlock(YES,imageDictionary);
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
