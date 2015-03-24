//
//  iconCollectionViewCell.h
//  2x2
//
//  Created by aDb on 3/9/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iconCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@end
