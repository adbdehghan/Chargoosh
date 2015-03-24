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

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Settings *st = [[Settings alloc]init];
    
    
    
    for (Settings *item in [DBManager selectSetting])
    {
        st =item;
    }
    
    
    
    if (st.settingId!=nil )
    {
        [self performSelector:@selector(performSegueToMain) withObject:nil afterDelay:.9];
    }
    else
        [self performSelector:@selector(performSegueToNext) withObject:nil afterDelay:.9];
    // Do any additional setup after loading the view.
}

-(void)performSegueToNext
{
    [self performSegueWithIdentifier:@"FirstToEnterNumber" sender:self];
}

-(void)performSegueToMain
{
    [self performSegueWithIdentifier:@"FirstToMain" sender:self];
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
