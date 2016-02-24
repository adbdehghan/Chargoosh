//
//  SecondViewController.m
//  2x2
//
//  Created by aDb on 2/23/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "SelectedViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "MMCell.h"
#import "TopParticipate.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#define URLaddress "http://www.app.chargoosh.ir/"

@interface SelectedViewController ()
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation SelectedViewController
NSString *name;
NSString *lastName;
UIImage *competitionImage;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self CreateNavigationBarButtons];

    self.cachedImages = [[NSMutableDictionary alloc] init];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [activityIndicator startAnimating];
    
    
    self.competitionDictionary = [[NSMutableDictionary alloc]init];
    self.topParticipateList = [[NSMutableArray alloc]init];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 80;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.competitionDictionary = data;
            
            for (NSString *item in self.competitionDictionary)
            {
                TopParticipate *top = [[TopParticipate alloc]init];
                top.name =[item valueForKey:@"name"];
                top.lastName =[item valueForKey:@"lastName"];
                top.imageUrl = [NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddress,[item valueForKey:@"picture"]]];
                top.imageDescription = [item valueForKey:@"description"]==[NSNull null]?@"":[item valueForKey:@"description"];
                
                [self.topParticipateList addObject:top];
                
            }
            
            [activityIndicator stopAnimating];
            [self.tableView reloadData];
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
    
    
    [self.getData GetTopParticipates:self.competitionId
                        withCallback:callback];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.competitionDictionary = data;
            
            [self.topParticipateList removeAllObjects];
            
            for (NSString *item in self.competitionDictionary)
            {
                TopParticipate *top = [[TopParticipate alloc]init];
                top.name =[item valueForKey:@"name"];
                top.lastName =[item valueForKey:@"lastName"];
                top.imageUrl = [NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddress,[item valueForKey:@"picture"]]];
                top.imageDescription = [item valueForKey:@"description"]==[NSNull null]?@"":[item valueForKey:@"description"];
                [self.topParticipateList addObject:top];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                [refreshControl endRefreshing];
            });
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
    
    
    [self.getData GetTopParticipates:self.competitionId
                        withCallback:callback];
    
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}


- (void)CreateNavigationBarButtons {
    
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
    
    // Associate the barButtonItem to the previous view
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.topParticipateList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;//[self.topParticipateList count];
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 400;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView.estimatedRowHeight = 100;
    
    static NSString *cellIdentifier = @"CellIdentifier";
    
    MMCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        cell = [[MMCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    TopParticipate *top = [self.topParticipateList objectAtIndex:indexPath.section];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.startTimeLabel.textColor=[UIColor whiteColor];
    cell.startTimeLabel.textAlignment = NSTextAlignmentCenter;
    cell.startTimeLabel.clipsToBounds = YES;
    cell.startTimeLabel.text = top.imageDescription;
    

    [cell.mmimageView setImageWithURL:top.imageUrl
                      placeholderImage:[UIImage imageNamed:@"photoPlaceHolder.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)UIActivityIndicatorViewStyleWhiteLarge];

    
    
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    TopParticipate *top = [self.topParticipateList objectAtIndex:section];
    NSString *cellText =[NSString stringWithFormat:@"%@ %@",top.name,top.lastName];
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , 40);
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.font = [UIFont fontWithName:@"B Yekan+" size:15];
    label.backgroundColor = [[UIColor darkGrayColor]colorWithAlphaComponent:1];
    label.text = cellText;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    TopParticipate *top = [self.topParticipateList objectAtIndex:section];
    
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , 40);
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.font = [UIFont fontWithName:@"B Yekan+" size:15];
    label.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:1];
    label.text = top.imageDescription;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
    
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
