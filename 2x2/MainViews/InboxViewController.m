//
//  InboxViewController.m
//  2x2
//
//  Created by aDb on 2/24/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "InboxViewController.h"
#import "DataDownloader.h"
#import "Settings.h"
#import "DBManager.h"
#import "CustomTableViewCell.h"
#import "UIView+Shadow.h"

#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface InboxViewController ()
@property (strong, nonatomic) DataDownloader *getData;

@end

@implementation InboxViewController
UIActivityIndicatorView *activityIndicator;

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
    //    self.messageDictionary = [[NSMutableDictionary alloc]init];
    //    self.messageList = [[NSMutableArray alloc]init];
    //
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 80;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self CreateNavigationBarButtons];
}


-(void)viewDidAppear:(BOOL)animated
{
    self.messageDictionary = [[NSMutableDictionary alloc]init];
    self.messageList = [[NSMutableArray alloc]init];
    [activityIndicator startAnimating];
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            
            self.messageDictionary = data;
            [self.messageList removeAllObjects];
            
            for (NSString *item in self.messageDictionary)
            {
                [self.messageList addObject:[item valueForKey:@"content"]];
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
            [activityIndicator stopAnimating];
            
            NSLog( @"Unable to fetch Data. Try again.");
        }
    };
    
    [self.getData GetMessages:st.settingId Password:st.password
                 withCallback:callback];
    
    
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    
    
    
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            self.messageDictionary = [[NSMutableDictionary alloc]init];
            self.messageDictionary = data;
            [self.messageList removeAllObjects];
            
            for (NSString *item in self.messageDictionary)
            {
                [self.messageList addObject:[item valueForKey:@"content"]];
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
    
    [self.getData GetMessages:st.settingId Password:st.password
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



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messageList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView.estimatedRowHeight = 100;
    
    static NSString *cellIdentifier = @"CellIdentifier";
    
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    NSString *cellText = [self.messageList objectAtIndex:indexPath.row];
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:cellText];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    //    paragraphStyle.alignment = NSTextAlignmentJustified;    // To justified text
    
    
    
    
    
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [cellText length])];
    
    cell.titleLabel.attributedText = attributedString ;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //cell.titleLabel.text= cellText;
    cell.titleLabel.textColor=[UIColor blackColor];
    cell.titleLabel.backgroundColor = [UIColor clearColor];
    
    //[cell.background makeInsetShadowWithRadius:6 Alpha:.4];
    cell.background.layer.cornerRadius = 6;
    
    
    //cell.background.layer.cornerRadius = cell.mmimageView.frame.size.width/3;
    
    cell.background.clipsToBounds = YES;
    cell.background.backgroundColor = RGBCOLOR(225, 225, 225);
    
    cell.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.titleLabel.numberOfLines = 0;
    
    [cell.titleLabel setTextAlignment:NSTextAlignmentRight];
    [cell.titleLabel setFont:[UIFont fontWithName:@"B Yekan" size:15]];
    
    
    return cell;
    
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



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
