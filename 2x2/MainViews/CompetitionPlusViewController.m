//
//  CompetitionPlusViewController.m
//  2x2
//
//  Created by aDb on 2/24/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "CompetitionPlusViewController.h"
#import "DataDownloader.h"
#import "MMCell.h"
#import "CompetitionPlus.h"
#import "CompetitionPlusDetailViewController.h"

#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface CompetitionPlusViewController ()
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation CompetitionPlusViewController
{
    UIActivityIndicatorView *activityIndicator;
    NSString *competitionTitle;
    NSString *competitionId;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [activityIndicator startAnimating];
    //
    self.competitionPlusDictionary = [[NSMutableDictionary alloc]init];
    self.competitionPlusList = [[NSMutableArray alloc]init];
    //
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  //  self.tableView.estimatedRowHeight = 80;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self CreateNavigationBarButtons];
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.competitionPlusDictionary = data;
            
            
            
            for (NSString *item in self.competitionPlusDictionary)
            {
                CompetitionPlus *competitionPlus = [[CompetitionPlus alloc]init];
                competitionPlus.competitionId =[item valueForKey:@"id"];
                competitionPlus.title =[item valueForKey:@"name"];
                competitionPlus.score =[item valueForKey:@"score"];
                competitionPlus.startTime =[item valueForKey:@"startTime"];
                competitionPlus.endTime =[item valueForKey:@"endTime"];
                [self.competitionPlusList addObject:competitionPlus];
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
    
    [self.getData GetPolls:@""  withCallback:callback];
    
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

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    

    
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.competitionPlusDictionary = data;
               [self.competitionPlusList removeAllObjects];
            
            for (NSString *item in self.competitionPlusDictionary)
            {
                CompetitionPlus *competitionPlus = [[CompetitionPlus alloc]init];
                competitionPlus.competitionId =[item valueForKey:@"id"];
                competitionPlus.title =[item valueForKey:@"name"];
                competitionPlus.score =[item valueForKey:@"score"];
                competitionPlus.startTime =[item valueForKey:@"startTime"];
                competitionPlus.endTime =[item valueForKey:@"endTime"];
                [self.competitionPlusList addObject:competitionPlus];
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
    
    [self.getData GetPolls:@""  withCallback:callback];
    
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.competitionPlusList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  //  self.tableView.estimatedRowHeight = 100;
    
    static NSString *cellIdentifier = @"CellIdentifier";
    
    MMCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        cell = [[MMCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    CompetitionPlus *competition = [self.competitionPlusList objectAtIndex:indexPath.row];
    
    cell.mmlabel.text= competition.title;
    cell.mmlabel.textColor=[UIColor blackColor];
    cell.mmlabel.textAlignment = NSTextAlignmentRight;
    cell.mmimageView.layer.cornerRadius = cell.mmimageView.frame.size.width/3;
    cell.mmimageView.clipsToBounds = YES;
    
    cell.coinLabel.text = [NSString stringWithFormat:@"%@",competition.score];
    cell.coinLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.startTimeLabel.text = competition.startTime;
    cell.endTimeLabel.text = competition.endTime;
    
    UIImage *settingImage = [[UIImage imageNamed:@"status.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.coinButton setImage:settingImage forState:UIControlStateNormal];
    
    cell.coinButton.tintColor = RGBCOLOR(238, 213, 0);
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMCell *cell =(MMCell*)[tableView cellForRowAtIndexPath:indexPath];
    competitionTitle = cell.mmlabel.text;
    competitionId = ((CompetitionPlus*)[self.competitionPlusList objectAtIndex:[indexPath row]]).competitionId;
    
    
    [self performSegueWithIdentifier:@"detailPlus" sender:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // this UIViewController is about to re-appear, make sure we remove the current selection in our table view
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}

- (void) statusButtonAction:(id) sender
{
    [self performSegueWithIdentifier:@"Status" sender:self];
}

- (void) settingButtonAction:(id) sender
{
    [self performSegueWithIdentifier:@"setting" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"detailPlus"]) {
        CompetitionPlusDetailViewController *destination = [segue destinationViewController];
        destination.competitionTitle = competitionTitle;
        destination.competitionId = competitionId;
    }
    
}
@end
