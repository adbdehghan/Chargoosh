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
#import "CompetitionDetailViewController.h"
#import "CompetitionPlusDetailViewController.h"
#import "SelectedViewController.h"
#import "QRCodeReaderViewController.h"
#define URLaddressPic "http://newapp.chargoosh.ir/"
#import "AppDelegate.h"

static NSString *Version = @"\"1.2\"";
static NSString *currentVersion = @"\"1.2\"";
static NSString *iconId;
@interface HomeViewController ()<QRCodeReaderDelegate>
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
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    self.organizationID = app.organizationID;
    
    self.cachedImages = [[NSMutableDictionary alloc] init];
    
    profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
    profileImage.layer.masksToBounds = YES;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [collectionViewOutlet addSubview:refreshControl];
    collectionViewOutlet.alwaysBounceVertical = YES;
    collectionViewOutlet.backgroundColor = [UIColor clearColor];
    [collectionViewOutlet.layer setCornerRadius:3];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [activityIndicator startAnimating];
    
   [collectionViewOutlet setTransform:CGAffineTransformMakeScale(-1, 1)];
    
    
    [self GetHome];
    
    
    RequestCompleteBlock callback2 = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            currentVersion =[data valueForKey:@"version"];
            
            if (![currentVersion isEqualToString:Version])
            {
                
                [self performSegueWithIdentifier:@"Update" sender:self];
                
            }
            
        }
        
        else
        
        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"خطا"
//                                                            message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
//                                                           delegate:self
//                                                  cancelButtonTitle:@"خب"
//                                                  otherButtonTitles:nil];
//            [alert show];
            
            
            
            NSLog( @"Unable to fetch Data. Try again.");
        }
    };
    
   // [self.getData GetVersion:@"" withCallback:callback2];
    
}


-(void)viewDidAppear:(BOOL)animated
{

      [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(notify) name:@"post" object:nil];
}

-(void)notify{
    
    [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:@"⚡︎"];
    
}

- (void)GetHome {

 
    self.homeDictionary = [[NSMutableDictionary alloc]init];
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            if ([data valueForKey:@"picture"] != [NSNull null]) {
                
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
            self.homeDictionary = data;
            
            home = [Home alloc];
            
            home.dataDictionary = self.homeDictionary;
            
            home = [home init];
            
            
            nameUiLabel.text = [NSString stringWithFormat:@"سلام %@", home.name];
            dayWeekUiLabel.text = home.weekDay;
            
            [commentUiTextView setEditable:NO];
            [commentUiTextView setSelectable:NO];
            [commentUiTextView setText:home.comment];
            commentUiTextView.textColor = [UIColor whiteColor];
            commentUiTextView.font = [UIFont fontWithName:@"B Yekan+" size:15];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [collectionViewOutlet reloadData];
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
    
    [self.getData GetHome:self.organizationID token:st.accesstoken withCallback:callback];
    


}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    
    
    
    self.homeDictionary = [[NSMutableDictionary alloc]init];
    self.cachedImages = [[NSMutableDictionary alloc]init];
    
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
    
    [self.getData GetHome:self.organizationID token:st.accesstoken withCallback:callback];
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
    return [home.homeIconList count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    iconCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    HomeIcon *homeIcon =((HomeIcon*)[home.homeIconList objectAtIndex:indexPath.row]);
    
    [cell setTransform:CGAffineTransformMakeScale(-1, 1)];
    
    cell.captionLabel.text = homeIcon.caption;
    [cell.captionLabel setTextAlignment:NSTextAlignmentCenter];

    cell.iconImage.layer.cornerRadius = 7;
    cell.iconImage.clipsToBounds = YES;

    [cell.activityView startAnimating];
    
    NSString *identifier = [NSString stringWithFormat:@"Cell%ld" , (long)indexPath.row];
    
    if([self.cachedImages objectForKey:identifier] != nil)
    {
        [cell.iconImage addTarget:self action:@selector(actionButton:)forControlEvents:UIControlEventTouchUpInside];
        [cell.iconImage setImage:[self.cachedImages valueForKey:identifier] forState:UIControlStateNormal];
        
        cell.iconImage.tag = [homeIcon.iconId integerValue];
        homeIcon.image = [self.cachedImages valueForKey:identifier];
        [cell.activityView stopAnimating];
    }
    else
    {
        // download the image asynchronously
  
            [self downloadImageWithURL:homeIcon.iconURL identifier:identifier completionBlock:^(BOOL succeeded, NSMutableDictionary *image) {
                if (succeeded) {
                    // change the image in the cell
                    if ([collectionView indexPathForCell:cell].row == indexPath.row) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([image objectForKey:identifier]!=nil) {
                                
                                [self.cachedImages setValue:[image valueForKey:identifier] forKey:identifier];
                                
                                [cell.iconImage addTarget:self action:@selector(actionButton:)forControlEvents:UIControlEventTouchUpInside];
                                [cell.iconImage setImage: [self.cachedImages valueForKey:identifier] forState:UIControlStateNormal];
                                homeIcon.image = [self.cachedImages valueForKey:identifier];
                                cell.iconImage.tag = [homeIcon.iconId integerValue];

                                [cell.activityView stopAnimating];
                            }
                            
                        });
                    }
                }
            }];
        
        cell.iconImage.imageView.image = nil;
        
    }

    
    
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
    return UIEdgeInsetsMake(5,5,0,5);  // top, left, bottom, right
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
                
                else
                {
                    iconId = content;
                    [self performSegueWithIdentifier:item.type sender:self];
                
                }
                
                
                
