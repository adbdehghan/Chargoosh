//
//  FirstViewController.h
//  2x2
//
//  Created by aDb on 2/23/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
{
    IBOutlet UICollectionView *collectionViewOutlet;
    IBOutlet UILabel *nameUiLabel;
    IBOutlet UILabel *dayWeekUiLabel;
    IBOutlet UITextView *commentUiTextView;
    IBOutlet UIImageView *profileImage;
    IBOutlet UIActivityIndicatorView *activityView;
    IBOutlet UIImageView *mainImage;
}
@property (strong, nonatomic)  NSMutableDictionary *homeDictionary;
@property (strong, nonatomic)  NSMutableArray *homeList;
@property (strong ,nonatomic) NSMutableDictionary *cachedImages;
@property (nonatomic,retain)NSString *organizationID;
@end

