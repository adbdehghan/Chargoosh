//
//  InviteViewController.m
//  2x2
//
//  Created by aDb on 3/11/15.
//  Copyright (c) 2015 aDb. All rights reserved.
//

#import "InviteViewController.h"
#import "DBManager.h"
#import "Status.h"
#import "DataDownloader.h"
#import <AddressBook/AddressBook.h>
#import "THContact.h"
#import "AFNetworking.h"
#define URLaddress "http://www.newapp.chargoosh.ir/api/register/Invites"

@interface InviteViewController ()
{
    Settings *st;
}
@property (strong, nonatomic) DataDownloader *getData;
@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@end

UIBarButtonItem *barButton;
#define kKeyboardHeight 0.0

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Get the previous view controller
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popViewController)];
    
    // Associate the barButtonItem to the previous view
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
    st = [[Settings alloc]init];
    
    st = [DBManager selectSetting][0];
    
    self.title = @"انتخاب کنید (0)";
    
    CFErrorRef error;
    _addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    
    
    barButton = [[UIBarButtonItem alloc] initWithTitle:@"دعوت" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    barButton.enabled = FALSE;
    
    self.navigationItem.rightBarButtonItem = barButton;
    
    // Initialize and add Contact Picker View
    self.contactPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    self.contactPickerView.delegate = self;
    [self.contactPickerView setPlaceholderString:@"اسم مورد نظر را تایپ کنید"];
    [self.view addSubview:self.contactPickerView];
    
    // Fill the rest of the view with the table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.contactPickerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height - kKeyboardHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"THContactPickerTableViewCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    
    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
    
   
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getContactsFromAddressBook];
            });
        } else {
            // TODO: Show alert
        }
    });

}

-(void)getContactsFromAddressBook
{
    CFErrorRef error = NULL;
    self.contacts = [[NSMutableArray alloc]init];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *mutableContacts = [NSMutableArray arrayWithCapacity:allContacts.count];
        
        NSUInteger i = 0;
        for (i = 0; i<[allContacts count]; i++)
        {

           
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            ABMultiValueRef multiPhones = ABRecordCopyValue(contactPerson,kABPersonPhoneProperty);
            
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);++i) {
                
                 THContact *contact = [[THContact alloc] init];
                
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                
                [phoneNumbers addObject:phoneNumber];

            
            contact.recordId = ABRecordGetRecordID(contactPerson);
            
            // Get first and last names
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            
            // Set Contact properties
            contact.firstName = firstName;
            contact.lastName = lastName;
            
           
            
            // Get mobile number
            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
                contact.phone = phoneNumber;
            if(phonesRef) {
                CFRelease(phonesRef);
            }
            
            // Get image if it exists
            NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
            contact.image = [UIImage imageWithData:imgData];
            if (!contact.image) {
                contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
            }
            
            [mutableContacts addObject:contact];
        }
        }
        
        if(addressBook) {
            CFRelease(addressBook);
        }
        
        self.contacts = [NSArray arrayWithArray:mutableContacts];
        self.selectedContacts = [NSMutableArray array];
        self.filteredContacts = self.contacts;
        
        [self.tableView reloadData];
    }
    else
    {
        NSLog(@"Error");
        
    }
}

- (void) refreshContacts
{
    for (THContact* contact in self.contacts)
    {
        [self refreshContact: contact];
    }
    [self.tableView reloadData];
}

- (void) refreshContact:(THContact*)contact
{
    ABRecordRef contactPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, (ABRecordID)contact.recordId);
    contact.recordId = ABRecordGetRecordID(contactPerson);
    
    // Get first and last names
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
    
    // Set Contact properties
    contact.firstName = firstName;
    contact.lastName = lastName;
    
    // Get mobile number
    ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
    contact.phone = [self getMobilePhoneProperty:phonesRef];
    if(phonesRef) {
        CFRelease(phonesRef);
    }
    
    // Get image if it exists
    NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
    contact.image = [UIImage imageWithData:imgData];
    if (!contact.image) {
        contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
    }
}