//                else if ([item.type isEqualToString:@"GOTO"])
//                {
//                    [self performSegueWithIdentifier:content sender:self];
//                }
//                
//                else if ([item.type isEqualToString:@"Competiton"])
//                {
//                    [self performSegueWithIdentifier:@"HomeToCompetition" sender:self];
//                }
//                
//                else if ([item.type isEqualToString:@"Poll"])
//                {
//                    [self performSegueWithIdentifier:@"HomeToPoll" sender:self];
//                }
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
    
    UIImage *image = [[UIImage imageNamed:@"status@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [statusButton setImage:image forState:UIControlStateNormal];
    statusButton.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:statusButton];
    
    
    UIButton *barcodeButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *barcodeImage = [UIImage imageNamed:@"m_scan.png"];
    
    [barcodeButton setImage:barcodeImage forState:UIControlStateNormal];
    barcodeButton.tintColor = [UIColor whiteColor];
    [barcodeButton addTarget:self action:@selector(ShowQR)forControlEvents:UIControlEventTouchUpInside];
    [barcodeButton setFrame:CGRectMake(0, 0, 20, 20)];
    
    
    UIBarButtonItem *barcodeBarButton = [[UIBarButtonItem alloc] initWithCustomView:barcodeButton];
    
      NSArray *barButtons = @[barcodeBarButton,barButton];
    
    self.navigationItem.leftBarButtonItems = barButtons;
    
    UIButton *settingButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *settingImage = [[UIImage imageNamed:@"groups.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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


- (void) statusButtonAction:(id) sender
{
    [self performSegueWithIdentifier:@"GOTOstatus" sender:self];
}

- (void) settingButtonAction:(id) sender
{
    [self performSegueWithIdentifier:@"groups" sender:self];
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
  [self GetHome];
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
    
    [self.getData GetHome:self.organizationID token:st.accesstoken withCallback:callback];
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
    else
    {
        if ([segue.identifier isEqual:@"GOTOcompetition"]) {
            
            CompetitionDetailViewController *destination = [segue destinationViewController];
            destination.competitionId = iconId;
            destination.competitionTitle = title;
            destination.coverImage = imageToDetail;
        }
        
        else if ([segue.identifier isEqual:@"GOTOcompetitionplus"])
        {
            CompetitionPlusDetailViewController *destination = [segue destinationViewController];
            destination.competitionTitle = title;
            destination.competitionId = iconId;
        
        }
        else if ([segue.identifier isEqual:@"GOTOtopparticipates"])
        {
            
            SelectedViewController *destination = [segue destinationViewController];
            destination.competitionId = iconId;
        }
    
    }
    
}

@end
