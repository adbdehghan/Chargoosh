//
//  competitionListTableViewController.m
//  2x2
//
//  Created by aDb on 3/4/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "competitionListTableViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "iconCollectionViewCell.h"
#import "SelectedViewController.h"
#import "Competition.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#define URLaddress "http://www.new.chargoosh.ir/"
#define URLaddressFav "http://www.newapp.chargoosh.ir/"

@interface competitionListTableViewController ()
{
    Settings *st ;
}
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation competitionListTableViewController
NSString *competitionTitle;
NSString *competitionContent;
NSString *competitionId;
UIImage *competitionImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cachedImages = [[NSMutableDictionary alloc] init];
    [self CreateNavigationBarButtons];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    self.organizationID = app.organizationID;
    
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
    
    self.collectionView.backgroundView = container;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [activityIndicator startAnimating];
    
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
        [self.collectionView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    self.competitionDictionary = [[NSMutableDictionary alloc]init];
    self.competitionList = [[NSMutableArray alloc]init];
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.competitionDictionary = data;
            
            for (NSString *item in self.competitionDictionary)
            {
                Competition *competition = [[Competition alloc]init];
                competition.title =[item valueForKey:@"title"];
                competition.competitionId =[item valueForKey:@"id"];
                competition.competitionUrl =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddress,[item valueForKey:@"picture"]]];
                 competition.favUrl =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddressFav,[item valueForKey:@"favImg"]]];
                [self.competitionList addObject:competition];
            }
            
            [activityIndicator stopAnimating];
            [self.collectionView reloadData];
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
    
    [self.getData GetCompetitionsForTopUsers:st.accesstoken orgId:self.organizationID withCallback:callback];
    
    

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
                competition.competitionUrl =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddress,[item valueForKey:@"picture"]]];
                
                [self.competitionList addObject:competition];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.collectionView reloadData];
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
    
    [self.getData GetCompetitionsForTopUsers:st.accesstoken orgId:self.organizationID withCallback:callback];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
   // NSIndexPath *tableSelection = [self.collectionView indexPathForSelectedRow];
    //[self.collectionView deselectRowAtIndexPath:tableSelection animated:NO];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.competitionList count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    iconCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    Competition *competition = [self.competitionList objectAtIndex:indexPath.row];
    
    cell.captionLabel.text= competition.title;

    cell.captionLabel.textColor=[UIColor blackColor];
    cell.captionLabel.textAlignment = NSTextAlignmentCenter;
    cell.icon.layer.cornerRadius = cell.icon.frame.size.width/3;
    cell.icon.clipsToBounds = YES;
    
//     [cell.activityView startAnimating];
    
    [self downloadImageWithURL:competition.competitionUrl completionBlock:^(BOOL succeeded,UIImage *image) {
        if (succeeded) {
            // change the image in the cell
            if ([collectionView indexPathForCell:cell].row == indexPath.row) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.icon.image = image;
                    [cell.iconActivityView stopAnimating];
                    
                });
            }
        }
    }];
    
    [cell.iconActivityView startAnimating];

    [cell.thumbnail setImageWithURL:competition.favUrl
                     placeholderImage:[UIImage imageNamed:@"photoPlaceHolder.png"] options:SDWebImageRefreshCached usingActivityIndicatorStyle:(UIActivityIndicatorViewStyle)UIActivityIndicatorViewStyleWhiteLarge];
    
    return cell;
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(5,5,5,5);  // top, left, bottom, right
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize calCulateSizze = CGSizeMake(self.view.frame.size.width / 2 - 8, self.view.frame.size.width / 2 - 8);
    
    return calCulateSizze;
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





- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    iconCollectionViewCell *cell =(iconCollectionViewCell*)[collectionView cellForRowAtIndexPath:indexPath];
    competitionTitle = ((Competition*)[self.competitionList objectAtIndex:[indexPath row]]).title;
//    competitionImage = cell.icon.image;
    competitionId =[NSString stringWithFormat:@"%@",((Competition*)[self.competitionList objectAtIndex:[indexPath row]]).competitionId];
//
//    
    [self performSegueWithIdentifier:@"next" sender:self];
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


- (void)CreateNavigationBarButtons {
    
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=self.navigationItem.title;
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font = [UIFont fontWithName:@"B Yekan+" size:17];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView=label;
    
    UIButton *statusButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [statusButton addTarget:self action:@selector(statusButtonAction:)forControlEvents:UIControlEventTouchUpInside];
    [statusButton setFrame:CGRectMake(0, 0, 24, 24)];
    
    UIImage *image = [[UIImage imageNamed:@"status.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [statusButton setImage:image forState:UIControlStateNormal];
    statusButton.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:statusButton];
    
    self.navigationItem.leftBarButtonItem = barButton;
    
    UIButton *settingButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *settingImage = [[UIImage imageNamed:@"groups.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [settingButton setImage:settingImage forState:UIControlStateNormal];
    
    settingButton.tintColor = [UIColor whiteColor];
    [settingButton addTarget:self action:@selector(settingButtonAction:)forControlEvents:UIControlEventTouchUpInside];
    [settingButton setFrame:CGRectMake(0, 0, 24, 24)];
    
    
    UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    self.navigationItem.rightBarButtonItem = settingBarButton;
}


- (void) statusButtonAction:(id) sender
{
    [self performSegueWithIdentifier:@"Status" sender:self];
}


- (void) settingButtonAction:(id) sender
{
    [self performSegueWithIdentifier:@"groups" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"next"]) {
        SelectedViewController *destination = [segue destinationViewController];
        destination.competitionId = competitionId;
        destination.competitionTitle = competitionTitle;
    }
    
}

- (void)loadImagesForOnscreenRows
{
    if ([self.cachedImages count]>0) {
        
        
        NSArray *visiblePaths = [self.collectionView indexPathsForVisibleItems];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSString *identifier = [NSString stringWithFormat:@"Cell%ld" , (long)indexPath.row];
            Competition *competition = [self.competitionList objectAtIndex:indexPath.row];
            
            if([self.cachedImages objectForKey:identifier] == nil)
                // Avoid the app icon download if the app already has an icon
            {
                iconCollectionViewCell *cell =(iconCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
                
                [self downloadImageWithURL:competition.competitionUrl identifier:identifier completionBlock:^(BOOL succeeded, NSMutableDictionary *image) {
                    if (succeeded) {
                        // change the image in the cell
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            
                            if ([image objectForKey:identifier]!=nil) {
                                
                                [self.cachedImages setValue:[image valueForKey:identifier] forKey:identifier];
                                cell.icon.image =  [self.cachedImages valueForKey:identifier];
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
