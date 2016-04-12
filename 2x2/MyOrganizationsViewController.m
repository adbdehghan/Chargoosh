//
//  MyOrganizationsViewController.m
//  2x2
//
//  Created by aDb on 2/27/16.
//  Copyright © 2016 aDb. All rights reserved.
//

#import "MyOrganizationsViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "Organization.h"
#import "DBManager.h"
#import "HomeTableViewCell.h"
#import "iconCollectionTableViewCell.h"
#import "iconCollectionViewCell.h"
#import "Organization.h"
#import "AppDelegate.h"
#import "MZLoadingCircle.h"
#import "UIImageView+WebCache.h"

#define URLaddressPic "http://new.chargoosh.ir/"

@interface MyOrganizationsViewController ()
{
    Organization *organization;
    NSURL *imageURL;
    UIActivityIndicatorView *activityIndicator;
    Settings *st ;
    MZLoadingCircle *loadingCircle;
}
@property (strong, nonatomic) DataDownloader *getData;
@property CZPickerView *pickerWithImage;
@end

@implementation MyOrganizationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self CreateNavigationBarButtons];
    
    self.cachedImages = [[NSMutableDictionary alloc] init];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    [collectionViewOutlet addSubview:refreshControl];
    collectionViewOutlet.alwaysBounceVertical = YES;
    collectionViewOutlet.backgroundColor = [UIColor clearColor];
    [collectionViewOutlet.layer setCornerRadius:3];
    
    [collectionViewOutlet setTransform:CGAffineTransformMakeScale(-1, 1)];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [activityIndicator startAnimating];
    
    self.homeDictionary = [[NSMutableDictionary alloc]init];
    self.organizationList = [[NSMutableArray alloc]init];
    
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            
            for (NSMutableDictionary *item in data) {
                
                self.homeDictionary = item;
                
                organization = [Organization alloc];
                
                organization.dataDictionary = self.homeDictionary;
                
                organization = [organization init];
                
                [self.organizationList addObject:organization];
            }
            
    
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [collectionViewOutlet reloadData];
                [refreshControl endRefreshing];
                [activityIndicator stopAnimating];
            });
            
            
            
        }
        
        else
        {

            
            
            NSLog( @"Unable to fetch Data. Try again.");
            
            self.getData = nil;
             self.getData = [[DataDownloader alloc] init];
            
            RequestCompleteBlock callback2 = ^(BOOL wasSuccessful,NSMutableDictionary *data2) {
                if (wasSuccessful) {
                    

                 [self UpdateToken:[data2 valueForKey:@"accesstoken"]];
                 
                    
                    [self.getData GetOrganizations:st.accesstoken withCallback:callback];
                    
                }
            else
            {
            
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                                message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                               delegate:self
                                                      cancelButtonTitle:@"خب"
                                                      otherButtonTitles:nil];
                [alert show];
            
            }
            
            };
            
            
            
            [self.getData GetToken:st.settingId password:st.password withCallback:callback2];
            
            
        }
    };
    
    st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    [self.getData GetOrganizations:st.accesstoken withCallback:callback];
    
    
    
}

