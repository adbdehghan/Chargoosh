//
//  CompetitionViewController.m
//  2x2
//
//  Created by aDb on 2/24/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "CompetitionViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "MMCell.h"
#import "CompetitionDetailViewController.h"
#import "Competition.h"
#import "QRCodeReaderViewController.h"
#define URLaddress "http://www.app.chargoosh.ir/"
#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
@interface CompetitionViewController ()<QRCodeReaderDelegate>
@property (strong, nonatomic) DataDownloader *getData;

@end

@implementation CompetitionViewController
{
    NSString *competitionTitle;
    NSString *competitionContent;
    NSString *competitionId;
    NSString *competitionScore;
    UIImage *competitionImage;
}

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
    
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    self.competitionDictionary = [[NSMutableDictionary alloc]init];
    self.competitionList = [[NSMutableArray alloc]init];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 100;
    
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.competitionDictionary = data;
            
            for (NSString *item in self.competitionDictionary)
            {
                Competition *competition = [[Competition alloc]init];
                competition.title =[item valueForKey:@"title"];
                competition.competitionId =[item valueForKey:@"id"];
                competition.userParticipationCount =[item valueForKey:@"userCompetitionCnt"];
                competition.score =[item valueForKey:@"score"];
                competition.competitionUrl =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddress,[item valueForKey:@"picture"]]];
                competition.limit =[item valueForKey:@"limitParticipate"];
                competition.startTime =[item valueForKey:@"startTime"];
                competition.endTime =[item valueForKey:@"endTime"];
                competition.scorePerPic =[item valueForKey:@"initScore"];
                [self.competitionList addObject:competition];
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
    
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    [self.getData GetCompetitions:st.settingId Password:st.password
                     withCallback:callback];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // this UIViewController is about to re-appear, make sure we remove the current selection in our table view
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
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
                competition.title =[item valueForKey:@"title"];
                competition.competitionId =[item valueForKey:@"id"];
                competition.userParticipationCount =[item valueForKey:@"userCompetitionCnt"];
                competition.score =[item valueForKey:@"score"];
                competition.competitionUrl =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddress,[item valueForKey:@"picture"]]];
                competition.limit =[item valueForKey:@"limitParticipate"];
                competition.startTime =[item valueForKey:@"startTime"];
                competition.endTime =[item valueForKey:@"endTime"];
                competition.scorePerPic =[item valueForKey:@"initScore"];
                [self.competitionList addObject:competition];
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
    
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    [self.getData GetCompetitions:st.settingId Password:st.password
                     withCallback:callback];
    
    
}

