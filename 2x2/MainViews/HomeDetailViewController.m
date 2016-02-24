//
//  HomeDetailViewController.m
//  2x2
//
//  Created by aDb on 3/9/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "HomeDetailViewController.h"
#import "StrechyParallaxScrollView.h"
#import "Masonry.h"
#define RGBCOLOR(r,g,b)     [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

@interface HomeDetailViewController ()
{
    StrechyParallaxScrollView *strechy;
}
@end

@implementation HomeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CustomizeNavigationBar];
    
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 150)];
    
    [topView setBackgroundColor:RGBCOLOR(53, 52, 52)];
    [topView setClipsToBounds:YES];
    
    // [topView makeInsetShadowWithRadius:7 Alpha:.4];
    
    
    UIImageView *circle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 45, 80, 80)];
    [circle setImage:self.coverImage];
    [circle setCenter:topView.center];
    [circle.layer setMasksToBounds:YES];
    [circle.layer setCornerRadius:40];
    [topView addSubview:circle];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, width, 20)];
    [label setText:self.detailTitle];
    
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setFont:[UIFont fontWithName:@"B Yekan+" size:19]];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setTextColor:[UIColor whiteColor]];
    [topView addSubview:label];
    //masonary constraints for parallax view subviews (optional)
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo (circle.mas_bottom).offset (5);
        make.centerX.equalTo (topView);
    }];
    [circle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo ([NSValue valueWithCGSize:CGSizeMake(80, 80)]);
        make.center.equalTo (topView);
    }];
    
    
    //create strechy parallax scroll view
    strechy = [[StrechyParallaxScrollView alloc] initWithFrame:self.view.frame andTopView:topView];
    [self.view addSubview:strechy];
    
    //add dummy scroll view items
    float itemStartY = topView.frame.size.height + 10;
    
    [strechy addSubview:[self scrollViewItemWithY:itemStartY andContent:self.content]];
}

- (UITextView *)scrollViewItemWithY:(CGFloat)y andContent:(NSString*)content {
    
    
    UITextView *item = [[UITextView alloc] initWithFrame:CGRectMake(10, y, [UIScreen mainScreen].bounds.size.width-20, self.view.bounds.size.height)];
    
    
    [item setBaseWritingDirection:UITextWritingDirectionRightToLeft forRange:[item textRangeFromPosition:[item beginningOfDocument] toPosition:[item endOfDocument]]];
    
    [item setTextAlignment:NSTextAlignmentJustified];
    [item setFont:[UIFont fontWithName:@"B Yekan+" size:19]];
    [item setText:[NSString stringWithFormat:@"%@", content]];
    [item setEditable:NO];
    [item setSelectable:NO];
    //[item sizeToFit];
    [item layoutIfNeeded];
   
    
    
    CGRect newFrame = item.frame;
    newFrame.size.height = item.contentSize.height+105;
    item.frame = newFrame;
    
    
    [strechy setContentSize:CGSizeMake(self.view.bounds.size.width , item.contentSize.height*2)];
    
    return item;
}

- (void)CustomizeNavigationBar {
    // Do any additional setup after loading the view.
    
    UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationItem.titleView.frame.size.width, 40)];
    label.text=self.detailTitle;
    label.textColor=[UIColor whiteColor];
    label.backgroundColor =[UIColor clearColor];
    label.adjustsFontSizeToFitWidth=YES;
    label.font = [UIFont fontWithName:@"B Yekan+" size:17];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView=label;

    // Get the previous view controller
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
    
    // Associate the barButtonItem to the previous view
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
    
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