-(void)UpdateToken:(NSString*)Token
{
    Settings *setting = [[Settings alloc]init];
    setting.settingId = st.settingId;
    setting.password = st.password;
    setting.accesstoken = Token;
    
    [DBManager deleteDataBase];
    [DBManager createTable];
    [DBManager saveOrUpdataSetting:setting];
    
    st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    
    
    
    self.homeDictionary = [[NSMutableDictionary alloc]init];
    self.cachedImages = [[NSMutableDictionary alloc]init];
    self.organizationList = [[NSMutableArray alloc]init];
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            
            for (NSMutableDictionary *item in data) {
                
                self.homeDictionary = item;
                
                organization = [Organization alloc];
                
                organization.dataDictionary = self.homeDictionary;
                
                organization = [organization init];
                
                [self.organizationList addObject:organization];
            }
            
            
            
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
    
    [self.getData GetOrganizations:st.accesstoken withCallback:callback];
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
    return [self.organizationList count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    iconCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    Organization *homeIcon =((Organization*)[self.organizationList objectAtIndex:indexPath.row]);
    
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
        
        cell.iconImage.tag = indexPath.row;
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
                            cell.iconImage.tag = indexPath.row;
                            
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
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    app.organizationID = ((Organization*)[self.organizationList objectAtIndex:((UIButton*)sender).tag]).iconId;
    
    [self performSegueWithIdentifier:@"main" sender:self];
}

- (IBAction)AddOrgan:(id)sender {
    self.allOrganizationList = [[NSMutableArray alloc]init];
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            
            for (NSMutableDictionary *item in data) {
                
                self.homeDictionary = item;
                
                organization = [Organization alloc];
                
                organization.dataDictionary = self.homeDictionary;
                
                organization = [organization init];
                
                [self.allOrganizationList addObject:organization];
            }
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [loadingCircle.view removeFromSuperview];
                loadingCircle = nil;
                self.pickerWithImage = [[CZPickerView alloc] initWithHeaderTitle:@"همه ی گروه ها" cancelButtonTitle:@"بی خیال" confirmButtonTitle:@"تایید"];
                self.pickerWithImage.delegate = self;
                self.pickerWithImage.dataSource = self;
                self.pickerWithImage.needFooterView = YES;
                self.pickerWithImage.allowMultipleSelection = YES;
                [self.pickerWithImage show];
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
    
    [self.getData GetAllOrganizations:st.accesstoken withCallback:callback];
    
    loadingCircle = [[MZLoadingCircle alloc]initWithNibName:nil bundle:nil];
    loadingCircle.view.backgroundColor = [UIColor clearColor];
    
    //Colors for layers
    loadingCircle.colorCustomLayer = [UIColor darkGrayColor];
    loadingCircle.colorCustomLayer2 =[UIColor grayColor];
    loadingCircle.colorCustomLayer3 = [UIColor darkGrayColor];
    
    int size = 100;
    
    CGRect frame = loadingCircle.view.frame;
    frame.size.width = size ;
    frame.size.height = size;
    frame.origin.x = self.view.frame.size.width / 2 - frame.size.width / 2;
    frame.origin.y = self.view.frame.size.height / 2 - frame.size.height / 2;
    loadingCircle.view.frame = frame;
    loadingCircle.view.layer.zPosition = MAXFLOAT;
    [self.view addSubview: loadingCircle.view];
}

- (NSString *)czpickerView:(CZPickerView *)pickerView
               titleForRow:(NSInteger)row{
    return ((Organization*)self.allOrganizationList[row]).caption;
}

- (NSURL*)czpickerView:(CZPickerView *)pickerView imageForRow:(NSInteger)row {
    
    return ((Organization*)(self.allOrganizationList[row])).iconURL;
}

- (NSString*)czpickerView:(CZPickerView *)pickerView checkForRow:(NSInteger)row {
    
    return ((Organization*)(self.allOrganizationList[row])).mine;
}

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView{
    return self.allOrganizationList.count;
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row{
    NSLog(@"%@ is chosen!", self.allOrganizationList[row]);
}

-(void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemsAtRows:(NSArray *)rows{
    NSMutableArray *orgs = [[NSMutableArray alloc]init];
    for(NSNumber *n in rows){
        NSInteger row = [n integerValue];
        NSLog(@"%@ is chosen!", self.allOrganizationList[row]);
        

        [orgs addObject:((Organization*)(self.allOrganizationList[row])).iconId];
        
        
        
    }
    
    RequestCompleteBlock callback2 = ^(BOOL wasSuccessful,NSMutableDictionary *data2) {
        if (wasSuccessful) {
            [self UpdateList];
            
        }
        else
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                            message:@"لطفا ارتباط خود با اینترنت را بررسی نمایید."
                                                           delegate:self
                                                  cancelButtonTitle:@"خب"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
        
    };
    
    
    
    [self.getData SetOrganizations:st.accesstoken Orgs:orgs withCallback:callback2];
}


-(void)UpdateList
{


    self.homeDictionary = [[NSMutableDictionary alloc]init];
    self.cachedImages = [[NSMutableDictionary alloc]init];
    self.organizationList = [[NSMutableArray alloc]init];
    [activityIndicator startAnimating];
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            
            for (NSMutableDictionary *item in data) {
                
                self.homeDictionary = item;
                
                organization = [Organization alloc];
                
                organization.dataDictionary = self.homeDictionary;
                
                organization = [organization init];
                
                [self.organizationList addObject:organization];
            }
            
            
            
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
    
    [self.getData GetOrganizations:st.accesstoken withCallback:callback];
}

- (void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView{
    NSLog(@"Canceled.");
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
    label.text=@"گروه ها";
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font = [UIFont fontWithName:@"B Yekan+" size:19];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView=label;
    
    UIButton *addButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *addImage = [[UIImage imageNamed:@"add@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [addButton setImage:addImage forState:UIControlStateNormal];
    
    addButton.tintColor = [UIColor whiteColor];
    [addButton addTarget:self action:@selector(AddOrgan:)forControlEvents:UIControlEventTouchUpInside];
    [addButton setFrame:CGRectMake(0, 0, 24, 24)];
    
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.leftBarButtonItem = addBarButton;
    
    
    UIButton *settingButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *settingImage = [[UIImage imageNamed:@"setting@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [settingButton setImage:settingImage forState:UIControlStateNormal];
    
    settingButton.tintColor = [UIColor whiteColor];
    [settingButton addTarget:self action:@selector(settingButtonAction:)forControlEvents:UIControlEventTouchUpInside];
    [settingButton setFrame:CGRectMake(0, 0, 24, 24)];
    
    
    UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    self.navigationItem.rightBarButtonItem = settingBarButton;
    
}

- (void) settingButtonAction:(id) sender
{
    [self performSegueWithIdentifier:@"setting" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