- (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if(currentPhoneLabel) {
            if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
            
            if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
        }
        if(currentPhoneLabel) {
            CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue) {
            CFRelease(currentPhoneValue);
        }
    }
    
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshContacts];
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat topOffset = 0;
    if ([self respondsToSelector:@selector(topLayoutGuide)]){
        topOffset = self.topLayoutGuide.length;
    }
    CGRect frame = self.contactPickerView.frame;
    frame.origin.y = topOffset;
    self.contactPickerView.frame = frame;
    [self adjustTableViewFrame:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustTableViewFrame:(BOOL)animated {
    CGRect frame = self.tableView.frame;
    // This places the table view right under the text field
    frame.origin.y = self.contactPickerView.frame.size.height;
    // Calculate the remaining distance
    frame.size.height = self.view.frame.size.height - self.contactPickerView.frame.size.height - kKeyboardHeight;
    
    if(animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.tableView.frame = frame;
        
        [UIView commitAnimations];
    }
    else{
        self.tableView.frame = frame;
    }
}



#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the desired contact from the filteredContacts array
    THContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    
    // Initialize the table view cell
    NSString *cellIdentifier = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Get the UI elements in the cell;
    UILabel *contactNameLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *mobilePhoneNumberLabel = (UILabel *)[cell viewWithTag:102];
    UIImageView *contactImage = (UIImageView *)[cell viewWithTag:103];
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    
    // Assign values to to US elements
    contactNameLabel.text = [contact fullName];
    mobilePhoneNumberLabel.text = contact.phone;
    if(contact.image) {
        contactImage.image = contact.image;
    }
    contactImage.layer.masksToBounds = YES;
    contactImage.layer.cornerRadius = 20;
    
    // Set the checked state for the contact selection checkbox
    UIImage *image;
    if ([self.selectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
    } else {
        //cell.accessoryType = UITableViewCellAccessoryNone;
        image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    }
   // checkboxImageView.image = image;
    
    // Assign a UIButton to the accessoryView cell property
    cell.accessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    // Set a target and selector for the accessoryView UIControlEventTouchUpInside
    [(UIButton *)cell.accessoryView addTarget:self action:@selector(viewContactDetail:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView.tag = contact.recordId; //so we know which ABRecord in the IBAction method
    
    // // For custom accessory view button use this.
    //    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    //    button.frame = CGRectMake(0.0f, 0.0f, 150.0f, 25.0f);
    //
    //    [button setTitle:@"Expand"
    //            forState:UIControlStateNormal];
    //
    //    [button addTarget:self
    //               action:@selector(viewContactDetail:)
    //     forControlEvents:UIControlEventTouchUpInside];
    //
    //    cell.accessoryView = button;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Hide Keyboard
    [self.contactPickerView resignKeyboard];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // This uses the custom cellView
    // Set the custom imageView
    THContact *user = [self.filteredContacts objectAtIndex:indexPath.row];
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    UIImage *image;
    
    if ([self.selectedContacts containsObject:user]){ // contact is already selected so remove it from ContactPickerView
        //cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedContacts removeObject:user];
        [self.contactPickerView removeContact:user];
        // Set checkbox to "unselected"
        image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    } else {
        // Contact has not been selected, add it to THContactPickerView
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedContacts addObject:user];
        [self.contactPickerView addContact:user withName:user.fullName];
        // Set checkbox to "selected"
        image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
    }
    
    // Enable Done button if total selected contacts > 0
    if(self.selectedContacts.count > 0) {
        barButton.enabled = TRUE;
    }
    else
    {
        barButton.enabled = FALSE;
    }
    
    // Update window title
    self.title = [NSString stringWithFormat:@"انتخاب شده (%lu)", (unsigned long)self.selectedContacts.count];
    
    // Set checkbox image
    checkboxImageView.image = image;
    // Reset the filtered contacts
    self.filteredContacts = self.contacts;
    // Refresh the tableview
    [self.tableView reloadData];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.%@ contains[cd] %@ OR self.%@ contains[cd] %@", @"firstName", textViewText, @"lastName", textViewText];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    [self adjustTableViewFrame:YES];
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.selectedContacts removeObject:contact];
    
    NSUInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    //cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Enable Done button if total selected contacts > 0
    if(self.selectedContacts.count > 0) {
        barButton.enabled = TRUE;
    }
    else
    {
        barButton.enabled = FALSE;
    }
    
    // Set unchecked image
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    UIImage *image;
    image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    checkboxImageView.image = image;
    
    // Update window title
    self.title = [NSString stringWithFormat:@"انتخاب شده (%lu)", (unsigned long)self.selectedContacts.count];
}

- (void)removeAllContacts:(id)sender
{
    [self.contactPickerView removeAllContacts];
    [self.selectedContacts removeAllObjects];
    self.filteredContacts = self.contacts;
    [self.tableView reloadData];
}
#pragma mark ABPersonViewControllerDelegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}


// This opens the apple contact details view: ABPersonViewController
//TODO: make a THContactPickerDetailViewController
- (IBAction)viewContactDetail:(UIButton*)sender {
    ABRecordID personId = (ABRecordID)sender.tag;
    ABPersonViewController *view = [[ABPersonViewController alloc] init];
    view.addressBook = self.addressBookRef;
    view.personViewDelegate = self;
    view.displayedPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, personId);
    
    
    [self.navigationController pushViewController:view animated:YES];
}

// TODO: send contact object
- (void)done:(id)sender
{
    [self invite];
    
}

-(void)invite
{
    
    NSMutableArray *selectedNumbers = [[NSMutableArray alloc]init];
    
    for (THContact *item in self.selectedContacts) {
        
        [selectedNumbers addObject:item.phone];
        
    }
    
    NSDictionary *parameters = @{@"phoneNumber": st.settingId,
                                 @"pass": st.password,
                                 @"numbers":selectedNumbers};
    

    
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    
    NSString *URLString = @URLaddress;
    
    
    [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Success %@", responseObject);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                        message:[NSString stringWithFormat:@"%@",responseObject]
                                                       delegate:self
                                              cancelButtonTitle:@"خب"
                                              otherButtonTitles:nil];
        [alert show];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      
        NSLog(@"Failure %@, %@", error, operation.responseString);
    }];
}

-(IBAction)continueButton:(id)sender
{
  
    
    if ([numberUiTextField.text isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"خطا"
                                                        message:@"لطفا شماره ی خود را وارد کنید"
                                                       delegate:self
                                              cancelButtonTitle:@"خب"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [activityView startAnimating];
        
        RequestCompleteBlock callback = ^(BOOL wasSuccessful,NSMutableDictionary *data) {
            if (wasSuccessful) {
                
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"📢"
                                                                message:@"انجام شد!"
                                                               delegate:self
                                                      cancelButtonTitle:@"خب"
                                                      otherButtonTitles:nil];
                [alert show];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [activityView stopAnimating];
                    [continueButton setEnabled:YES];
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
        
          [continueButton setEnabled:NO];
        [self.getData Invite:st.settingId Password:st.password contactNumber:[NSString stringWithFormat:@"%@",numberUiTextField.text] withCallback:callback];
    
    }
}


- (DataDownloader *)getData
{
    if (!_getData) {
        self.getData = [[DataDownloader alloc] init];
    }
    
    return _getData;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //    [nameUiTextField resignFirstResponder];
    //    [familyCodeUiTextField resignFirstResponder];
    [self.view endEditing:YES];
    
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