- (void)CreateNavigationBarButtons {
    UIButton *statusButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [statusButton addTarget:self action:@selector(statusButtonAction:)forControlEvents:UIControlEventTouchUpInside];
    [statusButton setFrame:CGRectMake(0, 0, 24, 24)];
    
    UIImage *image = [[UIImage imageNamed:@"status.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [statusButton setImage:image forState:UIControlStateNormal];
    statusButton.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:statusButton];
    UIButton *barcodeButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *barcodeImage = [UIImage imageNamed:@"m_scan.png"];
    
    [barcodeButton setImage:barcodeImage forState:UIControlStateNormal];
    
    [barcodeButton addTarget:self action:@selector(ShowQR)forControlEvents:UIControlEventTouchUpInside];
    [barcodeButton setFrame:CGRectMake(0, 0, 20, 20)];
    
    
    UIBarButtonItem *barcodeBarButton = [[UIBarButtonItem alloc] initWithCustomView:barcodeButton];
    
      NSArray *barButtons = @[barcodeBarButton,barButton];
    
    self.navigationItem.leftBarButtonItems = barButtons;
    
    UIButton *settingButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *settingImage = [[UIImage imageNamed:@"setting.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [settingButton setImage:settingImage forState:UIControlStateNormal];
    
    settingButton.tintColor = [UIColor whiteColor];
    [settingButton addTarget:self action:@selector(settingButtonAction:)forControlEvents:UIControlEventTouchUpInside];
    [settingButton setFrame:CGRectMake(0, 0, 24, 24)];
    
    
    UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    self.navigationItem.rightBarButtonItem = settingBarButton;
}

-(void)ShowQR
{
    static QRCodeReaderViewController *reader = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        reader = [QRCodeReaderViewController new];
        reader.modalPresentationStyle = UIModalPresentationFormSheet;
    });
    reader.delegate = self;
    
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        NSLog(@"Completion with result: %@", resultAsString);
    }];
    
    [self presentViewController:reader animated:YES completion:NULL];
    
    
}

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"QRCodeReader" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
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
    
    
    
    Competition *competition = [self.competitionList objectAtIndex:indexPath.row];
    
    cell.mmlabel.text= competition.title;
    cell.mmlabel.textColor=[UIColor blackColor];
    cell.mmlabel.textAlignment = NSTextAlignmentRight;
    cell.mmimageView.layer.cornerRadius = cell.mmimageView.frame.size.width/3;
    cell.mmimageView.clipsToBounds = YES;
    
    cell.coinLabel.text = [NSString stringWithFormat:@"%@",competition.score];
    cell.coinLabel.textAlignment = NSTextAlignmentCenter;
    cell.limitLabel.text = [NSString stringWithFormat:@"%@ از %@ عکس",competition.userParticipationCount,competition.limit];
    cell.startTimeLabel.text = competition.startTime;
    cell.endTimeLabel.text = competition.endTime;
    cell.scorePerPic.text = [NSString stringWithFormat:@"%@",competition.scorePerPic];
    
    [cell.activityView startAnimating];
    
    UIImage *coinImage = [[UIImage imageNamed:@"status.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.coinButton setImage:coinImage forState:UIControlStateNormal];
    
    cell.coinButton.tintColor = RGBCOLOR(238, 213, 0);
    
    
    NSString *identifier = [NSString stringWithFormat:@"Cell%ld" , (long)indexPath.row];
    
    if([self.cachedImages objectForKey:identifier] != nil)
    {
        
        cell.mmimageView.image = [self.cachedImages valueForKey:identifier];
        [cell.activityView stopAnimating];
    }
    else
    {
        // download the image asynchronously
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            
            
            [self downloadImageWithURL:competition.competitionUrl identifier:identifier completionBlock:^(BOOL succeeded, NSMutableDictionary *image) {
                if (succeeded) {
                    // change the image in the cell
                    if ([tableView indexPathForCell:cell].row == indexPath.row) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            
                            if ([image objectForKey:identifier]!=nil) {
                                
                                [self.cachedImages setValue:[image valueForKey:identifier] forKey:identifier];
                                cell.mmimageView.image =  [self.cachedImages valueForKey:identifier];
                                [cell.activityView stopAnimating];
                            }
                            
                        });
                    }
                }
            }];
        }
        cell.mmimageView.image = nil;
        
    }
    
    
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



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMCell *cell =(MMCell*)[tableView cellForRowAtIndexPath:indexPath];
    competitionTitle = cell.mmlabel.text;
    competitionImage = cell.mmimageView.image;
    competitionId = ((Competition*)[self.competitionList objectAtIndex:[indexPath row]]).competitionId;
    
    
    [self performSegueWithIdentifier:@"detail" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}

- (void) statusButtonAction:(id) sender
{
    [self performSegueWithIdentifier:@"Status" sender:self];
}

- (void) settingButtonAction:(id) sender
{
    [self performSegueWithIdentifier:@"setting" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"detail"]) {
        CompetitionDetailViewController *destination = [segue destinationViewController];
        destination.competitionTitle = competitionTitle;
        destination.coverImage = competitionImage;
        destination.competitionId = competitionId;
    }
    
}

- (void)loadImagesForOnscreenRows
{
    if ([self.cachedImages count]>0) {
        
        
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSString *identifier = [NSString stringWithFormat:@"Cell%ld" , (long)indexPath.row];
            Competition *competition = [self.competitionList objectAtIndex:indexPath.row];
            
            if([self.cachedImages objectForKey:identifier] == nil)
                // Avoid the app icon download if the app already has an icon
            {
                MMCell *cell =(MMCell*)[self.tableView cellForRowAtIndexPath:indexPath];
                
                [self downloadImageWithURL:competition.competitionUrl identifier:identifier completionBlock:^(BOOL succeeded, NSMutableDictionary *image) {
                    if (succeeded) {
                        // change the image in the cell
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            
                            if ([image objectForKey:identifier]!=nil) {
                                
                                [self.cachedImages setValue:[image valueForKey:identifier] forKey:identifier];
                                cell.mmimageView.image =  [self.cachedImages valueForKey:identifier];
                                [cell.activityView stopAnimating];
                            }
                            
                        });
                        
                    }
                }];
                
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


@end
