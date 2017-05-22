//
//  MypicsCollectionViewController.m
//  2x2
//
//  Created by aDb on 4/19/16.
//  Copyright © 2016 aDb. All rights reserved.
//

#import "MypicsCollectionViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "iconCollectionViewCell.h"
#import "SelectedViewController.h"
#import "Competition.h"
#import "QRCodeReaderViewController.h"
#import "AppDelegate.h"
#define URLaddress "http://www.new.chargoosh.ir/"
#define URLaddressFav "http://www.newapp.chargoosh.ir/"

@interface MypicsCollectionViewController ()
{
    NSURL *imageURL;
    UIActivityIndicatorView *activityIndicator;
    Settings *st ;
}
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation MypicsCollectionViewController
NSString *competitionTitle;
NSString *competitionContent;
NSString *competitionId;
UIImage *competitionImage;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    self.organizationID = app.organizationID;
    
    self.cachedImages = [[NSMutableDictionary alloc] init];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [activityIndicator startAnimating];
    
//    for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
//        [self.collectionView deselectRowAtIndexPath:indexPath animated:NO];
//    }
    

    
    
    self.competitionDictionary = [[NSMutableDictionary alloc]init];
    self.competitionList = [[NSMutableArray alloc]init];
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.competitionDictionary = data;
            
            for (NSString *item in self.competitionDictionary)
            {
                Competition *competition = [[Competition alloc]init];
                competition.competitionId =[item valueForKey:@"id"];
                competition.competitionUrl =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddress,[item valueForKey:@"complogo"]]];
                competition.favUrl =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddressFav,[item valueForKey:@"pic"]]];
                [self.competitionList addObject:competition];
            }
            
            if (self.competitionDictionary.count == 0) {
                
            
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.center.y - 30, self.view.frame.size.width,40)];
            label.textColor = [UIColor lightGrayColor];
            label.backgroundColor =[UIColor clearColor];
            label.adjustsFontSizeToFitWidth=YES;
            label.font = [UIFont fontWithName:@"B Yekan+" size:17];
            label.textAlignment = NSTextAlignmentCenter;
            label.text =@"عکسی موجود نیست";
        
            
            UIView *container = [[UIView alloc]init];
            [container setFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height )];
            
            [container addSubview:label];
            
            self.collectionView.backgroundView = container;
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
    
    [self.getData GetAllPictures:st.accesstoken orgId:self.organizationID withCallback:callback];
    
    
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
//                competition.title =[item valueForKey:@"title"];
                competition.competitionId =[item valueForKey:@"id"];
                competition.competitionUrl =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddress,[item valueForKey:@"complogo"]]];
                competition.favUrl =[NSURL URLWithString:[NSString stringWithFormat: @"%s%@",URLaddressFav,[item valueForKey:@"pic"]]];
                
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
    
    [self.getData GetAllPictures:st.accesstoken orgId:self.organizationID withCallback:callback];
    
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
    
    [cell.activityView startAnimating];
    
    [self downloadImageWithURL:competition.favUrl completionBlock:^(BOOL succeeded,UIImage *image) {
        if (succeeded) {
            // change the image in the cell
            if ([collectionView indexPathForCell:cell].row == indexPath.row) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    ClickImage *imageView = [[ClickImage alloc] initWithFrame:CGRectMake(0,0, cell.frame.size.width, cell.frame.size.height)];
                    imageView.image = image;
                    imageView.canClick = YES;
                    
                    cell.clickableThumbnail.canClick = YES;
                    cell.clickableThumbnail.image = imageView.image;
                    
                    [cell.activityView stopAnimating];
                    
                });
            }
        }
    }];
    
    [cell.iconActivityView startAnimating];
    
    
    NSString *identifier = [NSString stringWithFormat:@"Cell%ld" , (long)indexPath.row];
    
    if([self.cachedImages objectForKey:identifier] != nil)
    {
        
        cell.icon.image = [self.cachedImages valueForKey:identifier];
        [cell.iconActivityView stopAnimating];
    }
    else
    {
        // download the image asynchronously
        if (self.collectionView.dragging == NO && self.collectionView.decelerating == NO)
        {
            
            
            [self downloadImageWithURL:competition.competitionUrl identifier:identifier completionBlock:^(BOOL succeeded, NSMutableDictionary *image) {
                if (succeeded) {
                    // change the image in the cell
                    if ([collectionView indexPathForCell:cell].row == indexPath.row) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            
                            if ([image objectForKey:identifier]!=nil) {
                                
                                [self.cachedImages setValue:[image valueForKey:identifier] forKey:identifier];
                                cell.icon.image =  [self.cachedImages valueForKey:identifier];
                                [cell.iconActivityView stopAnimating];
                            }
                            
                        });
                    }
                }
            }];
        }
        cell.icon.image = nil;
        
    }
    return cell;
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(5,5,7,5);  // top, left, bottom, right
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize calCulateSizze = CGSizeMake(self.view.frame.size.width / 4 - 7, self.view.frame.size.width / 4 - 7);
    
    return calCulateSizze;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //    iconCollectionViewCell *cell =(iconCollectionViewCell*)[collectionView cellForRowAtIndexPath:indexPath];
    competitionTitle = ((Competition*)[self.competitionList objectAtIndex:[indexPath row]]).title;
    //    competitionImage = cell.icon.image;
    competitionId =[NSString stringWithFormat:@"%@",((Competition*)[self.competitionList objectAtIndex:[indexPath row]]).competitionId];
    //
 
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



@end
