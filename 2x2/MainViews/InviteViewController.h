//
//  InviteViewController.h
//  2x2
//
//  Created by aDb on 3/11/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContactPickerView.h"
#import <AddressBookUI/AddressBookUI.h>
#import "THContactPickerView.h"
#import "THContactPickerTableViewCell.h"

@interface InviteViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, THContactPickerDelegate, ABPersonViewControllerDelegate>
{
    IBOutlet UITextField *numberUiTextField;
    IBOutlet UIButton *continueButton;
    IBOutlet UIActivityIndicatorView *activityView;
}
@property (nonatomic, strong) THContactPickerView *contactPickerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;

@end
