//
//  FirstViewController.m
//  2x2
//
//  Created by aDb on 2/23/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "HomeViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "Home.h"
#import "DBManager.h"
#import "HomeTableViewCell.h"
#import "iconCollectionTableViewCell.h"
#import "iconCollectionViewCell.h"
#import "HomeIcon.h"
#import "HomeDetailViewController.h"
#define URLaddressPic "http://www.app.chargoosh.ir/"
@interface HomeViewController ()
{
    Home *home;
    NSString *content;
    NSString * title;
    UIImage *imageToDetail;
    NSURL *imageURL;
    UIActivityIndicatorView *activityIndicator;
    Settings *st ;
}
@property (strong, nonatomic) DataDownloader *getData;
@end

@implementation HomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self CreateNavigationBarButtons];
    
    profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
    profileImage.layer.masksToBounds = YES;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [collectionViewOutlet addSubview:refreshControl];
    collectionViewOutlet.alwaysBounceVertical = YES;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [activityIndicator startAnimating];
    
   
    
    self.homeDictionary = [[NSMutableDictionary alloc]init];
    
    
    //  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.homeDictionary = data;
            
            home = [Home alloc];
            
            home.dataDictionary = self.homeDictionary;
            
            home = [home init];
            
            
            nameUiLabel.text = [NSString stringWithFormat:@"سلام %@", home.name];
            dayWeekUiLabel.text = home.weekDay;
            
            [commentUiTextView setEditable:NO];
            [commentUiTextView setSelectable:NO];
            [commentUiTextView setText:home.comment];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [collectionViewOutlet reloadData];
                [refreshControl endRefreshing];
                [activityIndicator stopAnimating];
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
    
    st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    [self.getData GetHome:st.settingId Password:st.password
             withCallback:callback];
    
    
    [self GetProfilePic:st];
    
}

- (void)GetProfilePic:(Settings *)st {
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
            [activityView stopAnimating];
            
            NSLog( @"Unable to fetch Data. Try again.");
        }
    };
    
    
    
    [self.getData GetProfilePicInfo:st.settingId Password:st.password
                       withCallback:callback2];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    
    
    
    self.homeDictionary = [[NSMutableDictionary alloc]init];
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.homeDictionary = data;
            
            home = [Home alloc];
            
            home.dataDictionary = self.homeDictionary;
            
            home = [home init];
            
            
            nameUiLabel.text = [NSString stringWithFormat:@"سلام %@", home.name];
            dayWeekUiLabel.text = home.weekDay;
            
            [commentUiTextView setEditable:NO];
            [commentUiTextView setSelectable:NO];
            [commentUiTextView setText:home.comment];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [activityIndicator stopAnimating];
                [collectionViewOutlet reloadData];
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
    

    [self.getData GetHome:st.settingId Password:st.password
             withCallback:callback];
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
    return [home.homeIconList count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    iconCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    HomeIcon *homeIcon =((HomeIcon*)[home.homeIconList objectAtIndex:indexPath.row]);
    
    
    
    cell.captionLabel.text = homeIcon.caption;
    
    
    cell.iconImage.layer.cornerRadius = 7;
    cell.iconImage.clipsToBounds = YES;
    [cell.activityView startAnimating];
    
    if (homeIcon.image) {
        [cell.iconImage addTarget:self action:@selector(Participate:)forControlEvents:UIControlEventTouchUpInside];
        [cell.iconImage setImage:homeIcon.image forState:UIControlStateNormal];
        [cell.iconImage setFrame:CGRectMake(0, 0, 70, 70)];
        cell.iconImage.tag = [homeIcon.iconId integerValue];
    } else {
        
        // download the image asynchronously
        [self downloadImageWithURL:homeIcon.iconURL completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                // change the image in the cell
                [cell.iconImage addTarget:self action:@selector(actionButton:)forControlEvents:UIControlEventTouchUpInside];
                [cell.iconImage setImage:image forState:UIControlStateNormal];
                [cell.iconImage setFrame:CGRectMake(0, 0, 70, 70)];
                cell.iconImage.tag = [homeIcon.iconId integerValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [cell.activityView stopAnimating];
                });
                
                // cache the image for use later (when scrolling up)
                homeIcon.image = image;
            }
        }];
    }
    
    
    return cell;
}


-(void)actionButton:(id)sender
{
    @try {
        
        for (HomeIcon *item in home.homeIconList) {
            
            if (((UIButton*)sender).tag == [item.iconId integerValue]) {
                
                title = item.caption;
                content = item.data;
                imageToDetail = item.image;
                
                if ([item.type isEqualToString:@"Show"]) {
                    
                    [self performSegueWithIdentifier:@"Show" sender:self];
                    
                }
                else if ([item.type isEqualToString:@"GOTO"])
                {
                    [self performSegueWithIdentifier:content sender:self];
                }
            }
        }
        
    }
    @catch (NSException *exception) {
        
         NSLog(@"Exception: %@", exception);
    }
    @finally {
        
    }
}

- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
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



- (void) statusButtonAction:(id) sender
{
    [self performSegueWithIdentifier:@"Status" sender:self];
}

- (void) settingButtonAction:(id) sender
{
    [self performSegueWithIdentifier:@"setting" sender:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ChangeProfilePic)
                                                 name:@"ProfilePicIsChanged"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ChangeProfileInfo)
                                                 name:@"ProfileChanged"
                                               object:nil];
}

-(void)ChangeProfilePic
{
  [self GetProfilePic:st];
}

-(void)ChangeProfileInfo
{

    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.homeDictionary = data;
            
            home = [Home alloc];
            
            home.dataDictionary = self.homeDictionary;
            
            home = [home init];
            
            
            nameUiLabel.text = [NSString stringWithFormat:@"سلام %@", home.name];
            dayWeekUiLabel.text = home.weekDay;
            
            [commentUiTextView setEditable:NO];
            [commentUiTextView setSelectable:NO];
            [commentUiTextView setText:home.comment];
            
            
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
    
    [self.getData GetHome:st.settingId Password:st.password
             withCallback:callback];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"Show"]) {
        HomeDetailViewController *destination = [segue destinationViewController];
        destination.content = content;
        destination.detailTitle = title;
        destination.coverImage = imageToDetail;
    }
    
}

@end
