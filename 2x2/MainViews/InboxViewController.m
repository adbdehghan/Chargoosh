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

@implementation CALayer (Additions)

- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

@end

@implementation InboxViewController
UIActivityIndicatorView *activityIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [activityIndicator startAnimating];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 80;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    UIView *layer = [[UIView alloc]init];
    layer.backgroundColor = [UIColor blackColor];
    layer.alpha = .5f;
    [layer setFrame:self.view.frame];
    
    UIImageView *backImage =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.jpg"]];
    [backImage setFrame:CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height-110 )];
    backImage.contentMode = UIViewContentModeScaleAspectFill;
    UIView *container = [[UIView alloc]init];
    [container setFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-110 )];
    
    [container addSubview:backImage];
    [container addSubview:layer];
    
    self.tableView.backgroundView = container;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self CreateNavigationBarButtons];
}


-(void)viewDidAppear:(BOOL)animated
{
  
    self.messageDictionary = [[NSMutableDictionary alloc]init];
    self.messageList = [[NSMutableArray alloc]init];
    self.messageDateList = [[NSMutableArray alloc]init];
    
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
                [self.messageDateList addObject:[item valueForKey:@"assignDateString"]];
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
            [activityIndicator stopAnimating];
            
            NSLog( @"Unable to fetch Data. Try again.");
        }
    };
    
    [self.getData GetMessages:st.accesstoken withCallback:callback];
    
    
}


- (void)refresh:(UIRefreshControl *)refreshControl {
     
    Settings *st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
        if (wasSuccessful) {
            self.messageDictionary = [[NSMutableDictionary alloc]init];
            self.messageDictionary = data;
            [self.messageList removeAllObjects];
            [self.messageDateList removeAllObjects];
            
            for (NSString *item in self.messageDictionary)
            {
                [self.messageList addObject:[item valueForKey:@"content"]];
                [self.messageDateList addObject:[item valueForKey:@"assignDateString"]];
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
    
    [self.getData GetMessages:st.accesstoken withCallback:callback];
    
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
    if ([self.messageList  count]>0) {
        NSString *cellText = [self.messageList objectAtIndex:indexPath.row];
        NSString *dateText = [self.messageDateList objectAtIndex:indexPath.row];
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:cellText];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:6];
        //    paragraphStyle.alignment = NSTextAlignmentJustified;    // To justified text
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [cellText length])];
        
        cell.titleLabel.attributedText = attributedString;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.dateTimeLabel.font =[UIFont fontWithName:@"B Yekan" size:15];
        cell.dateTimeLabel.text = [ NSString stringWithFormat:@"%@",dateText];

        
        if (indexPath.row % 2 == 0) {
            [cell.dateBackground setBackgroundColor:RGBCOLOR(110, 110,110)];
        }
        else
        {
            [cell.dateBackground setBackgroundColor:RGBCOLOR(5, 113,189)];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.titleLabel.textColor=[UIColor blackColor];
        cell.titleLabel.backgroundColor = [UIColor clearColor];
        
      //  cell.background.layer.cornerRadius = 6;
        
        cell.background.clipsToBounds = YES;
        cell.background.backgroundColor = [UIColor whiteColor];
        
        cell.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.titleLabel.numberOfLines = 0;
        
        
        [cell.titleLabel setTextAlignment:NSTextAlignmentRight];
        [cell.titleLabel setFont:[UIFont fontWithName:@"B Yekan+" size:15]];
        [cell.titleLabel sizeToFit];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.messageList  count]>0) {
        NSString *cellText = [self.messageList objectAtIndex:indexPath.row];
        
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:cellText];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:6];
        //    paragraphStyle.alignment = NSTextAlignmentJustified;    // To justified text
        
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [cellText length])];
        
        UILabel *textLabel = [[UILabel alloc]init];
        
        textLabel.frame =CGRectMake(0, 0,tableView.bounds.size.width - 30 ,9999 );
        
        textLabel.attributedText = attributedString;
        
        textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        textLabel.numberOfLines = 0;
        [textLabel setTextAlignment:NSTextAlignmentRight];
        [textLabel setFont:[UIFont fontWithName:@"B Yekan+" size:15]];
        
        [textLabel sizeToFit];
        
        int size = textLabel.frame.size.height;
        
        return size + 78;
    }
    
    else
        
        return 50;
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
    [self performSegueWithIdentifier:@"groups" sender:self];
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
