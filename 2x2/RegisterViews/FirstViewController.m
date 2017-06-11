//
//  FirstViewController.m
//  2x2
//
//  Created by aDb on 3/1/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "FirstViewController.h"
#import "DBManager.h"
#import "Settings.h"
#import "AnimatedGIFImageSerialization.h"


@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    introImage.image = [UIImage imageNamed:@"introImage.gif"];
    
    
    
        Settings *st = [[Settings alloc]init];
    
        for (Settings *item in [DBManager selectSetting])
        {
            st =item;
        }

    
    if (st.settingId!=nil )
    {
        [self performSelector:@selector(performSegueToMain) withObject:nil afterDelay:2.5];
    }
    else
        [self performSelector:@selector(performSegueToNext) withObject:nil afterDelay:2.5];

}

-(void)performSegueToNext
{
    [self performSegueWithIdentifier:@"enterNumber" sender:self];
}

-(void)performSegueToMain
{
    [self performSegueWithIdentifier:@"main" sender:self];
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
