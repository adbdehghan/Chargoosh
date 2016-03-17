//
//  MyOrganizationsViewController.h
//  2x2
//
//  Created by aDb on 2/27/16.
//  Copyright © 2016 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CZPicker.h>

@interface MyOrganizationsViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate,CZPickerViewDataSource, CZPickerViewDelegate>
{
    IBOutlet UICollectionView *collectionViewOutlet;
}
@property (strong, nonatomic)  NSMutableDictionary *homeDictionary;
@property (strong, nonatomic)  NSMutableArray *organizationList;
@property (strong, nonatomic)  NSMutableArray *allOrganizationList;
@property (strong ,nonatomic) NSMutableDictionary *cachedImages;
@end
